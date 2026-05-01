import 'package:geolocator/geolocator.dart';
import '../models/ponto.dart';

/// Configuração fixa da jornada de trabalho
class Empresa {
  // R. Blumenau, 953 - Sala 402 - América, Joinville - SC
  static const double latitude = -26.2746;
  static const double longitude = -48.8426;
  static const String endereco = 'R. Blumenau, 953 - Sala 402 - Joinville, SC';
  static const int raioPermitidoMetros = 500; // 500m de tolerância
}

class HorarioJornada {
  final int hora;
  final int minuto;
  final TipoPonto tipo;
  final String label;

  HorarioJornada({
    required this.hora,
    required this.minuto,
    required this.tipo,
    required this.label,
  });

  int toMinutes() => hora * 60 + minuto;

  @override
  String toString() =>
      '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';
}

class JornadaService {
  // Horários fixos da jornada
  static final List<HorarioJornada> horariosFixos = [
    HorarioJornada(
      hora: 8,
      minuto: 30,
      tipo: TipoPonto.entrada,
      label: 'Entrada',
    ),
    HorarioJornada(
      hora: 12,
      minuto: 0,
      tipo: TipoPonto.almoco,
      label: 'Almoço',
    ),
    HorarioJornada(
      hora: 13,
      minuto: 0,
      tipo: TipoPonto.retorno,
      label: 'Retorno',
    ),
    HorarioJornada(hora: 18, minuto: 0, tipo: TipoPonto.saida, label: 'Saída'),
  ];

  static const int toleranciaMinutos = 5;

  /// Detecta qual tipo de ponto baseado na hora atual
  static TipoPonto detectarTipoPonto(DateTime dataHora) {
    final minutoAtual = dataHora.hour * 60 + dataHora.minute;

    // Agrupa os horários em períodos
    if (minutoAtual < horariosFixos[1].toMinutes()) {
      return TipoPonto.entrada;
    } else if (minutoAtual < horariosFixos[2].toMinutes()) {
      return TipoPonto.almoco;
    } else if (minutoAtual < horariosFixos[3].toMinutes()) {
      return TipoPonto.retorno;
    } else {
      return TipoPonto.saida;
    }
  }

  /// Retorna o próximo horário esperado
  static HorarioJornada? proximoHorario(List<Ponto> pontosDia) {
    final agora = DateTime.now();
    final minutoAtual = agora.hour * 60 + agora.minute;

    for (final horario in horariosFixos) {
      // Verifica se este horário já foi registrado
      final jaRegistrado = pontosDia.any((p) => p.tipo == horario.tipo);

      if (!jaRegistrado && horario.toMinutes() > minutoAtual) {
        return horario;
      }
    }
    return null;
  }

  /// Calcula se está no horário, atrasado ou falta
  static String statusPonto(Ponto ponto) {
    final horarioEsperado = horariosFixos.firstWhere(
      (h) => h.tipo == ponto.tipo,
      orElse: () => horariosFixos.first,
    );

    final minutoRegistrado = ponto.dataHora.hour * 60 + ponto.dataHora.minute;
    final minutoEsperado = horarioEsperado.toMinutes();
    final diferenca = minutoRegistrado - minutoEsperado;

    if (diferenca <= toleranciaMinutos && diferenca >= -toleranciaMinutos) {
      return 'no_horario';
    } else if (diferenca > 0) {
      return 'atrasado';
    } else {
      return 'adiantado';
    }
  }

  /// Calcula horas trabalhadas no dia
  static String calcularHorasDia(List<Ponto> pontosDia) {
    if (pontosDia.isEmpty) return '0h 00min';

    pontosDia.sort((a, b) => a.dataHora.compareTo(b.dataHora));

    int totalMinutos = 0;

    // Entrada -> Almoço
    final entradaIndex = pontosDia.indexWhere(
      (p) => p.tipo == TipoPonto.entrada,
    );
    final almocoIndex = pontosDia.indexWhere((p) => p.tipo == TipoPonto.almoco);

    if (entradaIndex >= 0 && almocoIndex >= 0) {
      totalMinutos += pontosDia[almocoIndex].dataHora
          .difference(pontosDia[entradaIndex].dataHora)
          .inMinutes;
    }

    // Retorno -> Saída
    final retornoIndex = pontosDia.indexWhere(
      (p) => p.tipo == TipoPonto.retorno,
    );
    final saidaIndex = pontosDia.indexWhere((p) => p.tipo == TipoPonto.saida);

    if (retornoIndex >= 0 && saidaIndex >= 0) {
      totalMinutos += pontosDia[saidaIndex].dataHora
          .difference(pontosDia[retornoIndex].dataHora)
          .inMinutes;
    }

    final horas = totalMinutos ~/ 60;
    final minutos = totalMinutos % 60;

    return '${horas}h ${minutos.toString().padLeft(2, '0')}min';
  }

  /// Calcula distância em metros entre dois pontos GPS
  static Future<int> calcularDistancia(Position usuarioPos) async {
    final distanciaMetros = Geolocator.distanceBetween(
      usuarioPos.latitude,
      usuarioPos.longitude,
      Empresa.latitude,
      Empresa.longitude,
    );
    return distanciaMetros.toInt();
  }

  /// Valida se usuário está dentro do raio permitido
  static Future<bool> validarLocalizacao(Position usuarioPos) async {
    final distancia = await calcularDistancia(usuarioPos);
    return distancia <= Empresa.raioPermitidoMetros;
  }

  /// Valida se botão pode ficar vermelho (hora de saída próxima)
  static bool isHorarioDeSaida(DateTime dataHora) {
    final minutoAtual = dataHora.hour * 60 + dataHora.minute;
    final minutoSaida = 18 * 60; // 18:00

    // Fica vermelho 30 minutes antes da saída
    return minutoAtual >= (minutoSaida - 30);
  }
}

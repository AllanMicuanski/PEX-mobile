import '../models/ponto.dart';

class PontoService {
  final List<Ponto> _pontos = [];

  List<Ponto> get pontos => List.unmodifiable(_pontos);

  void registrarPonto(Ponto ponto) {
    _pontos.insert(0, ponto); // Adiciona no início da lista
  }
}

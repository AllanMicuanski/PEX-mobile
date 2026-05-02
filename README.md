# PEX Mob — Controle de Ponto

Aplicativo Flutter para registro de ponto de trabalho com captura de localização e foto, desenvolvido com arquitetura orientada a serviços.

## 🎯 Funcionalidades

| Recurso               | Descrição                                                                     |
| --------------------- | ----------------------------------------------------------------------------- |
| **Registro de Ponto** | Bater ponto com detecção automática do tipo (entrada, almoço, retorno, saída) |
| **Validação GPS**     | Valida se o usuário está dentro do raio permitido (500m) da empresa           |
| **Captura de Foto**   | Integração com câmera do dispositivo para capturar foto no registro           |
| **Mapa Interativo**   | Visualização em tempo real da localização com mapa OpenStreetMap              |
| **Histórico**         | Visualização de registros anteriores com status e horários                    |
| **Persistência**      | Banco de dados SQLite local (funciona offline)                                |

## 🏗️ Arquitetura

```
lib/
├── main.dart                 # App entry point + navegação
├── models/
│   └── ponto.dart           # Modelo de dados
├── services/
│   ├── jornada_service.dart # Lógica de negócio (horários, validações)
│   ├── database_service.dart # Persistência SQLite
│   ├── location_service.dart # Gerenciamento de GPS
│   ├── camera_service.dart   # Captura de fotos
│   └── ponto_service.dart    # Orquestração de registro
├── screens/
│   ├── home_screen.dart     # Tela principal + botão de registro
│   ├── mapa_screen.dart     # Validação GPS com mapa
│   └── historico_screen.dart # Histórico de registros
└── widgets/
    ├── clock_widget.dart    # Relógio em tempo real
    └── gps_indicator.dart   # Status do GPS
```

## 🔧 Tecnologias

| Tecnologia          | Propósito                                |
| ------------------- | ---------------------------------------- |
| **Flutter** ^3.41.5 | Framework UI                             |
| **Dart** ^3.11.3    | Linguagem                                |
| **flutter_map**     | Mapa baseado em OpenStreetMap (gratuito) |
| **geolocator**      | Localização GPS com permissões           |
| **sqflite**         | Banco de dados local                     |
| **image_picker**    | Captura de fotos                         |
| **intl**            | Formatação de data/hora                  |

## 🚀 Início Rápido

### Pré-requisitos

- Flutter SDK ^3.11.3
- Android SDK 21+ ou iOS 11+
- Dispositivo/Emulador com GPS ativo

### Instalação

```bash
# 1. Clone o repositório
git clone https://github.com/AllanMicuanski/PEX-mobile.git
cd pex_mob

# 2. Instale dependências
flutter pub get

# 3. Execute no dispositivo
flutter run
```

### Permissões Obrigatórias

As permissões já estão configuradas em `android/app/src/main/AndroidManifest.xml`:

- `ACCESS_FINE_LOCATION` — GPS de alta precisão
- `CAMERA` — Captura de fotos
- `INTERNET` — Carregamento de mapa

## 📊 Regras de Negócio

A jornada de trabalho é fixa com horários pré-definidos:

| Tipo    | Horário | Tolerância |
| ------- | ------- | ---------- |
| Entrada | 8:30    | ±5 min     |
| Almoço  | 12:00   | ±5 min     |
| Retorno | 13:00   | ±5 min     |
| Saída   | 18:00   | ±5 min     |

**Validações:**

- Ponto só é aceito se usuário está **dentro de 500m** da empresa
- Status automático: `no_horario`, `adiantado` ou `atrasado`
- Botão de saída fica vermelho 30 minutos antes das 18:00

## 📱 Interface

### Tela Principal (Início)

- Relógio em tempo real
- Indicador de status GPS
- Botão grande para bater ponto (azul/vermelho)
- Grid com 4 horários do dia
- Total de horas trabalhadas

### Tela de Localização

- Mapa em OpenStreetMap
- Marcador da empresa (vermelho)
- Marcador do usuário (azul)
- Círculo de raio permitido
- Distância em metros

### Tela de Histórico

- Lista de registros anteriores
- Horários com status (on-time/late)
- Total de horas do dia

---

**Desenvolvido por:** Allan Micuanski

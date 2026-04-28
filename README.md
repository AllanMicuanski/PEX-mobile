# PEX Mob - Controle de Ponto

Este é um projeto Flutter estruturado para um aplicativo de controle de ponto, desenvolvido com foco em boas práticas de arquitetura e separação de responsabilidades.

## 🚀 Funcionalidades

- **Registro de Ponto:** Captura de data, hora, foto e localização GPS em um único fluxo.
- **Captura de Foto:** Integração com a câmera frontal para identificação no momento do registro.
- **Geolocalização:** Captura automática de coordenadas (latitude e longitude).
- **Persistência Local:** Histórico de registros salvo localmente em banco de dados SQLite (offline-first).
- **Histórico:** Visualização de registros anteriores com miniaturas das fotos e dados de localização.

## 🏗️ Arquitetura

O projeto segue uma estrutura organizada em camadas para facilitar a manutenção e escalabilidade:

- **Models:** Definição das entidades de dados (`Ponto`).
- **Services:** Camada de lógica de negócio e integração com hardware/banco:
  - `PontoService`: Orquestra o fluxo de registro completo (Foto -> GPS -> Banco).
  - `CameraService`: Gerencia a captura de imagens via hardware.
  - `LocationService`: Gerencia permissões e captura de localização.
  - `DatabaseService`: Gerencia a persistência de dados com SQLite.
- **Screens:** Camada de interface de usuário (UI), projetada para ser reativa e livre de lógica pesada.

## 🛠️ Tecnologias e Packages

- [sqflite](https://pub.dev/packages/sqflite) - Banco de dados local.
- [geolocator](https://pub.dev/packages/geolocator) - Localização em tempo real.
- [image_picker](https://pub.dev/packages/image_picker) - Captura de fotos.
- [intl](https://pub.dev/packages/intl) - Formatação de datas e horas.

## 📱 Como rodar o projeto

### Pré-requisitos
- Flutter SDK instalado e configurado.
- Dispositivo Android/iOS ou Emulador configurado.

### Passo a passo

1. **Clonar o repositório:**
   ```bash
   git clone https://github.com/AllanMicuanski/PEX-mobile.git
   ```

2. **Instalar dependências:**
   ```bash
   flutter pub get
   ```

3. **Permissões (Android):**
   O arquivo `AndroidManifest.xml` já possui as configurações necessárias para:
   - `ACCESS_FINE_LOCATION`
   - `ACCESS_COARSE_LOCATION`
   - `CAMERA`

4. **Executar o app:**
   ```bash
   flutter run
   ```

## 📝 Projeto Acadêmico
Este projeto foi desenvolvido como parte do **Projeto de Extensão** da disciplina de **Programação para Desenvolvimento para Dispositivos Móveis**.

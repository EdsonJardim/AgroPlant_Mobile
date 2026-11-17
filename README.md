# 🌱 AgroPlant Mobile

Aplicativo mobile desenvolvido em Flutter com o objetivo de auxiliar no gerenciamento e acompanhamento de propriedades agrícolas, oferecendo recursos de autenticação, informações meteorológicas, gerenciamento de preferências e notificações.

O AgroPlant busca reunir ferramentas úteis para facilitar o acompanhamento das propriedades rurais e contribuir para uma gestão agrícola mais organizada.

---

## 📱 Sobre o projeto

O **AgroPlant Mobile** é um aplicativo desenvolvido utilizando Flutter e Firebase, com integração a serviços externos para disponibilizar informações meteorológicas de acordo com a localização das propriedades cadastradas.

O projeto foi desenvolvido com foco em uma interface intuitiva, organização do código, armazenamento de dados em nuvem e compatibilidade com dispositivos Android e iOS.

## ✨ Funcionalidades implementadas

### 🔐 Autenticação e gerenciamento de usuários
- Cadastro de usuários com Firebase Authentication.
- Login com e-mail e senha.
- Autenticação com Google Sign-In.
- Recuperação de senha por e-mail utilizando Firebase Authentication.
- Logout da conta.
- Gerenciamento de provedores de autenticação.
- Gerenciamento das configurações de autenticação do usuário.

### 🌾 Propriedades agrícolas
- Funcionalidades de gerenciamento e acompanhamento de propriedades.
- Utilização de coordenadas geográficas associadas às propriedades.
- Integração da localização com os recursos meteorológicos.

### 🌦️ Informações meteorológicas
- Integração com a API Open-Meteo.
- Consulta de informações meteorológicas utilizando as coordenadas da propriedade.
- Exibição de informações climáticas.
- Apresentação de dados meteorológicos em gráficos.
- Interface adaptada ao tema claro e escuro.

### 👤 Perfil do usuário
- Tela de perfil.
- Exibição das informações da conta.
- Suporte à seleção de imagens utilizando Image Picker.
- Integração com Firebase Authentication.

### ⚙️ Configurações
- Gerenciamento das preferências do usuário.
- Ativação e desativação das notificações.
- Alternância entre tema claro e escuro.
- Persistência das preferências no Cloud Firestore.
- Acesso à recuperação de senha.
- Tela de suporte.
- Exibição do e-mail cadastrado.

### 🔔 Sistema de notificações
- Integração com Firebase Cloud Messaging (FCM).
- Solicitação de permissão para notificações.
- Geração e registro do token FCM do dispositivo.
- Armazenamento dos tokens no Cloud Firestore.
- Atualização automática do token quando necessário.
- Identificação da plataforma do dispositivo.
- Controle de ativação e desativação dos dispositivos.
- Integração com flutter_local_notifications para exibição de notificações locais.
- Configuração do canal Android `agroplant_alertas`.
- Recebimento de notificações com o aplicativo em segundo plano.

**Teste realizado:** envio de uma notificação pelo Firebase Console e recebimento confirmado no emulador Android.

---

## 🛠️ Tecnologias utilizadas

| Tecnologia | Aplicação |
|---|---|
| Flutter | Desenvolvimento mobile |
| Dart | Linguagem de programação |
| Firebase Authentication | Autenticação de usuários |
| Cloud Firestore | Armazenamento de dados |
| Firebase Cloud Messaging | Envio de notificações |
| Google Sign-In | Autenticação com Google |
| Open-Meteo API | Informações meteorológicas |
| Geolocator | Recursos de localização |
| Flutter Map | Exibição de mapas |
| LatLong2 | Coordenadas geográficas |
| FL Chart / gráficos | Visualização de dados meteorológicos |
| Image Picker | Seleção de imagens |
| Shared Preferences | Armazenamento local de preferências |
| HTTP | Requisições HTTP |
| Intl | Formatação de datas e informações |

## 🎨 Interface e identidade visual

O aplicativo utiliza uma identidade visual baseada em elementos relacionados ao agronegócio, com predominância das cores verde e bege.

**Paleta de cores:**

| Cor | Código |
|---|---|
| Verde principal | `#174D2A` |
| Verde secundário | `#78A878` |
| Bege | `#E8DCC6` |
| Bege claro | `#F7F2E8` |

O aplicativo possui suporte a tema claro e tema escuro, permitindo que o usuário escolha sua preferência.

---

## 🔥 Integração com Firebase

O projeto utiliza os seguintes serviços:

- **Firebase Authentication:** gerenciamento de contas e autenticação.
- **Cloud Firestore:** armazenamento das informações e preferências dos usuários.
- **Firebase Cloud Messaging:** gerenciamento e recebimento de notificações.

### Organização dos dados no Firestore

As configurações dos usuários são organizadas por meio de documentos associados ao identificador de autenticação.

Exemplo de organização:

```text
users/
 └── UID_DO_USUARIO/
      ├── configuracoes/
      │    ├── autenticacao
      │    └── preferencias
      │
      └── dispositivos/
           └── ID_DO_DISPOSITIVO/
                ├── token
                ├── plataforma
                ├── ativo
                └── atualizadoEm
```

As preferências de notificações são armazenadas em:

```text
users/{uid}/configuracoes/preferencias
```

Os dispositivos registrados para receber notificações são armazenados em:

```text
users/{uid}/dispositivos/{id}
```

---

## 📦 Dependências principais

As principais bibliotecas utilizadas no projeto incluem:

```yaml
firebase_core:
firebase_auth:
cloud_firestore:
firebase_messaging:
flutter_local_notifications:
google_sign_in:
shared_preferences:
image_picker:
flutter_svg:
geolocator:
flutter_map:
latlong2:
http:
intl:
```

As versões específicas estão definidas no arquivo `pubspec.yaml`.

---

## 💻 Como executar o projeto

### 1. Pré-requisitos

Antes de executar o projeto, é necessário possuir:

- Flutter SDK instalado.
- Dart SDK.
- Android Studio ou ambiente de desenvolvimento compatível.
- Emulador Android ou dispositivo físico.
- Conta e projeto configurados no Firebase.

### 2. Clonar o repositório

```bash
git clone URL_DO_REPOSITORIO
```

### 3. Entrar na pasta do projeto

```bash
cd AgroPlant-mobile
```

### 4. Instalar as dependências

```bash
flutter pub get
```

### 5. Configurar o Firebase

É necessário configurar o Firebase para o aplicativo, incluindo os arquivos de configuração correspondentes às plataformas utilizadas.

Para Android, disponibilizar o arquivo:

```text
android/app/google-services.json
```

O projeto também utiliza o arquivo:

```text
lib/firebase_options.dart
```

Esse arquivo contém as configurações geradas pelo FlutterFire CLI.

### 6. Executar o aplicativo

```bash
flutter run
```

### 7. Verificar o código

Para analisar o projeto e identificar possíveis problemas:

```bash
flutter analyze
```

---

## 📲 Configuração Android

O projeto possui configurações específicas para execução no Android, incluindo:

- Android Gradle Plugin.
- Kotlin.
- Java 17.
- Compile SDK 36.
- Core Library Desugaring.
- Configuração do Firebase.
- Permissões de localização.
- Permissão de notificações.
- Canal de notificações `agroplant_alertas`.

As configurações de compilação estão nos arquivos da pasta `android/`.

---

## 🔔 Situação atual das notificações

A integração com Firebase Cloud Messaging já foi implementada e testada no Android.

Atualmente, o aplicativo consegue registrar o dispositivo no Firestore e receber notificações enviadas pelo Firebase Console.

**Funcionalidades futuras:**
- Alertas meteorológicos automáticos.
- Avisos sobre mudanças climáticas.
- Lembretes automáticos de atividades agrícolas.
- Lembretes de cuidados com as plantações.

O envio automático desses alertas ainda depende da implementação de um serviço responsável por monitorar os eventos e disparar as mensagens.

---

## 🚧 Melhorias e próximas implementações

O AgroPlant continua em desenvolvimento. Entre as melhorias previstas estão:

- Implementação de lembretes automáticos de tarefas.
- Implementação de alertas meteorológicos automáticos.
- Evolução do sistema de notificações.
- Aprimoramento das funcionalidades de gerenciamento agrícola.
- Finalização e validação da configuração nativa para iOS.
- Melhorias gerais na interface e experiência do usuário.

---

## 👨‍💻 Desenvolvimento e os desenvolvidores do projeto

Projeto desenvolvido com Flutter e Firebase, com foco em soluções digitais para o agronegócio.

*EDSON EDUARDO SOARES JARDIM, *ANDRÉ LUIZ ALVES E *RAFAELA PEREIRA PAES 

**AgroPlant Mobile — Tecnologia a favor do campo!** 🌱

# 🌱 AgroPlant Mobile

Aplicativo desenvolvido em Flutter para gerenciamento agrícola, com integração ao Firebase e suporte para Android e Web.

## 🔗 Links do Projeto

- **Aplicativo Web:** [Acessar AgroPlant](https://agroplant2-2648d.web.app)
- **Repositório GitHub:** [AgroPlant Mobile](https://github.com/EdsonJardim/AgroPlant_Mobile.git)

## 📱 Sobre o Projeto

O AgroPlant é um aplicativo desenvolvido com Flutter, com o objetivo de oferecer recursos para gerenciamento de propriedades agrícolas, usuários, configurações e outras funcionalidades relacionadas ao ambiente rural.

---

## ✨ Funcionalidades implementadas

### 🔐 Autenticação e gerenciamento de usuários

- Cadastro de usuários com Firebase Authentication.
- Login com e-mail e senha.
- Autenticação com Google Sign-In.
- Recuperação de senha por e-mail utilizando Firebase Authentication.
- Logout da conta.
- Gerenciamento dos provedores de autenticação.
- Possibilidade de desativar, reativar ou excluir métodos de acesso vinculados.
- Gerenciamento das configurações de autenticação do usuário.

### 👥 Painel administrativo

O AgroPlant possui um painel administrativo com funcionalidades específicas para consulta de usuários, controle de contas e gerenciamento de administradores.

**Gerenciar usuários**

- Listagem dos usuários cadastrados.
- Pesquisa por nome ou e-mail.
- Consulta das informações dos usuários.
- Visualização do status de cada cadastro.
- Exibição dos dados de identificação do usuário.
- Consulta sem controles de ativação ou desativação de contas.

**Contas e acessos**

- Visualização da quantidade total de usuários.
- Contagem de contas ativas.
- Contagem de contas inativas.
- Filtro para visualizar todas as contas.
- Filtro para visualizar somente contas ativas.
- Filtro para visualizar somente contas inativas.
- Ativação de contas de usuários.
- Desativação de contas de usuários.
- Atualização da situação das contas.

**Administradores**

- Gerenciamento dos administradores da equipe.
- Cadastro de usuários como administradores.
- Ativação e desativação de administradores.
- Remoção de administradores da equipe.
- Identificação do administrador principal.
- Proteção contra desativação ou remoção do administrador principal.
- Controle de permissões de acordo com o perfil administrativo.

**Níveis de acesso administrativo:**

- **Super administrador:** responsável pelo gerenciamento da equipe administrativa e pelas operações administrativas com privilégios superiores.
- **Administrador da equipe:** possui acesso às funcionalidades administrativas permitidas pelas regras de segurança do projeto.

### 🌾 Propriedades agrícolas

- Funcionalidades de gerenciamento e acompanhamento de propriedades.
- Utilização de coordenadas geográficas associadas às propriedades.
- Exibição da localização das propriedades em mapas.
- Integração da localização com os recursos meteorológicos.

### 🌦️ Informações meteorológicas

- Integração com a API Open-Meteo.
- Consulta de informações meteorológicas utilizando as coordenadas da propriedade.
- Exibição de informações climáticas.
- Apresentação de dados meteorológicos em gráficos.
- Interface adaptada ao tema claro e escuro.

### 👤 Perfil do usuário

- Tela de perfil personalizada.
- Exibição das informações da conta.
- Edição do nome do usuário.
- Sincronização das informações do perfil com o Cloud Firestore.
- Seleção de imagem de perfil utilizando Image Picker.
- Remoção da imagem de perfil.
- Armazenamento local da imagem selecionada.
- Redefinição de senha por e-mail.
- Gerenciamento dos métodos de acesso vinculados.
- Opção de sair da conta.

### ⚙️ Configurações

- Gerenciamento das preferências do usuário.
- Ativação e desativação das notificações.
- Alternância entre tema claro e escuro.
- Persistência do tema selecionado utilizando Shared Preferences.
- Recuperação automática da preferência de tema ao iniciar o aplicativo.
- Manutenção do tema selecionado após encerrar e executar novamente o projeto, utilizando o mesmo armazenamento do navegador.
- Armazenamento das preferências de notificações no Cloud Firestore.
- Acesso à recuperação de senha.
- Tela de suporte.
- Exibição do e-mail cadastrado.

### 🎨 Tema claro e escuro

O AgroPlant possui dois modos de apresentação:

- **Tema claro:** utiliza predominantemente as cores verde, bege e branco.
- **Tema escuro:** utiliza tons de verde e superfícies escuras para proporcionar uma experiência visual adequada em ambientes com pouca iluminação.

O usuário pode alternar entre os temas diretamente na tela de Configurações.

A preferência é armazenada localmente por meio do pacote `Shared Preferences`, permitindo recuperar o tema escolhido quando o aplicativo é iniciado novamente.

No Flutter Web, os dados ficam associados ao armazenamento local da origem utilizada no navegador. Por isso, para manter a mesma preferência durante os testes, recomenda-se executar o projeto utilizando a mesma porta.

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
| Flutter | Desenvolvimento multiplataforma |
| Dart | Linguagem de programação |
| Flutter Web | Execução pelo navegador |
| Firebase Authentication | Autenticação de usuários |
| Cloud Firestore | Armazenamento de dados |
| Firebase Cloud Messaging | Envio de notificações |
| Google Sign-In | Autenticação com Google |
| Open-Meteo API | Informações meteorológicas |
| Geolocator | Recursos de localização |
| Flutter Map | Exibição de mapas |
| LatLong2 | Coordenadas geográficas |
| FL Chart | Visualização de dados meteorológicos |
| Image Picker | Seleção de imagens |
| Shared Preferences | Armazenamento local de preferências |
| HTTP | Requisições HTTP |
| Intl | Formatação de datas e informações |
| GoRouter | Gerenciamento de rotas e navegação |

---

## 🎨 Interface e identidade visual

O aplicativo utiliza uma identidade visual baseada em elementos relacionados ao agronegócio, com predominância das cores verde e bege.

**Paleta de cores:**

| Cor | Código |
|---|---|
| Verde principal | `#174D2A` |
| Verde secundário | `#78A878` |
| Bege | `#E8DCC6` |
| Bege claro | `#F7F2E8` |
| Fundo escuro | `#121A14` |
| Superfície escura | `#202B23` |
| Campos no tema escuro | `#29372D` |

O aplicativo possui suporte a tema claro e tema escuro, permitindo que o usuário escolha sua preferência.

As telas administrativas também acompanham o tema selecionado, proporcionando uma experiência visual consistente em todo o aplicativo.

---

## 🔥 Integração com Firebase

O projeto utiliza os seguintes serviços:

- **Firebase Authentication:** gerenciamento de contas e autenticação.
- **Cloud Firestore:** armazenamento das informações, preferências, dados administrativos e registros dos dispositivos.
- **Firebase Cloud Messaging:** gerenciamento e recebimento de notificações.

### Organização dos dados no Firestore

As configurações dos usuários são organizadas por meio de documentos associados ao identificador de autenticação.

**Dados privados dos usuários:**

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

**Diretório público de usuários:**

```text
users_public/
 └── UID_DO_USUARIO/
      ├── nome
      ├── email
      ├── criadoEm
      └── atualizadoEm
```

**Administradores:**

```text
admins/
 └── UID_DO_ADMINISTRADOR/
      ├── nome
      ├── email
      ├── role
      └── ativo
```

Os perfis administrativos utilizam os campos `role` e `ativo` para identificar o nível de acesso e a situação do administrador.

**Controle de situação das contas:**

```text
account_status/
 └── UID_DO_USUARIO/
      ├── ativo
      └── atualizadoEm
```

**Preferências de notificações:**

```text
users/{uid}/configuracoes/preferencias
```

**Dispositivos registrados para receber notificações:**

```text
users/{uid}/dispositivos/{id}
```

As operações administrativas são protegidas por regras de segurança do Cloud Firestore, respeitando os níveis de acesso definidos no projeto.

**Observação:** a preferência do tema claro ou escuro é armazenada localmente pelo Shared Preferences, não no Cloud Firestore.

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
go_router:
fl_chart:
```

As versões específicas estão definidas no arquivo `pubspec.yaml`.

---

## 💻 Como executar o projeto

### 1. Pré-requisitos

Antes de executar o projeto, é necessário possuir:

- Flutter SDK instalado.
- Dart SDK.
- Android Studio ou ambiente de desenvolvimento compatível.
- Google Chrome para execução Web.
- Emulador Android ou dispositivo físico, caso deseje executar a versão mobile.
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

### 6. Executar no Android

Para executar o aplicativo em um dispositivo ou emulador Android:

```bash
flutter run
```

### 7. Executar no Flutter Web

Para executar o AgroPlant no navegador Google Chrome:

```bash
flutter run -d chrome --web-port 5000
```

O aplicativo será disponibilizado em:

```text
http://localhost:5000
```

**Importante:** recomenda-se utilizar a mesma porta nas execuções seguintes para manter o acesso ao mesmo armazenamento local do navegador, incluindo a preferência do tema.

### 8. Verificar o código

Para analisar o projeto e identificar possíveis problemas:

```bash
flutter analyze
```

---

## 🌐 Suporte ao Flutter Web

O AgroPlant também está disponível na versão Web, podendo ser acessado diretamente pelo navegador, sem necessidade de um emulador Android.

**Acesse o aplicativo:** [AgroPlant Web](https://agroplant2-2648d.web.app)

Essa modalidade permite acessar as funcionalidades disponíveis na versão Web sem depender de um emulador Android.

Entre os recursos disponíveis estão:

- Navegação entre as telas.
- Autenticação de usuários.
- Integração com Firebase.
- Gerenciamento de usuários e administração.
- Configurações do aplicativo.
- Alternância entre tema claro e escuro.
- Persistência local da preferência de tema.
- Acesso aos recursos meteorológicos e de localização, conforme as permissões e compatibilidade do navegador.

Alguns recursos nativos podem apresentar diferenças de comportamento entre Android e Web, dependendo das APIs e permissões disponíveis em cada plataforma.

**Hospedagem:** Firebase Hosting.

**URL pública:** https://agroplant2-2648d.web.app

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

## 👨‍💻 Desenvolvimento e desenvolvedores do projeto

Projeto desenvolvido com Flutter e Firebase, com foco em soluções digitais para o agronegócio.

**Desenvolvedores:**

- Edson Eduardo Soares Jardim
- André Luis Alves
- Rafaela Paes Pereira

**AgroPlant Mobile — Tecnologia a favor do campo!** 🌱
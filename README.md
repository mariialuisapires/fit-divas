# FitDivas

Aplicativo de fitness focado em mulheres, com acompanhamento de treinos, metas de peso, controle de água, desafios e assistente de IA.

## Tecnologias

| Camada | Stack |
|---|---|
| Mobile | Flutter (Dart), Provider, GoRouter |
| Backend | ASP.NET Core .NET 10, EF Core, JWT |
| Banco de dados | PostgreSQL |
| Notificações | Firebase Cloud Messaging |
| Admin Panel | HTML + Tailwind CSS (vanilla JS) |

## Funcionalidades

- Cadastro e login com autenticação JWT
- Onboarding com criação automática de meta de peso
- Registro e histórico de treinos
- Controle de ingestão de água diária
- Metas de peso com gráfico de evolução
- Desafios fitness
- Calendário de treinos
- Assistente de IA
- Perfil com exclusão de conta
- Painel administrativo web (gestão de usuários, dashboard)

## Estrutura do projeto

```
fit-divas/
├── frontend/          # App Flutter
├── backend/
│   ├── FitDivas.API           # Controllers, Middleware, Program.cs
│   ├── FitDivas.Application   # Services, DTOs, Interfaces
│   ├── FitDivas.Domain        # Entidades
│   └── FitDivas.Infrastructure # Repositórios, EF Core, Migrations
└── admin-panel/
    └── index.html     # Painel admin standalone
```

## Como rodar

### Pré-requisitos

- [.NET 10 SDK](https://dotnet.microsoft.com/download)
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [PostgreSQL](https://www.postgresql.org/)

### Backend

1. Configure a connection string em `backend/FitDivas.API/appsettings.json`:
   ```json
   "ConnectionStrings": {
     "DefaultConnection": "Host=localhost;Database=fitdivas;Username=postgres;Password=SUA_SENHA"
   }
   ```

2. Rode o servidor:
   ```bash
   cd backend/FitDivas.API
   dotnet run
   ```
   O servidor sobe em `http://localhost:5226`. As migrations são aplicadas automaticamente na inicialização.

3. O usuário admin é criado automaticamente:
   - **Email:** `admin@fitdivas.com`
   - **Senha:** `Admin@2026!`

### Frontend

```bash
cd frontend
flutter pub get
flutter run
```

### Painel Admin

Abra `admin-panel/index.html` diretamente no navegador com o backend rodando.

## Variáveis de configuração

Todas em `backend/FitDivas.API/appsettings.json`:

| Chave | Descrição |
|---|---|
| `ConnectionStrings:DefaultConnection` | String de conexão PostgreSQL |
| `Jwt:Key` | Chave secreta JWT (mínimo 32 caracteres) |
| `Admin:Email` | E-mail do admin inicial |
| `Admin:Senha` | Senha do admin inicial |
| `Anthropic:ApiKey` | Chave da API Anthropic (assistente IA) |
| `Firebase:CredentialPath` | Caminho para o arquivo de credenciais Firebase |

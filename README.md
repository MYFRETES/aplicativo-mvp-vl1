# MyFretes — Base Inicial do MVP (v1)

> **Este repositório contém a base inicial do MVP do aplicativo MyFretes.**
> Trata-se do ponto de partida para o desenvolvimento do produto — splash,
> boas-vindas, login, cadastro, home cliente e home motorista integrados ao Supabase.

---

## Visão Geral

O **MyFretes** é um aplicativo Flutter para intermediação de fretes entre
clientes e motoristas.

| Funcionalidade | Status |
|---|---|
| Splash screen | ✅ |
| Tela de boas-vindas | ✅ |
| Cadastro (cliente / motorista) | ✅ |
| Login com Supabase | ✅ |
| Home cliente | ✅ base |
| Home motorista | ✅ base |
| Formulário de frete em etapas | 🔜 próxima sprint |

---

## Fluxo de Autenticação

```
Splash → Boas-vindas → Cadastro → Login (com mensagem de sucesso) → Home
```

### Cadastro
Após um cadastro bem-sucedido o app **não** redireciona diretamente para a home.
O usuário é encaminhado para a tela de **login** com uma mensagem orientando-o
a verificar o e-mail (quando aplicável) e realizar o login normalmente.
Isso evita falhas causadas por timing de sessão ou confirmação de e-mail no Supabase.

---

## Configuração do Supabase

### 1. Variáveis de ambiente

Em `lib/main.dart`, substitua os placeholders pelos valores reais do seu projeto:

```dart
await Supabase.initialize(
  url: 'SUA_SUPABASE_URL',
  anonKey: 'SUA_SUPABASE_ANON_KEY',
);
```

> 💡 Em produção, use variáveis de ambiente ou um arquivo `.env` não versionado.

### 2. Criação automática de `profiles` via Trigger SQL ⭐ (recomendado)

A estratégia preferida para criar registros na tabela `profiles` é um
**trigger SQL no Supabase**, acionado logo após a inserção em `auth.users`.
Isso elimina a dependência do cliente para a criação do perfil e torna o
fluxo muito mais robusto.

**Como configurar:**

1. Acesse o painel do Supabase → **Database → SQL Editor → New Query**
2. Cole e execute o conteúdo de
   [`supabase/migrations/20240101000000_create_profiles_trigger.sql`](supabase/migrations/20240101000000_create_profiles_trigger.sql)

O script cria:
- A tabela `public.profiles` (com RLS habilitado)
- A função `handle_new_user()` que preenche o profile com os metadados enviados no `signUp`
- O trigger `on_auth_user_created` em `auth.users`

#### Fallback no cliente

Caso o trigger ainda não esteja configurado, o `AuthService` tenta um
`upsert` em `profiles` logo após o `signUp`. Essa chamada é silenciosa
em caso de falha — o trigger é o mecanismo principal.

### 3. Esquema esperado da tabela `profiles`

| Coluna | Tipo | Descrição |
|---|---|---|
| `id` | `uuid` (PK) | Mesmo ID do `auth.users` |
| `email` | `text` | E-mail do usuário |
| `nome_completo` | `text` | Nome informado no cadastro |
| `telefone` | `text` | Telefone com máscara |
| `perfil` | `text` | `'cliente'` ou `'motorista'` |
| `criado_em` | `timestamptz` | Data de criação |

---

## Estrutura do Projeto

```
lib/
  main.dart
  app/
    app_widget.dart
    routes/
      app_router.dart
      route_names.dart
    theme/
      app_colors.dart
      app_theme.dart
  core/
    constants/
      app_strings.dart
  features/
    splash/
      presentation/pages/splash_page.dart
    auth/
      data/auth_service.dart
      presentation/
        controllers/auth_controller.dart
        pages/
          welcome_page.dart
          login_page.dart
          register_page.dart
    home/
      cliente/
        presentation/pages/home_cliente_page.dart
      motorista/
        presentation/pages/home_motorista_page.dart
supabase/
  migrations/
    20240101000000_create_profiles_trigger.sql
```

---

## Como Executar

```bash
# 1. Instale as dependências
flutter pub get

# 2. Execute o app (com emulador ou dispositivo conectado)
flutter run
```

---

## Tecnologias

- [Flutter](https://flutter.dev) 3.x (SDK ≥ 3.3)
- [Supabase Flutter](https://pub.dev/packages/supabase_flutter) ^2.8
- [go_router](https://pub.dev/packages/go_router) ^14
- [Google Fonts — Poppins](https://pub.dev/packages/google_fonts)
- [mask_text_input_formatter](https://pub.dev/packages/mask_text_input_formatter)

---

## Próximos Passos

- [ ] Formulário de solicitação de frete em etapas (cliente)
- [ ] Painel de fretes disponíveis (motorista)
- [ ] Notificações push

---

© 2025–2026 MyFretes. Todos os direitos reservados.
# MyFretes — MVP v1 + BLOCO 3

> **Este repositório contém a base do MVP do aplicativo MyFretes** com o fluxo
> completo de solicitação de frete pelo cliente (BLOCO 3).

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
| Home cliente | ✅ |
| Home motorista | ✅ base |
| Formulário de frete em etapas (BLOCO 3) | ✅ |
| Lista de fretes / propostas | 🔜 próxima sprint |

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

## BLOCO 3 — Formulário de Frete em Etapas

### Fluxo
A partir da home do cliente, o botão **"Novo frete"** abre um formulário
multi-etapas com navegação e validação por etapa:

| # | Etapa | Campos principais |
|---|---|---|
| 1 | Dados iniciais | título, descrição, data desejada, período |
| 2 | Origem | CEP, endereço, número, complemento, bairro, cidade, UF, referência |
| 3 | Paradas | zero ou várias paradas intermediárias (estrutura igual à origem) |
| 4 | Destino | mesmos campos da origem |
| 5 | Itens | lista dinâmica: nome, quantidade, categoria, observação |
| 6 | Apoio de carga | ajudantes, desmontagem/montagem, embalagem, observações |
| 7 | Revisão | resumo completo + botão de confirmação |

### Persistência no Supabase
Execute a migration abaixo para criar as tabelas e políticas RLS:

```
supabase/migrations/20250410000000_create_fretes.sql
```

**Tabelas criadas:**

| Tabela | Descrição |
|---|---|
| `fretes` | Dados principais da solicitação |
| `frete_paradas` | Paradas intermediárias (FK → fretes) |
| `frete_itens` | Itens transportados (FK → fretes) |

**Como aplicar:**
1. Acesse o painel do Supabase → **Database → SQL Editor → New Query**
2. Cole e execute o conteúdo de `supabase/migrations/20250410000000_create_fretes.sql`

> RLS está habilitado em todas as tabelas. O cliente só pode inserir e ler
> os próprios registros.

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

**Como configurar:**

1. Acesse o painel do Supabase → **Database → SQL Editor → New Query**
2. Cole e execute o conteúdo de
   [`supabase/migrations/20240101000000_create_profiles_trigger.sql`](supabase/migrations/20240101000000_create_profiles_trigger.sql)

O script cria:
- A tabela `public.profiles` (com RLS habilitado)
- A função `handle_new_user()` que preenche o profile com os metadados enviados no `signUp`
- O trigger `on_auth_user_created` em `auth.users`

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
    customer/                              ← BLOCO 3
      presentation/
        controllers/novo_frete_controller.dart
        pages/novo_frete_page.dart
        widgets/
          step_indicator.dart
          endereco_form_fields.dart
          etapa_dados_iniciais.dart
          etapa_origem.dart
          etapa_paradas.dart
          etapa_destino.dart
          etapa_itens.dart
          etapa_ajudantes.dart
          etapa_revisao.dart
    home/
      cliente/
        presentation/pages/home_cliente_page.dart
      motorista/
        presentation/pages/home_motorista_page.dart
  shared/
    services/
      frete_service.dart                   ← BLOCO 3
supabase/
  migrations/
    20240101000000_create_profiles_trigger.sql
    20250410000000_create_fretes.sql       ← BLOCO 3
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
- [intl](https://pub.dev/packages/intl) ^0.20

---

## Próximos Passos

- [x] Formulário de solicitação de frete em etapas (cliente)
- [ ] Lista de fretes do cliente (com status)
- [ ] Painel de fretes disponíveis (motorista)
- [ ] Sistema de propostas
- [ ] Notificações push

---

© 2025–2026 MyFretes. Todos os direitos reservados.
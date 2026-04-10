# MyFretes — MVP v1

> **Este repositório contém o MVP do aplicativo MyFretes.**
> Base inicial + formulário de solicitação de frete em etapas para o cliente.

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
| Formulário de frete em etapas | ✅ |

---

## Fluxo do Cliente — Novo Frete

```
Home Cliente → Novo Frete → [7 etapas] → Confirmar → Supabase
```

### Etapas do formulário

| # | Etapa | Campos principais |
|---|---|---|
| 1 | Dados iniciais | título, descrição, data desejada, período |
| 2 | Origem | CEP, endereço, número, bairro, cidade, UF, referência |
| 3 | Paradas | zero ou mais endereços intermediários |
| 4 | Destino | mesmos campos da origem |
| 5 | Itens | nome, quantidade, categoria, observação |
| 6 | Ajudantes | quantidade, montagem/desmontagem, embalagem |
| 7 | Revisão | resumo completo + confirmar envio |

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

### 2. Migration: profiles (trigger)

Execute no SQL Editor do Supabase:

```
supabase/migrations/20240101000000_create_profiles_trigger.sql
```

Cria a tabela `profiles`, a função `handle_new_user()` e o trigger
`on_auth_user_created` em `auth.users`.

### 3. Migration: fretes ⭐

Execute no SQL Editor do Supabase:

```
supabase/migrations/20260410000001_create_fretes.sql
```

Cria as tabelas:

| Tabela | Descrição |
|---|---|
| `fretes` | Solicitação principal com dados de origem, destino e ajudantes |
| `frete_paradas` | Paradas intermediárias vinculadas ao frete |
| `frete_itens` | Itens de carga vinculados ao frete |

Todas as tabelas têm **RLS habilitado**:
- O cliente autenticado pode **inserir** e **ler** apenas os próprios dados.
- As tabelas filhas (`frete_paradas`, `frete_itens`) verificam a posse via
  `JOIN` com `fretes`, garantindo que o cliente só acesse dados do próprio frete.

#### Esquema de `fretes`

| Coluna | Tipo | Descrição |
|---|---|---|
| `id` | `uuid` (PK) | Gerado automaticamente |
| `cliente_id` | `uuid` | FK → `auth.users` |
| `status` | `text` | `aberto` \| `aceito` \| `em_andamento` \| `concluido` \| `cancelado` |
| `titulo` | `text` | Opcional |
| `descricao` | `text` | Opcional |
| `data_desejada` | `date` | Data de coleta desejada |
| `periodo` | `text` | Opcional (ex.: "manhã") |
| `origem_*` | vários | Campos do endereço de origem |
| `destino_*` | vários | Campos do endereço de destino |
| `qtd_ajudantes` | `int` | Padrão 0 |
| `precisa_montagem` | `bool` | Padrão false |
| `precisa_embalagem` | `bool` | Padrão false |
| `obs_ajudantes` | `text` | Opcional |
| `criado_em` | `timestamptz` | Preenchido automaticamente |

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
  shared/
    models/
      frete_models.dart          ← FreteEnderecoData, FreteItemData
    services/
      frete_service.dart         ← persistência no Supabase
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
    customer/
      presentation/
        controllers/
          novo_frete_controller.dart   ← estado do formulário (ChangeNotifier)
        pages/
          novo_frete_page.dart         ← formulário em 7 etapas
supabase/
  migrations/
    20240101000000_create_profiles_trigger.sql
    20260410000001_create_fretes.sql
```

---

## Como Executar

```bash
# 1. Instale as dependências
flutter pub get

# 2. Configure o Supabase (veja seção acima)

# 3. Execute o app (com emulador ou dispositivo conectado)
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

- [ ] Painel de fretes disponíveis (motorista)
- [ ] Aceite de frete pelo motorista
- [ ] Notificações push
- [ ] Listagem de fretes do cliente

---

© 2025–2026 MyFretes. Todos os direitos reservados.
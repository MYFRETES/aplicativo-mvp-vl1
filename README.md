# MyFretes — App MVP v1

App Flutter para conectar **clientes** e **motoristas de frete**, inspirado no site [myfretes.com.br](https://myfretes.com.br).  
Funciona em **Android** e **iOS**, com backend via **Supabase**.

---

## 📋 Telas iniciais do MVP

| Tela | Arquivo | Descrição |
|------|---------|-----------|
| Splash | `lib/features/splash/presentation/pages/splash_page.dart` | Animação de carregamento e verificação de sessão |
| Boas-vindas | `lib/features/auth/presentation/pages/welcome_page.dart` | Escolha de perfil (Cliente ou Motorista) |
| Login | `lib/features/auth/presentation/pages/login_page.dart` | Login com e-mail e senha |
| Cadastro | `lib/features/auth/presentation/pages/register_page.dart` | Cadastro com nome, telefone, e-mail, senha e role |
| Home do Cliente | `lib/features/customer/presentation/pages/customer_home_page.dart` | Lista de pedidos e botão de novo frete |
| Home do Motorista | `lib/features/driver/presentation/pages/driver_home_page.dart` | Lista de fretes disponíveis e histórico |

---

## ⚙️ Configuração do Supabase

1. Acesse [app.supabase.com](https://app.supabase.com) e crie ou acesse seu projeto.
2. Vá em **Settings → API** e copie:
   - **Project URL** → `SUPABASE_URL`
   - **anon / public key** → `SUPABASE_ANON_KEY`
3. Abra o arquivo `lib/main.dart` e substitua os placeholders:

```dart
const _supabaseUrl = 'SUA_SUPABASE_URL';       // ← cole aqui a URL do projeto
const _supabaseAnonKey = 'SUA_SUPABASE_ANON_KEY'; // ← cole aqui a anon key
```

> ⚠️ **Nunca** commite credenciais reais no repositório.  
> Para produção, use variáveis de ambiente ou um pacote como `flutter_dotenv`.

### Tabela `profiles` no Supabase

Execute o SQL abaixo no **SQL Editor** do seu projeto Supabase para criar a tabela de perfis:

```sql
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  nome text not null,
  telefone text,
  email text,
  role text check (role in ('cliente', 'motorista')) not null,
  criado_em timestamptz default now()
);

-- Habilitar RLS
alter table public.profiles enable row level security;

-- Política: usuário vê e edita apenas o próprio perfil
create policy "Usuário pode ver o próprio perfil"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Usuário pode atualizar o próprio perfil"
  on public.profiles for update
  using (auth.uid() = id);

create policy "Usuário pode inserir o próprio perfil"
  on public.profiles for insert
  with check (auth.uid() = id);
```

---

## 🚀 Como rodar o projeto

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.0
- Android Studio ou Xcode (para emuladores)
- Conta no [Supabase](https://supabase.com)

### Passos

```bash
# 1. Clone o repositório
git clone https://github.com/MYFRETES/aplicativo-mvp-vl1.git
cd aplicativo-mvp-vl1

# 2. Configure as credenciais do Supabase em lib/main.dart

# 3. Instale as dependências
flutter pub get

# 4. Rode o app
flutter run
```

Para rodar em modo release:

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 🗂️ Estrutura de pastas

```
lib/
├── app/
│   ├── app_widget.dart          # Widget raiz do app
│   ├── routes/
│   │   ├── app_router.dart      # Configuração de rotas (go_router)
│   │   └── route_names.dart     # Nomes/paths das rotas
│   └── theme/
│       ├── app_colors.dart      # Paleta de cores
│       └── app_theme.dart       # ThemeData do app
├── core/
│   └── constants/
│       └── app_strings.dart     # Textos e strings (PT-BR)
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── auth_controller.dart
│   │       └── pages/
│   │           ├── welcome_page.dart
│   │           ├── login_page.dart
│   │           └── register_page.dart
│   ├── customer/
│   │   └── presentation/pages/
│   │       └── customer_home_page.dart
│   ├── driver/
│   │   └── presentation/pages/
│   │       └── driver_home_page.dart
│   └── splash/
│       └── presentation/pages/
│           └── splash_page.dart
├── shared/
│   └── services/
│       ├── supabase_client.dart  # Acesso global ao SupabaseClient
│       └── auth_service.dart     # Serviço de autenticação
└── main.dart                     # Ponto de entrada
```

---

## 🛠️ Dependências principais

| Pacote | Versão | Uso |
|--------|--------|-----|
| `go_router` | ^13.2.0 | Navegação declarativa |
| `google_fonts` | ^6.2.1 | Tipografia (Inter) |
| `supabase_flutter` | ^2.3.4 | Backend / Auth / DB |
| `mask_text_input_formatter` | ^2.9.0 | Máscara de telefone |
| `intl` | ^0.19.0 | Formatação de datas/números |

---

## 🗺️ Próximos passos

- [ ] Formulário de frete em etapas (cliente)
- [ ] Lista de fretes disponíveis com dados reais (motorista)
- [ ] Chat em tempo real (Supabase Realtime)
- [ ] Push notifications (Firebase Cloud Messaging)
- [ ] Propostas e negociação de frete
- [ ] Perfil completo do motorista (veículo, CNH)
- [ ] Histórico de fretes

---

## 📄 Licença

Proprietário — MyFretes © 2024
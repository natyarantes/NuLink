#NuLink
======

Pequeno app de **encurtador de URLs** feito para **um teste de processo seletivo**.\
Arquitetura **MVVM**, camadas separadas e cobertura de testes (Xcode) **87%**.

-   **Xcode:** 26.0.1

-   **iOS mínimo:** 17.6

-   **Gerenciador de dependências:** **CocoaPods**

-   **Backend:** `https://url-shortener-server.onrender.com/api/alias` (`POST {"url":"<string>"}`)

* * * * *

🧰 Pré-requisitos
-----------------

1.  **CocoaPods**

    -   via RubyGems:

        `sudo gem install cocoapods`

    -   ou via Homebrew:

        `brew install cocoapods`

2.  **Xcode 26.0.1** (ou mais novo compatível)

3.  Simulador/dispositivo com **iOS 17.6+**

> Se já tem o CocoaPods instalado, pode pular para **Instalação**.

* * * * *

🚀 Instalação
-------------

1.  No diretório do projeto, instale os pods:

    `cd NuLink
    pod install`

    Se necessário:

    `pod repo update
    pod install`

2.  **Abra SEMPRE** o workspace gerado:

    `open NuLink.xcworkspace`

3.  Selecione um simulador **iOS 17.6+** e rode:

    -   `⌘R` para executar o app

    -   `⌘U` para rodar os testes

* * * * *

🧭 Como usar
------------

1.  Cole/digite uma URL.

2.  Toque em **"Encurtar link"**.

3.  Um card aparece com:

    -   **link curto** (tocável/abrível),

    -   **link original**,

    -   ações **Copiar** e **Abrir**.

* * * * *

🧱 Arquitetura e Pastas
-----------------------

Este projeto adota **MVVM com SwiftUI** — tema da minha **tese de MBA** — por alinhar a UI declarativa a um **fluxo de dados unidirecional** e um **único estado-fonte** no ViewModel. A separação **View / ViewModel** melhora a **testabilidade** (mocks e injeção de dependências), a **previsibilidade do estado** (`@Published`) e a **manutenibilidade**, além de facilitar **SwiftUI Previews** e a evolução do código com baixo acoplamento.


<img width="565" height="781" alt="nulink_tree" src="https://github.com/user-attachments/assets/83af834d-055b-4d93-8ff4-5018b9bf7e9f" />


**Fluxo:** `View` → `ViewModel` → `Repository` → `API/HTTPClient`\
**Dados:** API → **DTO** → **Mapper** → `ShortLink` (domínio) → ViewModel → View.

* * * * *

🌐 API
------

**Request**

`POST /api/alias
Content-Type: application/json; charset=utf-8
Accept: application/json

{ "url": "<string>" }`

**Response (2xx)**

`{
  "alias": "<url alias>",
  "_links": { "self": "<original url>", "short": "<short url>" }
}`

**Erros tratados:** `requestFailed(status:body:)`, `transport(_:)`, `encoding(_:)`, `decoding(_:)`.

* * * * *

🧪 Testes
---------

### Unit Tests (XCTest)

-   Rode com `⌘U` (Scheme **NuLink**).

-   Para cobertura: **Edit Scheme → Test → Gather coverage for all targets** e rode `⌘U`.

-   **Cobertura atual:** **87%** (reportado pelo Xcode).

**Cobertura principal:**

-   Networking: `URLSessionHTTPClient`, `Endpoint`, `URLShortenerAPI`

-   Repositório/Mapeamento: `RemoteURLShorteningRepository`, `ShortenMapper`, DTOs

-   Domínio/Validação: `URLValidation`

-   Apresentação: `ShortenerViewModel` (fluxo feliz, erros, loading, reset)

### UI Tests (XCUITest)

Os testes de UI usam dublês de repositório **somente em DEBUG**, controlados por variáveis de ambiente:

-   O `NuLinkApp` detecta:

    -   `UI_TESTING=1`

    -   `UI_TEST_SCENARIO=success | delayedSuccess | requestFailed | decoding`

Os testes setam isso automaticamente (via `launchEnvironment`).\
Para rodar manualmente: selecione o target **NuLinkUITests** e `⌘U`.

* * * * *

🛣️ Roadmap / Melhorias Futuras
-------------------------------

-   **Confirmação antes de "Limpar tudo"** (exibir `confirmationDialog` antes de `reset()`).

-   **Persistência do histórico** (UserDefaults/CoreData/SQLite) para manter links após fechar o app.

-   **Snapshot tests** (ex.: `swift-snapshot-testing`) para validar UI (light/dark, Dynamic Type).

-   Internacionalização (`Localizable.strings`) e revisão de Acessibilidade.

- **Estressar testes de usabilidade** com voice over, contraste, etc.

* * * * *

❓Dicas de troubleshooting
-------------------------

-   **Abra o `.xcworkspace`**, não o `.xcodeproj`.

-   Se o CocoaPods reclamar:

    `pod repo update
    pod install`

-   Limpe o build (`⌘⇧K`) e tente novamente.

-   Garanta que o simulador é **iOS 17.6+**.

* * * * *

# Design System — Componentes Visuais

Este projeto possui um pequeno **Design System** para padronizar cores, tipografia e espaçamento entre telas e features.

## Visão geral

- **Tokens (fundação):**
  - `DSColors` (acessado como `DS.*`): paleta de **Cores** para texto, fundo e destaques.
  - `DSType`: **Tipografia** (títulos, corpo, legenda).
  - `DSMetrics`: **Espaçamento**, cantos e tamanhos.
- **Componentes (UI):**
  - `NuPrimaryButtonStyle`: estilo de botão principal (call-to-action).
  - `NuCard`: contêiner com fundo, canto arredondado e sombra sutil.
  - `nuField()`: modificador para campos de texto.
  - `ToastModifier` (utilitário local à view): feedback leve “copiado”.

> **Motivação**  
> Centralizar tokens e componentes mínimos mantém consistência visual, acelera a criação de telas e facilita futuras trocas de tema (ex.: dark mode).

---

## Tokens (Fundação)

### Cores (DS / DSColor)

A paleta utiliza **cores do sistema** (dinâmicas para Light/Dark) e **cores de marca** (roxo) derivadas de `hex`.  
Use **sempre os tokens semânticos** (`DS.*`) nas telas — evite `Color(...)` direto.

---

#### Paleta base (`DSColor`)

| Token              | Valor (Light) | Dinâmico (Light/Dark) | Observações                         |
|--------------------|---------------|------------------------|-------------------------------------|
| `purple`           | `#820AD1`     | Não                    | Cor de marca (accent principal)     |
| `purpleDark`       | `#5E0AA3`     | Não                    | Variante para estado “pressed”      |
| `purpleLight`      | `#B877FF`     | Não                    | Variante sutil/decorativa           |
| `background`       | `systemBackground` | **Sim**           | Fundo da tela                       |
| `surface`          | `secondarySystemBackground` | **Sim** | Fundo de cards/superfícies          |
| `textPrimary`      | `label`       | **Sim**                | Texto principal                     |
| `textSecondary`    | `secondaryLabel` | **Sim**             | Texto secundário/auxiliar           |

> A extensão `Color(hex:)` cria cores **sRGB** com opacidade opcional (`alpha`), ex.: `Color(hex: 0x820AD1, alpha: 0.9)`.

---

### Métricas (DSMetrics)

> Todos os valores estão em **points** (pt), exceto `shadowOpacity` (unitário 0–1).

| Token                | Valor | Tipo     | Uso típico                                |
|---------------------|:-----:|----------|-------------------------------------------|
| `radiusS`           |  8    | CGFloat  | Canto pequeno (chips, campos compactos)   |
| `radiusM`           |  12   | CGFloat  | Canto padrão (cards, botões principais)   |
| `paddingS`          |  8    | CGFloat  | Espaçamento interno/entre itens pequeno   |
| `paddingM`          |  12   | CGFloat  | Espaçamento interno/entre itens médio     |
| `paddingL`          |  16   | CGFloat  | Espaçamento interno/entre blocos maior    |
| `shadowRadius`      |  6    | CGFloat  | Raio da sombra de elevação sutil          |
| `shadowOpacity`     | 0.08  | Double   | Opacidade da sombra (0–1)                 |

**Exemplos**
```swift
VStack(spacing: DSMetrics.paddingM) {
    // …
}
.padding(.horizontal, DSMetrics.paddingL)

NuCard {
    // …
}
.cornerRadius(DSMetrics.radiusM)
.shadow(color: .black.opacity(DSMetrics.shadowOpacity),
        radius: DSMetrics.shadowRadius, x: 0, y: 2)


---

## Componentes

### 1) `NuPrimaryButtonStyle`

Botão de ação principal do app.

```swift
Button("Encurtar link") { /* action */ }
.buttonStyle(NuPrimaryButtonStyle())
.disabled(isDisabled)
```

### 2) NuCard
Contêiner para trechos de informação (ex.: resultado do encurtador).
```swift
NuCard {
    VStack(alignment: .leading, spacing: 8) {
        Text(shortURL).font(.headline).foregroundStyle(DS.Accent.primary)
        Text(originalURL).font(DSType.body).foregroundStyle(DS.Text.secondary)
        // Ações internas...
    }
}
```

### 3) nuField() (TextField style)
Modificador de TextField para borda, preenchimento e foco consistentes.
```swift
TextField("https://exemplo.com", text: $vm.inputURL)
    .keyboardType(.URL)
    .textInputAutocapitalization(.never)
    .autocorrectionDisabled(true)
    .nuField()
```
* * * * * 
Feito em Swift/SwiftUI 💜 

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

Arquitetura **MVVM** com separação de camadas (Presentation / Data).

`NuLink/
├─ App/
│  └─ NuLinkApp.swift                         # composição de dependências (produção e UI Tests)
├─ Presentation/
│  ├─ ShortenerView.swift                     # UI (SwiftUI)
│  └─ ShortenerViewModel.swift                # estado + orquestração
├─ Data/
│  ├─ Networking/
│  │  ├─ NetworkError.swift                   # erros de rede tipados
│  │  ├─ Endpoint.swift                       # builder de URLRequest
│  │  ├─ URLSessionHTTPClient.swift           # cliente HTTP genérico (URLSession)
│  │  └─ URLShortenerAPI.swift                # chamada /api/alias
│  ├─ Repositories/
│  │  ├─ ShortenResponseDTO.swift             # DTOs (Decodable)
│  │  ├─ ShortenMapper.swift                  # DTO → domínio
│  │  ├─ URLShorteningRepository.swift        # protocolo + entidade ShortLink
│  │  └─ RemoteURLShorteningRepository.swift  # repo remoto
│  ├─ Validation/
│  │  └─ URLValidation.swift                  # sanitização de entrada
│  └─ UITestDoubles.swift (DEBUG)             # dublês para UI Tests (cenários previsíveis)
├─ NuLinkTests/                               # Unit tests (XCTest)
└─ NuLinkUITests/                             # UI Tests (XCUITest)`

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

Feito em Swift/SwiftUI 💜 

# Think Locally

> Your mind. Your machine. No cloud required.

A native macOS app to explore everything Apple Intelligence can do on-device. Chat, generate images, prototype structured output, test tool calling — all running on the Neural Engine. Zero API keys. Zero cost. Zero data leaving your Mac.

![macOS 26+](https://img.shields.io/badge/macOS-26%2B-blue)
![Swift 6](https://img.shields.io/badge/Swift-6-orange)
![License MIT](https://img.shields.io/badge/License-MIT-green)

<!-- TODO: Add hero screenshot/GIF here -->

## Features

- **Chat** — Streaming conversations with Apple's on-device ~3B parameter model
- **Image Studio** — Generate images in three styles (animation, illustration, sketch) using Image Playground
- **Structured Output** — Design `@Generable` schemas and see JSON output in real-time
- **Tool Calling** — Define tools and watch the model invoke them
- **Token Visualizer** — See your 4,096-token context window fill up in real-time
- **Resource Monitor** — CPU, Neural Engine, memory, battery, and tokens/second
- **Parameter Tuner** — Temperature, sampling, max tokens with instant feedback
- **Compare Mode** — Same prompt, different parameters, side by side

## Why Think Locally?

|                       | Think Locally           | ChatGPT Desktop   | Claude Desktop    |
| --------------------- | ----------------------- | ----------------- | ----------------- |
| **Privacy**           | 100% on-device          | Cloud             | Cloud             |
| **Cost**              | Free forever            | Subscription      | Subscription      |
| **Internet**          | Not required            | Required          | Required          |
| **Speed**             | ~40 tok/s               | Network dependent | Network dependent |
| **Data**              | Never leaves your Mac   | Sent to OpenAI    | Sent to Anthropic |
| **Structured Output** | `@Generable` playground | N/A               | N/A               |
| **Tool Calling**      | Visual lab with mocks   | N/A               | N/A               |

## Requirements

- macOS 26 (Tahoe) or later
- Apple Silicon (M1 or later)
- Apple Intelligence enabled in System Settings

## Build & Run

```bash
git clone https://github.com/anthropics/think-locally.git
cd think-locally
open Package.swift  # Opens in Xcode
# Or build from terminal:
swift build
swift run ThinkLocally
```

## Architecture

Think Locally is a pure SwiftUI app with zero external dependencies. It uses:

- **FoundationModels** — Apple's on-device language model framework
- **ImagePlayground** — On-device image generation
- **NavigationSplitView** — Three-column layout (sidebar, canvas, inspector)

```
Sources/ThinkLocally/
├── ThinkLocallyApp.swift     # App entry point
├── Design/                   # Theme, colors, typography
├── Services/                 # ModelService, ImageService, ResourceMonitor
├── Views/
│   ├── Chat/                 # Chat view, messages, token bar
│   ├── ImageStudio/          # Image generation
│   ├── Schemas/              # Structured output playground
│   ├── Tools/                # Tool calling lab
│   ├── Inspector/            # Parameter tuner, model info
│   └── Shared/               # Reusable components
└── Models/                   # Data models, session storage
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT — see [LICENSE](LICENSE) for details.

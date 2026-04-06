# PRD: Think Locally — Apple Intelligence Playground

> **Your mind. Your machine. No cloud required.**

## Vision

Think Locally is a native macOS app that lets developers explore everything Apple Intelligence can do on-device. Chat, generate images, prototype structured output schemas, test tool calling — all running on the Neural Engine with zero API keys, zero cost, and zero data leaving the machine.

## Target audience

- iOS/macOS developers evaluating FoundationModels for their apps
- Power users curious about on-device AI capabilities
- Conference speakers preparing Apple Intelligence demos

## Personas

- **Adrián** (28, dev iOS mid-senior): Needs to evaluate if FM can replace an OpenAI API call for text classification. Has one afternoon. Wants concrete data and exportable Swift code.
- **Lena** (35, tech lead health startup): Mapping FM limits for structured medical summaries. Privacy is non-negotiable. Works across multiple sessions over a week.
- **Tomás** (42, conference speaker): Preparing an Apple Intelligence demo for NSSpain. Needs visually impressive demos that work live.

## Technical constraints

- macOS 26+ (Tahoe), Apple Silicon required
- FoundationModels: ~3B params, 4096 token context window, text-only input
- ImagePlayground: ImageCreator API, 3 styles (animation, illustration, sketch)
- Model cold start ~500ms (prewarmable)
- Guardrails not disableable, may produce false positives
- 9 languages supported (en, es, fr, de, it, pt-BR, ja, ko, zh-Hans)

## Architecture

- Pure SwiftUI, NavigationSplitView (3 columns)
- No external dependencies beyond Apple frameworks
- Local persistence: ~/Library/Application Support/ThinkLocally/
- State restoration via @SceneStorage
- Open source, MIT license

---

## UI/UX Design (validated by Tufte/Krug/Jobs/Cooper panel)

### Layout

```
┌─────────────────────────────────────────────────────────────────────────┐
│ ◀▶  Think Locally        [NE: ● 38 tok/s]        [⌘K]  [⌘⇧I]        │
├────────────┬──────────────────────────────────┬─────────────────────────┤
│  Chat   ⌘1│                                  │   INSPECTOR (300pt)     │
│  Image  ⌘2│     PRIMARY CANVAS               │   collapsible ⌘⇧I      │
│  ─ ─ ─ ─ ─│     (contextual per mode)        │                         │
│  Schemas⌘3│                                  │   Parameters            │
│  Tools  ⌘4│                                  │   Presets               │
│  ─ ─ ─ ─ ─│                                  │   Context info          │
│  Model  ⌘5│                                  │                         │
│  ─ ─ ─ ─ ─│  ┌────────────────────────────┐  │                         │
│  Sessions  │  │ > Type a message…    ⌘R 🎤 │  │                         │
│   today    │  └────────────────────────────┘  │                         │
│   apr 5    │  ████████░░░░░ 1847/4096 tokens  │                         │
└────────────┴──────────────────────────────────┴─────────────────────────┘
```

- **Sidebar**: 200pt fixed. 5 modes + visual separators + session history.
- **Canvas**: flexible (min 500pt). Contextual per active mode.
- **Inspector**: 300pt collapsible (⌘⇧I). Parameter Tuner, presets, contextual info.
- **Token bar**: 24pt below input. Segmented by role (system/user/assistant), progressive semaphore (normal→orange 75%→red 90%).
- **Resource Monitor**: compact in toolbar (`NE: ● 38 tok/s`). Heartbeat animation during inference. Popover on click with sparklines (CPU, MEM, ANE, BAT, TPS).
- **Status bar**: 20pt at bottom. Model status, params summary when inspector collapsed.

### Key design decisions

- **Chat format**: Full-width without bubbles (Console style). Role labels in small caps. Alternating subtle backgrounds.
- **Color palette**: Cool functional base + amber gold accent (#D4A855). Blue = user, indigo = assistant, gray = system. Orange = warning, red = critical. No green.
- **Typography**: SF Pro for UI, SF Mono for model output and code.
- **Chat as default**: App opens with cursor in chat input field. Zero clicks to primary action.
- **Parameter labels**: Dynamic descriptions ("Temperature: 0.7 — varied responses").
- **Empty states**: Three-line copy pattern (what, value, differentiator). Example: "Your Neural Engine is ready. No server. No latency. Just ask."
- **First run**: Subtle message "Generated entirely on this Mac. Nothing left this device." after first response. Shown once.
- **Image reveal**: Polaroid-style progressive reveal animation.
- **Guardrail hits**: Inline in chat with expandable [Why?] explanation.

### Keyboard shortcuts

| Shortcut | Action                        |
| -------- | ----------------------------- |
| ⌘1-5     | Switch mode                   |
| ⌘N       | New session/schema/generation |
| ⌘R       | Run (generate)                |
| ⌘E       | Export                        |
| ⌘⇧I      | Toggle Inspector              |
| ⌘⌥S      | Toggle Sidebar                |
| ⌘K       | Command palette               |
| ⌘↑/↓     | Temperature ±0.1              |
| ⌘F       | Search current session        |
| ⌘⇧F      | Search all sessions           |

---

## Features (v1)

### F01: Chat conversacional

Streaming text generation with multi-turn sessions. Full-width Console-style format. System prompt editable in Inspector. Session history in sidebar with auto-save.

### F02: Token Visualizer

Persistent bar below input area. Segmented by role (system=gray, user=blue, assistant=indigo). Progressive color warning (75% orange, 90% red). Hover shows per-turn breakdown. Inline warning in chat at 90%. Real-time growth during streaming.

### F03: Image Studio

Three-column layout showing all styles simultaneously (animation, illustration, sketch). Single prompt generates all three. Polaroid reveal animation. Save/copy/share per image. Generation history as horizontal scroll.

### F04: Structured Output Playground

Split view: Swift schema editor (left) + JSON preview (right). Syntax highlighting for both. Schema-output correspondence lines on hover. Pre-populated example (WeatherForecast). Auto-run on edit (optional, 500ms debounce). Run count for variability testing. Export as complete .swift file.

### F05: Tool Calling Lab

Split view: Tool definition editor (left) + conversation with tool invocations (right). Mock response field per tool. Full cycle visible: request → tool call → mock → response. Expandable blocks for tool invocations showing args and response.

### F06: Parameter Tuner

Lives in Inspector panel. Three sliders: Temperature (0.0-2.0), Sampling (greedy/top-p/top-k with sub-param), Max Tokens (1-4096). Numeric values editable on click. Dynamic labels describing effect. Presets as chips: Creative, Precise, Balanced, Deterministic. Changes apply immediately (no Apply button). Condensed in status bar when inspector collapsed.

### F07: Model Inspector

Model availability status, parameter count, context window size, supported languages list, Neural Engine status, throughput benchmark (tok/s). Known Limitations section with guardrail categories. Accessible via ⌘5.

### F08: Resource Monitor

Compact display in toolbar: `NE: ● Active · 38 tok/s`. Heartbeat animation (● pulses) during active inference. Click opens popover with 5 sparklines (30 samples each): CPU%, Memory, ANE%, Battery (with time estimate), Tokens/sec. Adaptive: warning colors when thresholds exceeded.

### F09: Command Palette (⌘K)

Fuzzy search over all actions, modes, keyboard shortcuts. Quick prompt templates accessible via `/classify`, `/summarize`, `/extract`, `/translate`. Each template is an optimized system prompt for the 3B model.

### F10: Export

Contextual per mode. Chat → Markdown/JSON. Schemas → .swift file with imports. Tools → .swift file. Images → PNG/JPEG. Model Info → diagnostic report. Accessible via File > Export (⌘E) and contextual button in each mode.

### F11: State Restoration

@SceneStorage for last active mode, inspector state, window position. UserDefaults for parameter values, session history. Full session persistence in local storage.

### F12: Compare Mode

Split chat canvas: same prompt, different parameters, simultaneous execution. Side-by-side comparison of model responses. Toggle via toolbar button.

---

## Features (v2 — post-launch)

- Voice Pipeline (Speech → Transcription → AI → Response)
- Guardrails Tester (dedicated screen with batch testing and presets)
- Cross-reference schemas in Guardrails
- Plugin/extension system

---

## Tasks

### T01: Project scaffold [haiku]

**Objective**: Create the Xcode project with the basic SwiftUI app structure.
**Depends on**: nothing.
**Deliverable**: ThinkLocally.xcodeproj with App entry point, basic WindowGroup, Info.plist configured for macOS 26+.

**Acceptance criteria**:

- Project compiles and runs on macOS 26+
- App icon placeholder set
- Bundle ID: dev.frr.thinklocally
- Minimum deployment target: macOS 26.0
- MIT LICENSE file present
- Basic README.md with project description

**Tests**:

- test_app_launches_successfully

---

### T02: Navigation shell [sonnet]

**Objective**: Implement the 3-column NavigationSplitView layout with sidebar, canvas, and inspector.
**Depends on**: T01.
**Deliverable**: NavigationShell.swift, SidebarView.swift, InspectorView.swift.

**Acceptance criteria**:

- Sidebar shows 5 modes with SF Symbols and visual separators
- ⌘1-5 switches between modes
- Inspector panel toggles with ⌘⇧I
- Sidebar toggles with ⌘⌥S
- Active mode highlighted in sidebar with amber accent
- Status bar at bottom showing model info
- Window restoration via @SceneStorage (last mode, inspector state)
- Minimum window size enforced (900x600)

**Tests**:

- test_sidebar_shows_five_modes
- test_keyboard_shortcuts_switch_modes
- test_inspector_toggles
- test_window_state_restoration

---

### T03: Theme and design system [haiku]

**Objective**: Define the color palette, typography, and reusable style components.
**Depends on**: T01.
**Deliverable**: Theme.swift, Colors.swift, Typography.swift.

**Acceptance criteria**:

- Amber gold accent color (#D4A855) defined
- Role colors: blue (user), indigo (assistant), gray (system)
- Warning colors: orange (75%), red (90%)
- SF Pro for UI text, SF Mono for model output
- Dark mode as default, light mode follows system
- Reusable ViewModifiers for console-style text, role labels, status text

**Tests**:

- test_colors_resolve_in_both_appearances

---

### T04: FoundationModels service layer [sonnet]

**Objective**: Create the service that wraps LanguageModelSession with streaming, token counting, and error handling.
**Depends on**: T01.
**Deliverable**: ModelService.swift, ModelAvailability.swift.

**Acceptance criteria**:

- Async streaming text generation with LanguageModelSession
- Token count tracking per turn (system/user/assistant)
- Session management (create, reset, prewarm)
- Availability checking with all unavailability reasons handled
- GenerationOptions support (temperature, sampling mode, max tokens)
- Guardrail violation error surfaced with category info
- Context window overflow handled gracefully
- Observable state for UI binding (@Observable)

**Tests**:

- test_availability_check_all_states
- test_session_creation_with_options
- test_token_count_tracking
- test_guardrail_error_surfaced
- test_context_overflow_handled

---

### T05: Chat view [opus]

**Objective**: Build the main chat interface with Console-style formatting, streaming, and token bar.
**Depends on**: T02, T03, T04.
**Deliverable**: ChatView.swift, MessageView.swift, TokenBarView.swift, ChatInputView.swift.

**Acceptance criteria**:

- Full-width Console-style messages (no bubbles)
- Role labels (USER/ASSISTANT/SYSTEM) in monospace small caps
- Alternating subtle background per message
- Streaming text appears token-by-token
- Input field with ⌘R to send (also Enter)
- Token bar below input: segmented by role, progressive semaphore colors
- Hover on token bar shows per-turn breakdown
- Inline warning in chat at 90% context usage
- First-run message "Generated entirely on this Mac" after first response
- System prompt editable in Inspector when Chat mode active
- Auto-scroll during streaming with manual scroll override
- Copy message on hover button

**Tests**:

- test_message_renders_with_role_label
- test_streaming_updates_in_realtime
- test_token_bar_segments_by_role
- test_token_bar_color_changes_at_thresholds
- test_first_run_message_shown_once
- test_system_prompt_editable_in_inspector

---

### T06: Parameter Tuner [sonnet]

**Objective**: Build the Inspector panel content for parameter tuning.
**Depends on**: T02, T03, T04.
**Deliverable**: ParameterTunerView.swift, ParameterPresets.swift.

**Acceptance criteria**:

- Temperature slider (0.0-2.0) with editable numeric value
- Sampling mode picker (greedy, top-k, top-p) with sub-parameter slider
- Max tokens slider (1-4096) with editable numeric value
- Dynamic labels: "Temperature: 0.7 — varied responses" updates live
- Presets as chips: Creative (T:1.2, top-p:0.95), Precise (T:0.1, greedy), Balanced (T:0.7, top-k:40), Deterministic (T:0.0, greedy)
- Changes apply immediately to next generation
- Parameters persist between launches (UserDefaults)
- Condensed display in status bar when inspector collapsed: `T:0.7 · top-k:40 · 1024`
- ⌘↑/⌘↓ adjusts temperature by 0.1

**Tests**:

- test_temperature_slider_range
- test_dynamic_labels_update
- test_presets_apply_correct_values
- test_parameters_persist_between_launches
- test_keyboard_temperature_adjustment

---

### T07: Session persistence [sonnet]

**Objective**: Implement local storage for chat sessions and their restoration.
**Depends on**: T04, T05.
**Deliverable**: SessionStore.swift, Session.swift.

**Acceptance criteria**:

- Sessions auto-save to ~/Library/Application Support/ThinkLocally/sessions/
- Session list in sidebar grouped by date (today, yesterday, older dates)
- Click session to restore full conversation with parameters
- Delete session with swipe or context menu
- Session shows first message preview and timestamp
- New session via ⌘N
- Search across all sessions with ⌘⇧F

**Tests**:

- test_session_saves_on_new_message
- test_session_restores_full_conversation
- test_sessions_grouped_by_date
- test_session_deletion
- test_search_across_sessions

---

### T08: Image Studio [sonnet]

**Objective**: Build the image generation interface using ImageCreator API.
**Depends on**: T02, T03.
**Deliverable**: ImageStudioView.swift, ImageGenerationService.swift.

**Acceptance criteria**:

- Three-column layout: animation, illustration, sketch simultaneously
- Single prompt generates all three styles in parallel
- Polaroid-style progressive reveal animation
- Save to disk (PNG), copy to clipboard, share sheet
- Generation history as horizontal scroll below
- Loading state with skeleton placeholders and time counter
- Error handling: device not supported, generation failed, etc.
- Inspector shows generation parameters and timing per style

**Tests**:

- test_three_styles_generated_in_parallel
- test_image_save_to_disk
- test_image_copy_to_clipboard
- test_error_states_displayed
- test_generation_history_persists

---

### T09: Structured Output Playground [opus]

**Objective**: Build the schema editor and JSON preview with live generation.
**Depends on**: T02, T03, T04.
**Deliverable**: SchemaEditorView.swift, SchemaPreviewView.swift, StructuredOutputService.swift.

**Acceptance criteria**:

- Split view: Swift schema editor (left) + JSON result (right)
- Syntax highlighting for Swift (editor) and JSON (preview)
- Pre-populated example schema (WeatherForecast with @Generable)
- Correspondence lines between schema fields and JSON keys (on hover)
- ⌘R to generate, auto-run on edit toggle (500ms debounce)
- Run count (1-10) to test output variability, results as tabs
- Generation time and validation status shown
- Export as complete .swift file with FoundationModels import
- Error highlighting: unsupported types, missing @Guide, etc.
- Prompt field for generation context

**Tests**:

- test_example_schema_loads_on_first_open
- test_generation_produces_valid_json
- test_correspondence_lines_render_on_hover
- test_export_produces_compilable_swift
- test_run_count_generates_multiple_results
- test_error_highlighting_for_invalid_types

---

### T10: Tool Calling Lab [sonnet]

**Objective**: Build the tool definition editor and invocation visualizer.
**Depends on**: T02, T03, T04.
**Deliverable**: ToolEditorView.swift, ToolInvocationView.swift, ToolCallingService.swift.

**Acceptance criteria**:

- Split view: tool definition editor (left) + chat with invocations (right)
- Tool definition with name, description, arguments schema
- Mock response field per tool (what to return when invoked)
- Full cycle visible: user message → model decides to call tool → args shown → mock response → model uses response
- Expandable blocks for tool invocations showing args and response
- Multiple tools definable per session
- Export tool definitions as .swift file
- Pre-populated example tool (getWeather)

**Tests**:

- test_tool_definition_parsed_correctly
- test_model_invokes_tool_with_correct_args
- test_mock_response_returned_to_model
- test_invocation_block_expandable
- test_export_produces_compilable_swift
- test_example_tool_loads

---

### T11: Model Inspector [haiku]

**Objective**: Build the model information and capabilities view.
**Depends on**: T02, T03, T04.
**Deliverable**: ModelInspectorView.swift.

**Acceptance criteria**:

- Model availability status with icon (available/unavailable/loading)
- Parameter count (~3B)
- Context window size (from API, not hardcoded)
- Supported languages list
- Neural Engine status
- Throughput benchmark (run on demand, show tok/s)
- Known Limitations section (guardrail categories, no multimodal, no fine-tuning)
- Benchmark history sparkline (last 10 runs)

**Tests**:

- test_availability_status_displayed
- test_benchmark_runs_and_shows_result
- test_supported_languages_listed
- test_known_limitations_present

---

### T12: Resource Monitor [sonnet]

**Objective**: Build the toolbar resource display and popover with sparklines.
**Depends on**: T02, T03.
**Deliverable**: ResourceMonitorView.swift, ResourceMonitorService.swift.

**Acceptance criteria**:

- Compact toolbar display: `NE: ● Active · 38 tok/s`
- Heartbeat animation: ● pulses during active inference
- Click opens popover with 5 sparklines (CPU, MEM, ANE, BAT, TPS)
- 30 samples per sparkline, sampled every 1s
- Warning colors when thresholds exceeded (CPU >80%, MEM >80%, BAT <15%)
- Battery shows percentage + estimated time remaining (when unplugged)
- Tokens/second updates during streaming
- Popover dismisses on click outside

**Tests**:

- test_toolbar_shows_compact_display
- test_heartbeat_animates_during_inference
- test_popover_shows_five_sparklines
- test_warning_colors_at_thresholds
- test_battery_shows_time_estimate_when_unplugged

---

### T13: Command Palette [haiku]

**Objective**: Implement ⌘K command palette with fuzzy search.
**Depends on**: T02.
**Deliverable**: CommandPaletteView.swift, CommandRegistry.swift.

**Acceptance criteria**:

- ⌘K opens overlay with search field
- Fuzzy search over all modes, actions, keyboard shortcuts
- Quick prompt templates: /classify, /summarize, /extract, /translate
- Each template includes optimized system prompt for 3B model
- Arrow keys + Enter to select, Escape to dismiss
- Recently used commands shown when field empty
- Results show keyboard shortcut hint when available

**Tests**:

- test_palette_opens_with_cmd_k
- test_fuzzy_search_finds_modes
- test_prompt_templates_available
- test_keyboard_navigation_works
- test_recent_commands_shown

---

### T14: Export system [haiku]

**Objective**: Implement contextual export across all modes.
**Depends on**: T05, T08, T09, T10, T11.
**Deliverable**: ExportService.swift.

**Acceptance criteria**:

- File > Export (⌘E) triggers export for current mode
- Chat exports: Markdown (formatted), JSON (raw), clipboard
- Schemas exports: complete .swift file with imports
- Tools exports: complete .swift file with Tool protocol conformance
- Images exports: PNG/JPEG with metadata
- Model Info exports: diagnostic Markdown report
- NSSavePanel for file destination
- Copy to clipboard alternative for all formats

**Tests**:

- test_chat_exports_markdown
- test_schema_exports_compilable_swift
- test_image_exports_png
- test_model_info_exports_report

---

### T15: Empty states and first-run experience [haiku]

**Objective**: Design all empty states with the three-line copy pattern and first-run message.
**Depends on**: T02, T03.
**Deliverable**: EmptyStateView.swift, FirstRunManager.swift.

**Acceptance criteria**:

- Chat empty: "Your Neural Engine is ready. No server. No latency. Just ask." + ⌘N CTA + 3 template shortcuts
- Image empty: "Three styles. Infinite ideas. Everything stays on your Mac." + prompt field
- Schemas empty: pre-populated example (handled in T09)
- Tools empty: pre-populated example (handled in T10)
- Model empty: auto-loads info (handled in T11)
- First-run "Generated entirely on this Mac. Nothing left this device." after first response, shown once
- Model unavailable state: "Apple Intelligence is loading..." with spinner

**Tests**:

- test_empty_states_show_correct_copy
- test_first_run_message_shown_once
- test_model_unavailable_state

---

### T16: Compare Mode [sonnet]

**Objective**: Side-by-side chat comparison with different parameters.
**Depends on**: T05, T06.
**Deliverable**: CompareView.swift.

**Acceptance criteria**:

- Toggle via toolbar button in Chat mode
- Split canvas: left and right with independent parameter sets
- Same prompt sent to both sides simultaneously
- Each side shows its own token bar and parameter summary
- Results appear side-by-side with streaming
- Differences highlighted (response length, content variation)
- Exit compare mode preserves the preferred side's session

**Tests**:

- test_compare_mode_splits_canvas
- test_same_prompt_sent_to_both
- test_independent_parameters_per_side
- test_exit_preserves_preferred_session

---

### T17: App icon and branding [haiku]

**Objective**: Create the app icon (crystal cube with amber light) and branding assets.
**Depends on**: T03.
**Deliverable**: AppIcon.appiconset, About window.

**Acceptance criteria**:

- App icon: crystal cube with warm amber interior light suggesting λ
- Icon renders well at all sizes (16x16 to 1024x1024)
- About window with app name, version, tagline
- macOS standard About panel (not custom)

**Tests**:

- test_about_window_shows_correct_info

---

### T18: GitHub repo and README [haiku]

**Objective**: Prepare the public GitHub repository with compelling README for HN.
**Depends on**: T01.
**Deliverable**: README.md, CONTRIBUTING.md, .github/ templates.

**Acceptance criteria**:

- README with: tagline, hero GIF/screenshot, feature list, requirements, build instructions
- Clear "zero API keys, zero cost, zero cloud" messaging
- Installation via git clone + Xcode build (no Homebrew yet)
- Feature comparison table (vs ChatGPT Desktop, vs Claude Desktop)
- Architecture section with diagram
- Contributing guide
- MIT license

**Tests**:

- (manual review)

---

### T19: Integration testing and polish [opus]

**Objective**: End-to-end testing, performance profiling, and UX polish.
**Depends on**: T05, T06, T07, T08, T09, T10, T11, T12, T13, T14, T15, T16.
**Deliverable**: Integration tests, performance benchmarks.

**Acceptance criteria**:

- Full flow: launch → chat → adjust params → switch to schemas → export
- No memory leaks during extended chat sessions
- Streaming performance: UI stays responsive at 60fps during generation
- Cold start time < 2s (including model prewarm)
- Token counting accuracy verified against session.tokenCount API
- All keyboard shortcuts functional
- State restoration works after force quit
- VoiceOver accessibility for all interactive elements

**Tests**:

- test_full_chat_flow_end_to_end
- test_no_memory_leaks_extended_session
- test_streaming_ui_responsive
- test_cold_start_under_two_seconds
- test_all_keyboard_shortcuts_work
- test_voiceover_accessible

---

## Implementation sprints

**Sprint 1 — Skeleton** (T01, T02, T03, T18):
Project scaffold, navigation shell, theme, README.

**Sprint 2 — Core** (T04, T05, T06, T07, T15):
Model service, chat view, parameter tuner, session persistence, empty states.

**Sprint 3 — Features** (T08, T09, T10, T11):
Image Studio, Structured Output, Tool Calling, Model Inspector.

**Sprint 4 — Power tools** (T12, T13, T14, T16, T17):
Resource Monitor, Command Palette, Export, Compare Mode, App Icon.

**Sprint 5 — Ship** (T19):
Integration testing, polish, HN launch prep.

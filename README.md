# AIContextIOS

A comprehensive iOS foundation library providing AI-ready project foundations using **TCA (The Composable Architecture)** with Clean Architecture principles.

## Features

- 🏗️ **TCA Architecture**: State/Action/Reducer/Environment pattern with Clean Architecture
- 🎨 **Dynamic Theme System**: Seasonal and cultural themes with automatic switching
- 📱 **Design System**: Complete design tokens with colors, typography, and spacing
- 🔧 **Code Templates**: Ready-to-use TCA screen, UseCase, and Repository templates
- 📝 **Documentation**: Comprehensive architecture guidelines and best practices
- 🧪 **Testing**: Mock environments and testing utilities

## Installation

### CocoaPods

Add this line to your `Podfile`:

```ruby
pod 'AIContextIOS', '~> 1.0'
```

Then run:

```bash
pod install
```

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/tienbm92/ai-context-base", from: "1.0.0")
]
```

Or add it through Xcode: **File → Add Package Dependencies** and enter the repository URL.

## Quick Start

### 1. Basic Setup

```swift
import AIContextIOS

// Access the foundation manifest
let manifest = AIContextIOS.manifest
print("Foundation version: \(manifest?["version"] ?? "unknown")")

// Get available resources
let resources = AIContextIOS.availableResources
print("Available resources: \(resources)")
```

### 2. Theme System

```swift
import SwiftUI
import AIContextIOS

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello World")
                .foregroundColor(theme.colors.primary)
        }
        .environment(\.theme, currentTheme)
    }
    
    private var currentTheme: Theme {
        let themesData = AIContextIOS.themes
        let themeId = UserDefaults.standard.string(forKey: "current_theme") ?? "default_light"
        return themesData?.theme(id: themeId) ?? defaultTheme
    }
}
```

### 3. TCA Integration

```swift
import ComposableArchitecture
import AIContextIOS

struct AppState: Equatable {
    var currentThemeId: String = "default_light"
    // ... other state
}

enum AppAction {
    case themeSelected(String)
    // ... other actions
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .themeSelected(let themeId):
        state.currentThemeId = themeId
        return .none
    }
}
```

## Available Themes

AIContextIOS includes several built-in themes:

- **Default**: `default_light`, `default_dark`
- **Seasonal**: `christmas_2024`, `summer_2024`, `halloween_2024`
- **Cultural**: `tet_2024` (Vietnamese New Year), `valentine_2024`

### Time-Limited Themes

Some themes automatically activate during specific periods:

```swift
let availableThemes = AIContextIOS.availableThemes
// Returns only themes that are currently active based on date ranges
```

## Design Tokens

Access the design system tokens:

```swift
let designTokens = AIContextIOS.designTokens

// Typography
let headingFont = designTokens?.typography.heading1
let bodyFont = designTokens?.typography.body

// Spacing
let spacing = designTokens?.spacing.lg // 24pt

// Colors (from current theme)
let primaryColor = currentTheme.colors.primary
let backgroundColor = currentTheme.colors.background.primary
```

## Architecture Guidelines

AIContextIOS follows Clean Architecture with TCA:

### TCA Components (5 files per feature)

1. **State** (`{Feature}State.swift`) - Immutable business state
2. **Action** (`{Feature}Action.swift`) - All possible events
3. **Reducer** (`{Feature}Reducer.swift`) - State transformation logic
4. **Environment** (`{Feature}Environment.swift`) - Dependencies
5. **View** (`{Feature}View.swift`) - SwiftUI presentation

### Critical Animation Rule ⚠️

**Animation state MUST be in `@State` (View), NEVER in Store State.**

```swift
// ✅ CORRECT - Animation in View @State
struct LoginView: View {
    let store: Store<LoginState, LoginAction>
    @State private var buttonScale: CGFloat = 1.0
    
    var body: some View {
        WithViewStore(store) { viewStore in
            Button("Login") { viewStore.send(.loginButtonTapped) }
                .scaleEffect(buttonScale)
                .onChange(of: viewStore.status) { status in
                    if status == .loading {
                        withAnimation { buttonScale = 0.95 }
                    }
                }
        }
    }
}
```

## Templates

Access code templates for rapid development:

```swift
// Get template content
let tcaScreenTemplate = AIContextIOS.loadResource("templates/tca_screen")
let useCaseTemplate = AIContextIOS.loadResource("templates/usecase")
let repositoryTemplate = AIContextIOS.loadResource("templates/repository")
```

## Resources Access

Direct access to foundation resources:

```swift
// Load specific resource
let architectureGuide = AIContextIOS.loadResource("architecture")
let stateManagement = AIContextIOS.loadResource("state_management")

// Get resource file path
let manifestPath = AIContextIOS.resourcePath(for: "manifest")
let themePath = AIContextIOS.resourcePath(for: "theme_system")
```

## Requirements

- iOS 15.0+
- Swift 5.5+
- Xcode 13.0+

## Dependencies

- [ComposableArchitecture](https://github.com/pointfreeco/swift-composable-architecture) (2.0.0+)

## Documentation

The library includes comprehensive documentation files:

- **Architecture**: Clean Architecture + TCA patterns
- **State Management**: TCA state handling best practices
- **Animation Guidelines**: How to properly handle animations in TCA
- **Theme System**: Dynamic theming implementation
- **Testing**: Testing strategies for TCA applications

Access these through:

```swift
let architectureDocs = AIContextIOS.loadResource("architecture")
let animationGuides = AIContextIOS.loadResource("animation_guidelines")
```

## License

AIContextIOS is available under the MIT license. See the LICENSE file for more info.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For questions and support, please open an issue on GitHub.

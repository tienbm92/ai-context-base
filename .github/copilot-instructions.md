# iOS Foundation - AI Coding Agent Instructions

This repository provides AI-ready iOS project foundations using **MVVM (Model-View-ViewModel)** with Clean Architecture principles.

## Architecture Overview

**Pattern**: Clean Architecture + MVVM (ViewModel/View)
**Dependency Flow**: `Presentation → Domain ← Data`

### MVVM Components (2 files per feature)
1. **ViewModel** (`{Feature}ViewModel.swift`) - ObservableObject with @Published business state, async methods, dependencies via init
2. **View** (`{Feature}View.swift`) - SwiftUI with `@StateObject` ViewModel, `@State` for animations/transient UI

**Templates**: See `ios_foundation/templates/mvvm_screen.swift.json` for complete examples.

## Critical Animation Rule ⚠️

**Animation state MUST be in `@State` (View), NEVER in ViewModel @Published properties.**

```swift
// ❌ FORBIDDEN - Animation in ViewModel @Published
class LoginViewModel: ObservableObject {
  @Published var buttonScale: CGFloat = 1.0  // NO!
}

// ✅ CORRECT - Animation in View @State
struct LoginView: View {
  @StateObject private var viewModel = LoginViewModel()
  @State private var buttonScale: CGFloat = 1.0  // YES!
  
  var body: some View {
    Button("Login") { viewModel.login() }
      .scaleEffect(buttonScale)
      .onChange(of: viewModel.status) { status in
        // Trigger animations from business state changes
        if status == .loading {
          withAnimation { buttonScale = 0.95 }
        }
      }
  }
}
```

**Read**: `ios_foundation/animation_guidelines.json` BEFORE implementing any UI with animations.

## Code Generation Checklist

Before generating MVVM code, validate:

### ViewModel
- ✅ Is `class` conforming to `ObservableObject`
- ✅ Uses `@Published` for business state ONLY (no `CGFloat`/`Double`/`Angle` for animations)
- ✅ No transient UI state (focus, drag positions, etc.)
- ✅ Async methods for asynchronous operations
- ✅ Dependencies injected via init (UseCases, NOT Repositories)
- ✅ Provides mock variant for testing

### View
- ✅ Uses `@StateObject` for ViewModel ownership OR `@ObservedObject` for passed-in ViewModels
- ✅ Uses `@State` for animations/transient UI state
- ✅ Calls ViewModel methods for user interactions
- ✅ Uses `.onChange(of: viewModel.property)` to trigger animations
- ✅ No business logic in View (belongs in ViewModel)

**Reference**: `ios_foundation/ai_rules.json` for complete validation rules.

## Theme System

**Theme ID** stored in AppViewModel @Published (String), **Theme object** accessed via `@Environment(\.theme)`.

```swift
// AppViewModel
class AppViewModel: ObservableObject {
  @Published var currentThemeId: String = "default_light"  // ✅ ID only
}

// View
struct MyView: View {
  @Environment(\.theme) var theme  // ✅ Access theme object
  
  var body: some View {
    Text("Hello").foregroundColor(theme.colors.primary)
  }
}
```

Theme changes trigger through ViewModel methods (`appViewModel.selectTheme("dark")`). See `ios_foundation/theme_system.json`.

## Dependency Injection

**Primary**: ViewModel init (for feature dependencies)
**Secondary**: Resolver (for global services)

```swift
// ViewModel with Dependencies
class LoginViewModel: ObservableObject {
  private let loginUseCase: LoginUserUseCaseProtocol  // ✅ Inject UseCases
  
  init(loginUseCase: LoginUserUseCaseProtocol) {
    self.loginUseCase = loginUseCase
  }
  
  // For testing
  static func mock() -> LoginViewModel {
    LoginViewModel(loginUseCase: MockLoginUseCase())
  }
  
  // For production
  static func live() -> LoginViewModel {
    LoginViewModel(loginUseCase: Resolver.resolve())
  }
}
```

**Never**: Inject Repositories directly into ViewModel (use UseCases as abstraction layer).

See `ios_foundation/di.json` for patterns.

## File Locations

- **Architecture docs**: `ios_foundation/architecture.json`
- **Presentation patterns**: `ios_foundation/presentation_patterns.json`
- **State management**: `ios_foundation/state_management.json`
- **Animation guidelines**: `ios_foundation/animation_guidelines.json` (CRITICAL)
- **Networking**: `ios_foundation/networking.json`
- **Templates**: `ios_foundation/templates/` (mvvm_screen, viewmodel, repository, usecase)
- **Manifest**: `ios_foundation/manifest.json` (when to read which file)

## Common Anti-Patterns

❌ Animation state in ViewModel @Published (use `@State` in View)
❌ Repositories injected into ViewModel (inject UseCases)
❌ Business logic in View (belongs in ViewModel)
❌ Missing mock ViewModel variant (breaks testing)
❌ Using `@ObservedObject` when View owns ViewModel (use `@StateObject`)
❌ Synchronous methods for async operations (use async/await)

## Quick Commands

This is a **documentation repository** (no builds/tests). Reference files in `ios_foundation/` when implementing features.

For implementing new MVVM screens, follow the 2-file template in `ios_foundation/templates/mvvm_screen.swift.json`.


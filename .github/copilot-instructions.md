# iOS Foundation - AI Coding Agent Instructions

This repository provides AI-ready iOS project foundations using **MVVM (Model-View-ViewModel)** with Clean Architecture principles.

## Architecture Overview

**Pattern**: Clean Architecture + MVVM (ViewModel/View/ViewState/Navigator)
**Dependency Flow**: `Presentation → Domain ← Data`

### MVVM Components (2-4 files per feature)
1. **ViewModel** (`{Feature}ViewModel.swift`) - ObservableObject with @Published business state, async methods, dependencies via init
2. **View** (`{Feature}View.swift`) - SwiftUI with `@StateObject` ViewModel, `@State` for animations/transient UI
3. **ViewState** (OPTIONAL, nested in ViewModel) - Single Equatable struct with pre-formatted View-ready data (for complex screens)
4. **Navigator** (OPTIONAL, Presentation layer) - Protocol for navigation abstraction (use sparingly)

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

**Read**: `ios_foundation/architecture/animation_guidelines.json` BEFORE implementing any UI with animations.

## ViewState Pattern (Optional)

For screens with complex formatting/mapping, use ViewState to reduce View complexity:

```swift
class LoginViewModel: ObservableObject {
  // ViewState (public, single source for View)
  @Published private(set) var viewState: ViewState = .idle
  
  // Business state (private)
  @Published private var email: String = ""
  @Published private var status: Status = .idle
  
  struct ViewState: Equatable {
    let buttonTitle: String
    let isButtonEnabled: Bool
    let showsLoading: Bool
    let errorMessage: String?
  }
  
  private func updateViewState() {
    viewState = ViewState(
      buttonTitle: status == .loading ? "Signing in..." : "Sign In",
      isButtonEnabled: !email.isEmpty && status != .loading,
      showsLoading: status == .loading,
      errorMessage: nil
    )
  }
}

// View reads ViewState
var body: some View {
  Button(viewModel.viewState.buttonTitle) { }
    .disabled(!viewModel.viewState.isButtonEnabled)
}
```

**When to use**: Complex formatting, multiple @Published properties updated together, want to test rendering logic.  
**Read**: `ios_foundation/architecture/viewstate_pattern.json`

## Navigation Patterns

**Recommended**: Intent-based navigation (default) — ViewModel emits intent, View executes.

```swift
// ViewModel (intent-based)
class LoginViewModel: ObservableObject {
  @Published var navigationIntent: NavigationIntent?
  
  enum NavigationIntent: Equatable {
    case home
    case forgotPassword
  }
  
  func loginSuccess() {
    navigationIntent = .home
  }
}

// View handles navigation
.onChange(of: viewModel.navigationIntent) { intent in
  guard let intent = intent else { return }
  switch intent {
  case .home:
    navigationPath.append(HomeRoute.home)
  case .forgotPassword:
    showForgotPassword = true
  }
  viewModel.navigationIntent = nil  // Consume
}
```

**Alternative (use sparingly)**: Navigator injection — ViewModel injects Navigator protocol.

```swift
protocol Navigator: AnyObject {
  func push(_ route: Route)
  func present(_ route: Route)
}

class LoginViewModel: ObservableObject {
  private weak var navigator: Navigator?  // weak to avoid retain cycle
  
  init(navigator: Navigator?) {
    self.navigator = navigator
  }
  
  func loginSuccess() {
    navigator?.push(.home)
  }
}
```

**When to use Navigator injection**: Need imperative navigation, want to mock in tests, complex flows.  
**When to use Coordinator**: Large apps with multiple flows (auth, onboarding, main).  
**Read**: `ios_foundation/architecture/navigation_patterns.json`

## Code Generation Checklist

Before generating MVVM code, validate:

### ViewModel
- ✅ Is `class` conforming to `ObservableObject`
- ✅ Uses `@Published` for business state ONLY (no `CGFloat`/`Double`/`Angle` for animations)
- ✅ No transient UI state (focus, drag positions, etc.)
- ✅ Async methods for asynchronous operations
- ✅ Dependencies injected via init (UseCases, NOT Repositories; Navigator optional)
- ✅ Provides mock variant for testing
- ✅ Uses ViewState if screen has complex formatting (optional)

### View
- ✅ Uses `@StateObject` for ViewModel ownership OR `@ObservedObject` for passed-in ViewModels
- ✅ Uses `@State` for animations/transient UI state
- ✅ Calls ViewModel methods for user interactions
- ✅ Uses `.onChange(of: viewModel.property)` to trigger animations
- ✅ No business logic in View (belongs in ViewModel)
- ✅ Handles navigation intents if using intent-based pattern

### Navigation
- ✅ Default: intent-based (ViewModel @Published intent, View executes)
- ✅ Use Navigator injection sparingly (weak reference, presentation-only)
- ✅ Use Coordinator for complex multi-screen flows

**Reference**: `ios_foundation/architecture/ai_rules.json` for complete validation rules.

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


# iOS Foundation - AI Coding Agent Instructions

This repository provides AI-ready iOS project foundations using **TCA (The Composable Architecture)** with Clean Architecture principles.

## Architecture Overview

**Pattern**: Clean Architecture + TCA (State/Action/Reducer/Environment)
**Dependency Flow**: `Presentation → Domain ← Data`

### TCA Components (5 files per feature)
1. **State** (`{Feature}State.swift`) - Immutable business state struct (Equatable)
2. **Action** (`{Feature}Action.swift`) - Exhaustive enum of all events
3. **Reducer** (`{Feature}Reducer.swift`) - Pure function: `(inout State, Action, Environment) -> Effect<Action>`
4. **Environment** (`{Feature}Environment.swift`) - Dependencies container (UseCases, services, schedulers)
5. **View** (`{Feature}View.swift`) - SwiftUI with `Store<State, Action>` + `WithViewStore`

**Templates**: See `ios_foundation/templates/tca_screen.swift.json` for complete examples.

## Critical Animation Rule ⚠️

**Animation state MUST be in `@State` (View), NEVER in Store State.**

```swift
// ❌ FORBIDDEN - Animation in Store State
struct LoginState: Equatable {
  var buttonScale: CGFloat = 1.0  // NO!
}

// ✅ CORRECT - Animation in View @State
struct LoginView: View {
  let store: Store<LoginState, LoginAction>
  @State private var buttonScale: CGFloat = 1.0  // YES!
  
  var body: some View {
    WithViewStore(store) { viewStore in
      Button("Login") { viewStore.send(.loginButtonTapped) }
        .scaleEffect(buttonScale)
        .onChange(of: viewStore.status) { status in
          // Trigger animations from business state changes
          if status == .loading {
            withAnimation { buttonScale = 0.95 }
          }
        }
    }
  }
}
```

**Read**: `ios_foundation/animation_guidelines.json` BEFORE implementing any UI with animations.

## Code Generation Checklist

Before generating TCA code, validate:

### State
- ✅ Is `struct` conforming to `Equatable`
- ✅ Contains business state ONLY (no `CGFloat`/`Double`/`Angle` for animations)
- ✅ No transient UI state (focus, drag positions, etc.)
- ✅ Pure Swift (no UIKit/SwiftUI imports)

### Action
- ✅ Is `enum` (exhaustive)
- ✅ Covers ALL user interactions (`.buttonTapped`, `.inputChanged`)
- ✅ Covers ALL system responses (`.response(Result<T, Error>)`)
- ✅ Uses associated values for data
- ✅ No generic actions (`.update`, `.setState`)

### Reducer
- ✅ Pure function (no side effects in body)
- ✅ Handles ALL Action cases (exhaustive `switch`)
- ✅ Returns `Effect<Action>` for async work, `.none` for sync updates
- ✅ Uses `environment` for dependencies (NOT direct calls)

### Environment
- ✅ Injects UseCases (NOT Repositories)
- ✅ Includes `mainQueue: AnySchedulerOf<DispatchQueue>`
- ✅ Provides `.mock` (with `.immediate` scheduler for tests) and `.live` variants

### View
- ✅ Uses `@State` for animations/transient UI state
- ✅ Uses `WithViewStore` for state observation
- ✅ Sends actions via `viewStore.send()`
- ✅ Uses `.onChange(of: viewStore.state)` to trigger animations

**Reference**: `ios_foundation/ai_rules.json` for complete validation rules.

## Theme System

**Theme ID** stored in Store State (String), **Theme object** accessed via `@Environment(\.theme)`.

```swift
// Store State
struct AppState: Equatable {
  var currentThemeId: String = "default_light"  // ✅ ID only
}

// View
struct MyView: View {
  @Environment(\.theme) var theme  // ✅ Access theme object
  
  var body: some View {
    Text("Hello").foregroundColor(theme.colors.primary)
  }
}
```

Theme changes trigger through TCA actions (`.themeSelected(String)`). See `ios_foundation/theme_system.json`.

## Dependency Injection

**Primary**: TCA Environment struct (for Reducer dependencies)
**Secondary**: Resolver (for global services)

```swift
// Environment with UseCases
struct LoginEnvironment {
  var loginUseCase: LoginUserUseCaseProtocol  // ✅ Inject UseCases
  var mainQueue: AnySchedulerOf<DispatchQueue>
  
  static var mock: Self {
    Self(loginUseCase: MockLoginUseCase(), mainQueue: .immediate)
  }
  
  static var live: Self {
    Self(loginUseCase: Resolver.resolve(), mainQueue: .main)
  }
}
```

**Never**: Inject Repositories directly into Environment (use UseCases as abstraction layer).

See `ios_foundation/di.json` for patterns.

## File Locations

- **Architecture docs**: `ios_foundation/architecture.json`
- **Presentation patterns**: `ios_foundation/presentation_patterns.json`
- **State management**: `ios_foundation/state_management.json`
- **Animation guidelines**: `ios_foundation/animation_guidelines.json` (CRITICAL)
- **Networking**: `ios_foundation/networking.json`
- **Templates**: `ios_foundation/templates/` (tca_screen, repository, usecase)
- **Manifest**: `ios_foundation/manifest.json` (when to read which file)

## Common Anti-Patterns

❌ Animation state in Store State (use `@State` in View)
❌ Repositories injected into Environment (inject UseCases)
❌ Generic Action cases (`.update`, `.change` - be explicit)
❌ Side effects in Reducer body (use `Effect`)
❌ `.main` scheduler in `.mock` (use `.immediate` for deterministic tests)
❌ Missing `.mock` Environment (breaks testing)

## Quick Commands

This is a **documentation repository** (no builds/tests). Reference files in `ios_foundation/` when implementing features.

For implementing new TCA screens, follow the 5-file template in `ios_foundation/templates/tca_screen.swift.json`.

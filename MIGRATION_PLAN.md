# Migration Plan: TCA → Clean Architecture + MVVM

**Date**: November 1, 2025  
**Repository**: ai-context-base  
**Branch**: feature/ios-foundation-theme-system  
**Objective**: Remove TCA dependency, migrate to MVVM with Clean Architecture

## Overview

This repository provides AI-ready iOS project foundations. We're migrating from TCA (The Composable Architecture) to **Clean Architecture + MVVM** to eliminate external library dependencies while maintaining:

- ✅ Clean Architecture layers (Presentation → Domain ← Data)
- ✅ Testability (protocol-based DI, mock support)
- ✅ Animation rules (@State in View for animations)
- ✅ Theme system (theme ID in business state)
- ✅ Async/await for side effects

## Why Migrate?

### Problems with TCA
- ❌ External dependency (github.com/pointfreeco/swift-composable-architecture)
- ❌ Breaking changes in major versions
- ❌ Learning curve for new developers
- ❌ Overkill for most projects
- ❌ Long-term maintenance risk

### Benefits of MVVM
- ✅ No external dependencies (native Swift/Combine/SwiftUI)
- ✅ Simpler mental model (ViewModel + View)
- ✅ Easier onboarding
- ✅ Full control over architecture
- ✅ Native Apple patterns

## Architecture Comparison

### Before (TCA)
```
Presentation Layer:
├── State.swift         → Immutable struct (Equatable)
├── Action.swift        → Enum (all events)
├── Reducer.swift       → Pure function (State, Action, Environment) → Effect
├── Environment.swift   → Dependencies container
└── View.swift          → SwiftUI View with Store<State, Action>
```

### After (MVVM)
```
Presentation Layer:
├── ViewModel.swift     → ObservableObject (@Published state, methods)
└── View.swift          → SwiftUI View with @StateObject/@ObservedObject
```

## Component Mapping

| TCA Component | MVVM Equivalent | Notes |
|--------------|-----------------|-------|
| `State` struct | `@Published` properties in ViewModel | Business state only |
| `Action` enum | ViewModel methods | `func loginButtonTapped()` |
| `Reducer` | ViewModel method implementations | Update @Published state |
| `Effect` | async/await or Combine Publisher | In ViewModel methods |
| `Environment` | ViewModel init dependencies | Inject UseCases via Resolver |
| `Store` | ViewModel instance | `@StateObject var viewModel` |
| `WithViewStore` | Direct ViewModel access | `viewModel.property` |
| `TestStore` | ViewModel unit tests | Test @Published state changes |

## Migration Steps

### Phase 1: Documentation Update (This PR)

1. ✅ **Read all existing files** (completed)
2. 🔄 **Create MIGRATION_PLAN.md** (this file)
3. 🔄 **Update core documentation**:
   - `architecture.json` - Replace TCA with MVVM
   - `presentation_patterns.json` - MVVM patterns
   - `state_management.json` - @Published + Combine
   - `ai_rules.json` - ViewModel validation rules
   - `animation_guidelines.json` - Keep @State rules, remove TCA Store
   - `di.json` - ViewModel dependency injection
   - `testing.json` - ViewModel testing patterns
   - `theme_system.json` - Theme with ViewModel

4. 🔄 **Create new templates**:
   - `templates/mvvm_screen.swift.json` (replace tca_screen)
   - `templates/viewmodel.swift.json` (new)
   - Keep: `usecase.swift.json`, `repository.swift.json`

5. 🔄 **Update references**:
   - `manifest.json` - File descriptions
   - `.github/copilot-instructions.md` - MVVM guidance

### Phase 2: Code Examples (Future PR)

1. Create sample MVVM implementation
2. Add comprehensive tests
3. Validate against real iOS project

## MVVM Pattern Details

### ViewModel Structure
```swift
import Foundation
import Combine

final class LoginViewModel: ObservableObject {
    // MARK: - Published State (Business State)
    @Published private(set) var email: String = ""
    @Published private(set) var password: String = ""
    @Published private(set) var status: Status = .idle
    @Published private(set) var errorMessage: String?
    
    enum Status: Equatable {
        case idle, loading, success(User), error
    }
    
    // MARK: - Dependencies
    private let loginUseCase: LoginUserUseCaseProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed
    var isLoading: Bool { 
        if case .loading = status { return true }
        return false 
    }
    var isFormValid: Bool {
        !email.isEmpty && email.contains("@") && !password.isEmpty
    }
    
    // MARK: - Init
    init(
        loginUseCase: LoginUserUseCaseProtocol,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.loginUseCase = loginUseCase
        self.analyticsService = analyticsService
    }
    
    // MARK: - Actions (Methods replace Action enum)
    func emailChanged(_ newEmail: String) {
        email = newEmail
    }
    
    func passwordChanged(_ newPassword: String) {
        password = newPassword
    }
    
    func loginButtonTapped() {
        guard isFormValid else {
            errorMessage = "Invalid form"
            return
        }
        
        status = .loading
        errorMessage = nil
        
        Task {
            do {
                let user = try await loginUseCase.execute(
                    email: email,
                    password: password
                )
                await MainActor.run {
                    status = .success(user)
                }
                await analyticsService.track(event: .login)
            } catch {
                await MainActor.run {
                    status = .error
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
```

### View Structure
```swift
import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    
    // ✅ Animation state in @State (SAME as TCA rule)
    @State private var buttonScale: CGFloat = 1.0
    @State private var isShaking = false
    
    var body: some View {
        VStack(spacing: 24) {
            TextField("Email", text: .init(
                get: { viewModel.email },
                set: { viewModel.emailChanged($0) }
            ))
            
            SecureField("Password", text: .init(
                get: { viewModel.password },
                set: { viewModel.passwordChanged($0) }
            ))
            
            Button("Login") {
                viewModel.loginButtonTapped()
            }
            .scaleEffect(buttonScale)
            .disabled(viewModel.isLoading)
        }
        .onChange(of: viewModel.status) { status in
            switch status {
            case .loading:
                withAnimation { buttonScale = 0.95 }
            case .error:
                withAnimation { isShaking = true }
            default:
                buttonScale = 1.0
            }
        }
    }
}
```

### Dependency Injection
```swift
// In Resolver registration
extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        // UseCases
        register { LoginUserUseCase(
            authRepository: resolve()
        ) as LoginUserUseCaseProtocol }
        
        // Services
        register { AnalyticsService() as AnalyticsServiceProtocol }
            .scope(.application)
    }
}

// In Coordinator or App
let viewModel = LoginViewModel(
    loginUseCase: Resolver.resolve(),
    analyticsService: Resolver.resolve()
)
let view = LoginView(viewModel: viewModel)
```

### Testing
```swift
class LoginViewModelTests: XCTestCase {
    var sut: LoginViewModel!
    var mockUseCase: MockLoginUseCase!
    var mockAnalytics: MockAnalyticsService!
    
    override func setUp() {
        mockUseCase = MockLoginUseCase()
        mockAnalytics = MockAnalyticsService()
        sut = LoginViewModel(
            loginUseCase: mockUseCase,
            analyticsService: mockAnalytics
        )
    }
    
    func testLoginSuccess() async {
        // Given
        mockUseCase.result = .success(User.mock)
        sut.emailChanged("test@test.com")
        sut.passwordChanged("password")
        
        // When
        sut.loginButtonTapped()
        
        // Wait for async
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(sut.status, .success(User.mock))
        XCTAssertEqual(mockUseCase.callCount, 1)
        XCTAssertTrue(mockAnalytics.events.contains(.login))
    }
    
    func testLoginFailure() async {
        // Given
        mockUseCase.result = .failure(APIError.unauthorized)
        sut.emailChanged("test@test.com")
        sut.passwordChanged("wrong")
        
        // When
        sut.loginButtonTapped()
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        if case .error = sut.status {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected error status")
        }
        XCTAssertNotNil(sut.errorMessage)
    }
}
```

## Critical Rules (Preserved from TCA)

### 1. Animation State Rule ⚠️
**UNCHANGED**: Animation state MUST be in `@State` (View), NEVER in ViewModel `@Published`

```swift
// ❌ WRONG - Animation in ViewModel
class LoginViewModel: ObservableObject {
    @Published var buttonScale: CGFloat = 1.0  // NO!
}

// ✅ CORRECT - Animation in View
struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    @State private var buttonScale: CGFloat = 1.0  // YES!
}
```

### 2. Business State in ViewModel
- ViewModel contains business state ONLY
- NO animation values (CGFloat/Double/Angle)
- NO transient UI state (focus, drag positions)
- Pure Swift types (Equatable for testing)

### 3. Dependency Injection
- Inject UseCases (NOT Repositories) into ViewModel
- Use Resolver for global services
- Provide mock dependencies for testing

### 4. Testing
- Test ViewModel logic (business state changes)
- Mock all dependencies
- Use async/await test patterns
- Test both success and failure paths

## Theme System with MVVM

```swift
// AppViewModel (replaces AppState/AppAction/AppReducer/AppEnvironment)
final class AppViewModel: ObservableObject {
    @Published private(set) var currentThemeId: String = "default_light"
    @Published private(set) var availableThemes: [String] = []
    
    private let themeService: ThemeServiceProtocol
    
    init(themeService: ThemeServiceProtocol) {
        self.themeService = themeService
    }
    
    func appLaunched() {
        Task {
            let savedId = await themeService.loadSavedTheme()
            await MainActor.run { currentThemeId = savedId }
            await loadAvailableThemes()
        }
    }
    
    func themeSelected(_ themeId: String) {
        Task {
            await themeService.activateTheme(id: themeId)
            await MainActor.run { currentThemeId = themeId }
            await themeService.saveTheme(id: themeId)
        }
    }
    
    private func loadAvailableThemes() async {
        let themes = await themeService.getAvailableThemes()
        await MainActor.run {
            availableThemes = themes.map(\.id)
        }
    }
}

// View usage (SAME as TCA)
struct AppView: View {
    @StateObject var appViewModel: AppViewModel
    @StateObject var themeService: ThemeService
    
    var body: some View {
        ContentView()
            .environment(\.theme, themeService.getTheme(id: appViewModel.currentThemeId) ?? .defaultLight)
            .onAppear { appViewModel.appLaunched() }
    }
}
```

## Files to Update

### Core Documentation (15 files)
1. ✅ `architecture.json` - MVVM layers
2. ✅ `presentation_patterns.json` - ViewModel patterns
3. ✅ `state_management.json` - @Published + Combine
4. ✅ `ai_rules.json` - ViewModel validation
5. ✅ `animation_guidelines.json` - Remove TCA Store
6. ✅ `di.json` - ViewModel DI
7. ✅ `testing.json` - ViewModel tests
8. ✅ `theme_system.json` - Theme with ViewModel
9. ⏭️ `networking.json` - Keep (no changes)
10. ⏭️ `storage.json` - Keep (no changes)
11. ⏭️ `security.json` - Keep (no changes)
12. ⏭️ `design_tokens.json` - Keep (no changes)

### Templates (5 files)
13. ✅ `templates/mvvm_screen.swift.json` - NEW (replaces tca_screen)
14. ✅ `templates/viewmodel.swift.json` - NEW
15. ❌ `templates/tca_screen.swift.json` - DELETE
16. ❌ `templates/tca_reducer.swift.json` - DELETE
17. ⏭️ `templates/usecase.swift.json` - Keep
18. ⏭️ `templates/repository.swift.json` - Keep
19. ⏭️ `templates/theme_manager.swift.json` - Keep

### References
20. ✅ `manifest.json` - Update file descriptions
21. ✅ `.github/copilot-instructions.md` - MVVM guidance

## Validation Checklist

After migration, verify:

### Architecture
- ✓ Presentation → Domain ← Data dependency flow
- ✓ Domain layer has NO framework imports (except Foundation)
- ✓ ViewModel contains business state ONLY
- ✓ Animation state in @State (View), NOT ViewModel

### ViewModel
- ✓ Is class conforming to ObservableObject
- ✓ Uses @Published for business state
- ✓ NO animation values (CGFloat/Double/Angle)
- ✓ Methods replace Action enum
- ✓ Injects UseCases (NOT Repositories)
- ✓ Async/await or Combine for side effects

### View
- ✓ Uses @StateObject or @ObservedObject for ViewModel
- ✓ Uses @State for animations
- ✓ Accesses viewModel properties directly
- ✓ Calls viewModel methods for actions
- ✓ NO business logic in View

### Testing
- ✓ ViewModel unit tests
- ✓ Mock dependencies
- ✓ Test @Published state changes
- ✓ Async/await test patterns

### Documentation
- ✓ All TCA references removed
- ✓ MVVM patterns documented
- ✓ Templates updated
- ✓ Examples provided

## Execution Timeline

### Today (November 1, 2025)
- [x] Read all files
- [ ] Create MIGRATION_PLAN.md
- [ ] Update documentation files (8 files)
- [ ] Create new templates (2 files)
- [ ] Delete old templates (2 files)
- [ ] Update references (2 files)
- [ ] Commit and push

### Next Steps (Future)
- [ ] Create sample MVVM project
- [ ] Add comprehensive tests
- [ ] Validate with real iOS project

## Success Criteria

✅ **Migration Complete When**:
1. All TCA references removed from documentation
2. MVVM patterns fully documented
3. New templates created and validated
4. Animation rules preserved (@State in View)
5. Clean Architecture layers maintained
6. Testing patterns updated
7. All files committed and pushed

## Notes

- This is a **documentation repository** (no actual iOS code)
- Purpose: Provide AI agents with foundation patterns
- Migration applies to documentation/templates ONLY
- Real iOS projects will use these as reference

---

**Last Updated**: November 1, 2025  
**Status**: In Progress  
**Next Action**: Update architecture.json

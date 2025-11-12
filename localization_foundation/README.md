# Localization Foundation - Multi-Platform i18n Context

Multi-platform localization (i18n) context for AI-driven code generation. Supports iOS, Android, and Flutter with clear pipelines for both **new projects** (from scratch) and **existing projects** (adding new text).

## 📁 Folder Structure

```
localization_foundation/
├── manifest.json                          # Overview & file guide (START HERE)
├── shared/                                # Platform-agnostic patterns
│   ├── architecture.json                  # Localization architecture principles
│   ├── best_practices.json                # Key naming, plurals, ICU, pitfalls
│   ├── pipeline_new_project.json          # NEW project: setup from scratch (10 steps)
│   └── pipeline_add_text.json             # EXISTING project: add new text (6 steps)
├── ios/                                   # iOS-specific (SwiftGen + MVVM)
│   └── ios_localization.json              # iOS implementation details
├── android/                               # Android-specific (strings.xml)
│   └── android_localization.json          # Android implementation details
├── flutter/                               # Flutter-specific (intl + ARB)
│   └── flutter_localization.json          # Flutter implementation details
└── templates/                             # Code generation templates
    ├── ios_localizable_strings.json       # iOS Localizable.strings template
    ├── android_strings_xml.json           # Android strings.xml template
    ├── flutter_arb.json                   # Flutter ARB file template
    └── flutter_l10n_yaml.json             # Flutter l10n.yaml config
```

## 🚀 Quick Start

### For AI Agents

**Scenario 1: New project WITHOUT localization**
```
Read order:
1. manifest.json (overview)
2. shared/architecture.json
3. shared/best_practices.json
4. shared/pipeline_new_project.json (CRITICAL - 10 step pipeline)
5. Platform-specific file (ios/android/flutter)
6. Templates for code generation
```

**Scenario 2: Existing project WITH localization, add new text**
```
Read order:
1. shared/pipeline_add_text.json (quick 6-step workflow)
2. shared/best_practices.json (key naming reference)
3. Platform-specific file (for syntax)
```

### For Developers

**iOS (SwiftGen + MVVM)**
- Library: SwiftGen + Localizable.strings
- State: `AppViewModel @Published currentLocale: String`
- Usage: `Text(L10n.Login.title)` (type-safe)

**Android (strings.xml)**
- Library: Native strings.xml + resource qualifiers
- State: `ViewModel StateFlow<String> currentLocale`
- Usage: `getString(R.string.login_title)` or `@string/login_title`

**Flutter (intl + ARB)**
- Library: intl + ARB files + l10n.yaml
- State: `Provider<Locale>` or `Riverpod StateNotifier<Locale>`
- Usage: `AppLocalizations.of(context)!.loginTitle`

## 📋 Common Workflows

### iOS: Add localization to new project
```
1. Install SwiftGen: brew install swiftgen
2. Create Resources/Localization/en.lproj/Localizable.strings
3. Add keys: "login.title" = "Login";
4. Configure swiftgen.yml
5. Run: swiftgen
6. Use: Text(L10n.Login.title)
```

### Android: Add localization to new project
```
1. Create res/values/strings.xml (English)
2. Add keys: <string name="login_title">Login</string>
3. Create res/values-vi/strings.xml (Vietnamese)
4. Translate values
5. Build project (generates R.string.*)
6. Use: getString(R.string.login_title)
```

### Flutter: Add localization to new project
```
1. Add dependencies: intl, flutter_localizations
2. Create l10n.yaml in project root
3. Create lib/l10n/app_en.arb with keys
4. Run: flutter gen-l10n
5. Setup MaterialApp with AppLocalizations
6. Use: AppLocalizations.of(context)!.loginTitle
```

### Add new text to existing project (any platform)
```
1. Identify text: "Welcome to Dashboard"
2. Choose key: home.title (iOS), home_title (Android), homeTitle (Flutter)
3. Add to base language file (en)
4. Add translations to other languages (vi, ja)
5. Regenerate code (swiftgen / gradle build / flutter gen-l10n)
6. Use in code
```

## 🎯 Key Features

- ✅ **Multi-platform**: iOS, Android, Flutter
- ✅ **Two pipelines**: New project (10 steps) vs Add text (6 steps)
- ✅ **Best practices**: Key naming, plurals, RTL, ICU MessageFormat
- ✅ **MVVM/Provider integration**: Locale state management
- ✅ **Code generation**: SwiftGen (iOS), R.string (Android), intl (Flutter)
- ✅ **Dynamic switching**: Runtime language change without restart
- ✅ **Templates**: Ready-to-use translation file templates

## 📖 Documentation

Start with `manifest.json` for complete file guide and when-to-read recommendations.

**Core files:**
- `shared/architecture.json` - Platform-agnostic architecture
- `shared/best_practices.json` - Key naming, plurals, ICU, pitfalls
- `shared/pipeline_new_project.json` - NEW project setup (10 steps)
- `shared/pipeline_add_text.json` - Add text to EXISTING project (6 steps)

**Platform-specific:**
- `ios/ios_localization.json` - SwiftGen, MVVM, Bundle.setLanguage
- `android/android_localization.json` - strings.xml, resource qualifiers
- `flutter/flutter_localization.json` - intl, ARB, Provider/Riverpod

## 🔥 AI Prompt Examples

**New iOS project:**
```
I need to add localization to my iOS project from scratch. The project uses MVVM and 
currently has hardcoded strings. Help me set up SwiftGen and replace all hardcoded 
strings with localization keys. Target languages: English, Vietnamese.
```

**Existing Flutter project:**
```
My Flutter project already uses intl for localization. I need to add a new screen 
"DashboardScreen" with title "Welcome to Dashboard" and button "Refresh". Help me 
add the localization keys and use them in the widget.
```

**Android new feature:**
```
I'm adding a biometric login feature to my Android app (already has localization). 
Need translations for: "Enable Biometric Login", "Authenticate with Face ID", 
"Authentication failed". Add keys and use them in the Fragment.
```

## ⚠️ Critical Rules (for AI)

1. **ALWAYS** read `shared/pipeline_new_project.json` for NEW projects
2. **ALWAYS** read `shared/pipeline_add_text.json` for EXISTING projects
3. **NEVER** hardcode strings after localization setup
4. **ALWAYS** use type-safe access (SwiftGen L10n, R.string, AppLocalizations)
5. **ALWAYS** add translations for ALL supported languages
6. **FOLLOW** platform naming conventions (dot.notation, snake_case, camelCase)

## 🤝 Integration with ios_foundation

This localization context complements `ios_foundation` MVVM patterns:
- `AppViewModel` holds `@Published currentLocale: String`
- Follows MVVM state management principles
- Integrates with theme system (both use AppViewModel)
- Compatible with animation guidelines (@State for UI, @Published for business)

## 📝 License

MIT - Same as parent repository

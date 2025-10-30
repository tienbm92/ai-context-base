Pod::Spec.new do |s|
  s.name             = 'AIContextIOS'
  s.version          = '1.0.0'
  s.summary          = 'AI-ready iOS project foundation with TCA architecture, design system, and dynamic theme support'
  
  s.description      = <<-DESC
    AIContextIOS provides a comprehensive set of guidelines, patterns, and code templates 
    for building iOS applications with The Composable Architecture (TCA).
    
    Features:
    • Clean Architecture with TCA (The Composable Architecture) pattern
    • Complete design system with dynamic theming (Christmas, Tết, Halloween themes)
    • Animation guidelines optimized for 60fps performance
    • Networking, storage, and security best practices
    • AI-optimized JSON documentation for intelligent code generation
    • Pre-built Swift templates for screens, reducers, and use cases
    • Theme system with time-limited seasonal/cultural themes
    • Comprehensive validation rules for AI code generation
    
    Perfect for:
    • Starting new iOS projects with proven architecture patterns
    • AI-assisted code generation with validated patterns
    • Team standardization and development best practices
    • Rapid prototyping with consistent, tested patterns
    • Building apps with seasonal theme support
    
    Documentation includes 15 core JSON files and 5 Swift templates, 
    all optimized for AI parsing and code generation.
  DESC

  s.homepage         = 'https://github.com/tienbm92/ai-context-base'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'TradeHub iOS Team' => 'ios@tradehub.com' }
  s.source           = { 
    :git => 'https://github.com/tienbm92/ai-context-base.git', 
    :tag => "aicontextios-#{s.version}" 
  }

  # Platform requirements
  s.ios.deployment_target = '15.0'
  s.swift_version = '5.9'
  s.cocoapods_version = '>= 1.10.0'

  # Resource files - All JSON documentation and templates
  s.resource_bundles = {
    'AIContextIOS' => [
      'ios_foundation/*.json',
      'ios_foundation/templates/*.json',
      'ios_foundation/*.md'
    ]
  }

  # If we add Swift source code later
  # s.source_files = 'ios_foundation/Sources/**/*.swift'
  # s.public_header_files = 'ios_foundation/Sources/**/*.h'

  # Framework dependencies
  s.frameworks = 'Foundation', 'SwiftUI', 'Combine'
  s.requires_arc = true
  
  # Optional: TCA dependency (uncomment if you want to enforce TCA)
  # s.dependency 'ComposableArchitecture', '~> 1.0'
  
  # Metadata for discoverability
  s.documentation_url = 'https://github.com/tienbm92/ai-context-base/tree/main/ios_foundation'
  s.social_media_url = 'https://github.com/tienbm92'
  
  # Swift and iOS versions
  s.swift_version = '5.5'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.5' }
end
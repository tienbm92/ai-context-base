import Foundation

/// AIContextIOS - AI-ready iOS project foundation
///
/// Provides access to architecture patterns, design tokens, theme definitions,
/// and code templates optimized for AI-assisted development.
public struct AIContextIOS {
    
    /// Current version of AIContextIOS
    public static let version = "1.0.0"
    
    /// Bundle containing all AIContextIOS resources
    private static let bundle: Bundle = {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(identifier: "org.cocoapods.AIContextIOS") ?? Bundle.main
        #endif
    }()
    
    // MARK: - Resource Access
    
    /// Load JSON resource from the bundle
    /// - Parameter filename: Name of the JSON file (without extension)
    /// - Returns: Parsed JSON data or nil if file not found
    public static func loadJSON<T: Codable>(_ filename: String, as type: T.Type) -> T? {
        guard let url = bundle.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("AIContextIOS: Could not find \(filename).json")
            return nil
        }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("AIContextIOS: Error decoding \(filename).json - \(error)")
            return nil
        }
    }
    
    /// Load raw JSON data
    /// - Parameter filename: Name of the JSON file (without extension)
    /// - Returns: Raw Data or nil if file not found
    public static func loadJSONData(_ filename: String) -> Data? {
        guard let url = bundle.url(forResource: filename, withExtension: "json") else {
            print("AIContextIOS: Could not find \(filename).json")
            return nil
        }
        return try? Data(contentsOf: url)
    }
    
    /// Get path to a resource file
    /// - Parameters:
    ///   - filename: Name of the file
    ///   - extension: File extension
    /// - Returns: File URL or nil if not found
    public static func resourcePath(for filename: String, extension: String = "json") -> URL? {
        return bundle.url(forResource: filename, withExtension: `extension`)
    }
    
    // MARK: - Quick Access Properties
    
    /// Load the manifest.json file containing all metadata
    public static var manifest: [String: Any]? {
        guard let data = loadJSONData("manifest") else { return nil }
        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }
    
    /// Get list of available architecture files
    public static var availableResources: [String] {
        let resourceNames = [
            "manifest", "architecture", "presentation_patterns", "state_management",
            "animation_guidelines", "ai_rules", "theme_system", "themes_data",
            "design_tokens", "networking", "storage", "security", "testing", "di"
        ]
        
        return resourceNames.filter { resourcePath(for: $0) != nil }
    }
    
    /// Get list of available template files
    public static var availableTemplates: [String] {
        let templateNames = [
            "tca_screen.swift", "tca_reducer.swift", "usecase.swift", 
            "repository.swift", "theme_manager.swift"
        ]
        
        // Check in templates subdirectory
        return templateNames.compactMap { templateName in
            let name = templateName.replacingOccurrences(of: ".swift", with: "")
            return bundle.url(forResource: "templates/\(name)", withExtension: "json") != nil ? name : nil
        }
    }
}
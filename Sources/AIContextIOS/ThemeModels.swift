import Foundation
import SwiftUI

// MARK: - Theme Data Structures

/// Represents a complete theme definition
public struct AITheme: Codable, Identifiable {
    public let id: String
    public let name: String
    public let category: String
    public let availabilityPeriod: DateRange?
    public let colors: ColorPalette
    public let typography: Typography?
    public let spacing: Spacing?
    public let components: ComponentStyles?
    public let assets: ThemeAssets?
    
    public struct DateRange: Codable {
        public let start: String
        public let end: String
        
        public var isActive: Bool {
            let formatter = ISO8601DateFormatter()
            guard let startDate = formatter.date(from: start),
                  let endDate = formatter.date(from: end) else {
                return true
            }
            let now = Date()
            return now >= startDate && now <= endDate
        }
    }
    
    public struct ColorPalette: Codable {
        public let primary: String
        public let secondary: String
        public let accent: String
        public let success: String
        public let error: String
        public let warning: String
        public let background: String
        public let surface: String
        public let textPrimary: String
        public let textSecondary: String
        public let border: String
    }
    
    public struct Typography: Codable {
        public let fontFamily: String
        public let h1: FontStyle
        public let h2: FontStyle
        public let h3: FontStyle
        public let h4: FontStyle
        public let body1: FontStyle
        public let body2: FontStyle
        public let caption: FontStyle
        
        public struct FontStyle: Codable {
            public let size: Double
            public let weight: Int
            public let lineHeight: Double
        }
    }
    
    public struct Spacing: Codable {
        public let xs: Double
        public let sm: Double
        public let md: Double
        public let lg: Double
        public let xl: Double
        public let xxl: Double
    }
    
    public struct ComponentStyles: Codable {
        public let button: ButtonStyle
        public let card: CardStyle
        
        public struct ButtonStyle: Codable {
            public let borderRadius: Double
            public let paddingHorizontal: Double
            public let paddingVertical: Double
            public let minHeight: Double
        }
        
        public struct CardStyle: Codable {
            public let borderRadius: Double
            public let padding: Double
            public let elevation: Double
        }
    }
    
    public struct ThemeAssets: Codable {
        public let backgroundPattern: String?
        public let appIconVariant: String
        public let decorativeElements: [String]
    }
}

// MARK: - Themes Data Container

public struct AIThemesData: Codable {
    public let themes: [AITheme]
    
    /// Get theme by ID
    public func theme(id: String) -> AITheme? {
        return themes.first { $0.id == id }
    }
    
    /// Get available themes (not expired)
    public var availableThemes: [AITheme] {
        return themes.filter { $0.availabilityPeriod?.isActive ?? true }
    }
    
    /// Get themes by category
    public func themes(category: String) -> [AITheme] {
        return themes.filter { $0.category == category }
    }
}

// MARK: - Design Tokens

public struct AIDesignTokens: Codable {
    public let colors: Colors
    public let typography: Typography
    public let spacing: Spacing
    public let components: Components
    
    public struct Colors: Codable {
        public let lightMode: ColorMode
        public let darkMode: ColorMode
        
        public struct ColorMode: Codable {
            public let primary: String
            public let secondary: String
            public let success: String
            public let error: String
            public let warning: String
            public let background: String
            public let surface: String
            public let textPrimary: String
            public let textSecondary: String
            public let border: String
        }
    }
    
    public struct Typography: Codable {
        public let fontFamily: String
        public let sizes: [String: FontSize]
        
        public struct FontSize: Codable {
            public let size: Int
            public let weight: Int
            public let lineHeight: Int
        }
    }
    
    public struct Spacing: Codable {
        public let xs: Int
        public let sm: Int
        public let md: Int
        public let lg: Int
        public let xl: Int
        public let xxl: Int
    }
    
    public struct Components: Codable {
        public let button: ComponentStyle
        public let card: ComponentStyle
        public let input: ComponentStyle
        
        public struct ComponentStyle: Codable {
            public let borderRadius: Int
            public let padding: Int?
            public let paddingHorizontal: Int?
            public let paddingVertical: Int?
            public let minHeight: Int?
            public let borderWidth: Int?
            public let elevation: Int?
        }
    }
}

// MARK: - AIContextIOS Extensions

extension AIContextIOS {
    
    /// Load all available themes
    public static var themes: AIThemesData? {
        return loadJSON("themes_data", as: AIThemesData.self)
    }
    
    /// Load design tokens
    public static var designTokens: AIDesignTokens? {
        return loadJSON("design_tokens", as: AIDesignTokens.self)
    }
    
    /// Get specific theme by ID
    public static func theme(id: String) -> AITheme? {
        return themes?.theme(id: id)
    }
    
    /// Get available themes (not expired)
    public static var availableThemes: [AITheme] {
        return themes?.availableThemes ?? []
    }
}
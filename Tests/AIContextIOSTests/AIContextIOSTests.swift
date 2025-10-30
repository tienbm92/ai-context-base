import XCTest
@testable import AIContextIOS

final class AIContextIOSTests: XCTestCase {
    
    func testVersion() {
        XCTAssertEqual(AIContextIOS.version, "1.0.0")
    }
    
    func testManifestLoading() {
        let manifest = AIContextIOS.manifest
        XCTAssertNotNil(manifest, "Manifest should be loadable")
        
        if let manifest = manifest {
            XCTAssertNotNil(manifest["id"], "Manifest should have ID")
            XCTAssertNotNil(manifest["version"], "Manifest should have version")
        }
    }
    
    func testAvailableResources() {
        let resources = AIContextIOS.availableResources
        XCTAssertFalse(resources.isEmpty, "Should have available resources")
        XCTAssertTrue(resources.contains("manifest"), "Should contain manifest")
        XCTAssertTrue(resources.contains("theme_system"), "Should contain theme_system")
    }
    
    func testThemeLoading() {
        let themesData = AIContextIOS.themes
        XCTAssertNotNil(themesData, "Themes data should be loadable")
        
        if let themesData = themesData {
            XCTAssertFalse(themesData.themes.isEmpty, "Should have themes")
            
            // Test specific themes
            let defaultLight = themesData.theme(id: "default_light")
            XCTAssertNotNil(defaultLight, "Should have default_light theme")
            
            let christmasTheme = themesData.theme(id: "christmas_2024")
            XCTAssertNotNil(christmasTheme, "Should have christmas_2024 theme")
        }
    }
    
    func testDesignTokensLoading() {
        let designTokens = AIContextIOS.designTokens
        XCTAssertNotNil(designTokens, "Design tokens should be loadable")
        
        if let tokens = designTokens {
            XCTAssertEqual(tokens.typography.fontFamily, "SF Pro Text")
            XCTAssertEqual(tokens.spacing.md, 16)
        }
    }
    
    func testAvailableThemes() {
        let availableThemes = AIContextIOS.availableThemes
        XCTAssertFalse(availableThemes.isEmpty, "Should have available themes")
        
        // Should always have default themes
        let hasDefaultLight = availableThemes.contains { $0.id == "default_light" }
        let hasDefaultDark = availableThemes.contains { $0.id == "default_dark" }
        
        XCTAssertTrue(hasDefaultLight, "Should have default_light theme")
        XCTAssertTrue(hasDefaultDark, "Should have default_dark theme")
    }
    
    func testResourcePathAccess() {
        let manifestPath = AIContextIOS.resourcePath(for: "manifest")
        XCTAssertNotNil(manifestPath, "Should be able to get path to manifest")
        
        let themesPath = AIContextIOS.resourcePath(for: "themes_data")
        XCTAssertNotNil(themesPath, "Should be able to get path to themes_data")
    }
    
    func testJSONDataLoading() {
        let manifestData = AIContextIOS.loadJSONData("manifest")
        XCTAssertNotNil(manifestData, "Should be able to load manifest data")
        
        if let data = manifestData {
            XCTAssertTrue(data.count > 0, "Manifest data should not be empty")
        }
    }
}
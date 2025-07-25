import Foundation

/// App configuration constants
struct Config {
    
    // MARK: - API Configuration
    
    /// Base URL for the backend API
    static let apiBaseURL: String = {
        #if DEBUG
        return "http://127.0.0.1:8002" // Local development
        #else
        return "https://your-production-api.com" // Production URL
        #endif
    }()
    
    /// API key for backend authentication
    static let apiKey: String = {
        // TODO: Move to secure storage or environment variables
        return "test_api_key"
    }()
    
    // MARK: - App Information
    
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
}
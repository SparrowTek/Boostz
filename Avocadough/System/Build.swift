//
//  Build.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 12/10/23.
//

import Foundation

final class Build: Sendable {
    /// Build environemnt
    enum Environment: String {
        case development = "DEVELOPMENT"
        case production = "PRODUCTION"
    }
    
    /// Shared build
    static let shared = Build()
    
    /// Current environment
    let environment: Environment
    
    /// Namespace
//    let nameSpace =  "com.sparrowtek.vocadough"
//
//    /// Shared app group
//    let appGroup = "group.com.sparrowtek.avocadough"
    
    /// Version / Build number
    let version: String
    let build: String
    
    /// Is this a production environment
    var isProduction: Bool {
        environment == .production
    }
    
    /// Is this a development environment
    var isDevelopment: Bool {
        environment != .production
    }
    
    private init() {
        guard let bundle = Bundle.main.infoDictionary else { fatalError("Could not load main bundle") }
        guard let environmentString = bundle["AvocadoughEnv"] as? String else { fatalError("Environement not set in bundle") }
        guard let versionString = bundle["CFBundleShortVersionString"] as? String else { fatalError("version not set in bundle") }
        guard let buildString = bundle["CFBundleVersion"] as? String else { fatalError("build not set in bundle") }
        guard let environment = Environment(rawValue: environmentString) else { fatalError("Environment could not be set") }
        
        // Setup environment
        self.environment = environment
        
        /// Setup versions
        version = versionString
        build = buildString
    }
}

//
//  Build.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/10/23.
//

import Foundation
import AlbyKit

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
//    let nameSpace =  "com.sparrowtek.boostz"
//
//    /// Shared app group
//    let appGroup = "group.com.sparrowtek.boostz"
    
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
        guard let environmentString = bundle["BoostzEnv"] as? String else { fatalError("Environement not set in bundle") }
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

extension Build.Environment {

    /// Convert build environment to AlbyKit API environment
    var alby: API {
//        switch self {
//        case .development:
//            return .dev
//        case .production:
//            return .prod
//        }
        // TODO: get dev environment working
        .prod
    }
}


//
//  Build+Constants.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 12/10/23.
//

import Foundation

extension Build {
    struct Constants {
        struct UserDefault {
            static let colorScheme = "com.sparrowtek.avocadough.userDefaults.colorScheme"
            static let lightThemeColor = "com.sparrowtek.avocadough.userDefaults.lightThemeColor"
            static let darkThemeColor = "com.sparrowtek.avocadough.userDefaults.darkThemeColor"
        }
        
        struct Theme {
            static let light = "com.sparrowtek.avocadough.theme.light"
            static let dark = "com.sparrowtek.avocadough.theme.dark"
        }
    }
}

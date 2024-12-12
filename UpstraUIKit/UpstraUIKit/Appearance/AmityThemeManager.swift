//
//  AmityThemeManager.swift
//  AmityUIKit
//
//  Created by Nontapat Siengsanor on 7/8/2563 BE.
//  Copyright © 2563 Amity Communication. All rights reserved.
//

import UIKit

class AmityThemeManager {
    private var lightTheme = AmityTheme()
    private var darkTheme = AmityTheme()
    
    private var interfaceStyle: AmityInterfaceStyle = .light {
        didSet {
            // Log for debugging
            print("Interface style changed to: \(interfaceStyle)")
        }
    }
    
    private var currentTheme: AmityTheme {
        return interfaceStyle == .dark ? darkTheme : lightTheme
    }
    
    private static let defaultManager = AmityThemeManager()
    
    static var currentTheme: AmityTheme {
        print("Returning current theme: \(defaultManager.currentTheme)")
        return defaultManager.currentTheme
    }
    
    static func set(theme: AmityTheme, for interfaceStyle: AmityInterfaceStyle = .light) {
        print("Setting theme for \(interfaceStyle)")
        if interfaceStyle == .dark {
            defaultManager.darkTheme = theme
        } else {
            defaultManager.lightTheme = theme
        }
        
        // Log to confirm the theme is updated
        print("Theme set successfully for \(interfaceStyle)")
    }
    
    /// Update the interface style
    static func updateInterfaceStyle(_ style: AmityInterfaceStyle) {
        print("Updating interface style to: \(style)")
        defaultManager.interfaceStyle = style
    }
}

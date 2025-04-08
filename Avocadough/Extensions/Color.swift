//
//  Color.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 12/10/23.
//

import SwiftUI

extension Color {
    private func luminance(in environment: EnvironmentValues) -> Double {
        let colorResolved = self.resolve(in: environment)
        let red = Double(colorResolved.red)
        let green = Double(colorResolved.green)
        let blue = Double(colorResolved.blue)
        
        /// These coefficients are part of the standard for defining luminance developed by the International Commission on Illumination (CIE). They're used in various color spaces and standards, including sRGB, which is commonly used in digital imaging and displays.
        /// Using these specific values allows for a calculation of luminance that closely matches human visual perception, making it a reliable method for determining how bright or dark a color appears to the human eye.
        let redCoefficient = 0.2126
        let greenCoefficient = 0.7152
        let blueCoefficient = 0.0722
        
        return redCoefficient * red + greenCoefficient * green + blueCoefficient * blue
    }

    static func adaptiveColor(for background: Color, lightColorToDisplay light: Color, darkColorToDisplay dark: Color, in environment: EnvironmentValues) -> Color {
        background.luminance(in: environment) > 0.5 ? dark : light
    }
}

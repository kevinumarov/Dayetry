import SwiftUI

enum AssetManager {
    enum Icons {
        static let energy = "Dashboard"
        static let arsenal = "Cube"
        static let calendar = "Calendar"
        // Add your icon names here
        static let placeholder = "placeholder"
    }
    
    enum Images {
        // Add your image names here
        static let placeholder = "placeholder"
    }
    
    enum Fonts {
        static let regular = "PPMori-Regular"
        static let semiBold = "PPMori-SemiBold"
        static let extraLight = "PPMori-Extralight"
        // Add more as needed
    }
}

// MARK: - Font Extensions
extension Font {
    static func ppmoriRegular(_ size: CGFloat) -> Font {
        .custom(AssetManager.Fonts.regular, size: size)
    }
    static func ppmoriSemiBold(_ size: CGFloat) -> Font {
        .custom(AssetManager.Fonts.semiBold, size: size)
    }
    static func ppmoriExtraLight(_ size: CGFloat) -> Font {
        .custom(AssetManager.Fonts.extraLight, size: size)
    }
}

// MARK: - Image Extensions
extension Image {
    static func asset(_ name: String) -> Image {
        Image(name)
    }
    
    static func icon(_ name: String) -> Image {
        Image(name)
    }
} 

import SwiftUI
import UIKit

extension Color: Codable {
    private enum CodingKeys: String, CodingKey {
        case red, green, blue, alpha
    }

    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//
//        // Convert Color to UIColor to get RGBA components
//        let uiColor = UIColor(self)
//
//        var red: CGFloat = 0
//        var green: CGFloat = 0
//        var blue: CGFloat = 0
//        var alpha: CGFloat = 0
//
//        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
//
//        try container.encode(red, forKey: .red)
//        try container.encode(green, forKey: .green)
//        try container.encode(blue, forKey: .blue)
//        try container.encode(alpha, forKey: .alpha)
    }

    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        let red = try container.decode(CGFloat.self, forKey: .red)
//        let green = try container.decode(CGFloat.self, forKey: .green)
//        let blue = try container.decode(CGFloat.self, forKey: .blue)
//        let alpha = try container.decode(CGFloat.self, forKey: .alpha)
//
//        self = Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
        self = Color.red
    }
}

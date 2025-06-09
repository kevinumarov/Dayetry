import SwiftUI

struct EnergyModuleCard: View {
    let iconName: String
    let title: String
    let subtitle: String
    let valueText: String
    let progress: Double // 0.0 to 1.0
    let timeText: String
    let valueIsCurrency: Bool
    let valueUnit: String?
    let secondaryValue: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemGray6))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image.icon(iconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.custom("PPMori-SemiBold", size: 20))
                        .foregroundColor(.black)
                    Text(subtitle)
                        .font(.custom("PPMori-Regular", size: 15))
                        .foregroundColor(Color(.systemGray))
                }
                Spacer()
                Image.icon("Info")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundColor(Color(.systemGray3))
            }
            if valueIsCurrency {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(valueText)
                        .font(.custom("PPMori-SemiBold", size: 22))
                        .foregroundColor(.black)
                    if let unit = valueUnit {
                        Text(unit)
                            .font(.custom("PPMori-Regular", size: 15))
                            .foregroundColor(Color(.systemGray))
                    }
                    Spacer()
                    if let secondary = secondaryValue {
                        Text(secondary)
                            .font(.custom("PPMori-Regular", size: 13))
                            .foregroundColor(Color(.systemGray))
                    }
                }
            } else {
                HStack {
                    Text(valueText)
                        .font(.custom("PPMori-SemiBold", size: 22))
                        .foregroundColor(.black)
                    Spacer()
                    Text(timeText)
                        .font(.custom("PPMori-Regular", size: 13))
                        .foregroundColor(Color(.systemGray))
                }
            }
            ProgressView(value: progress)
                .progressViewStyle(EnergyProgressStyle())
                .frame(height: 12)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.25))
                .background(.ultraThinMaterial)
                .blur(radius: 0.5)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1.5)
                )
        )
        .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
    }
}

struct EnergyProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color(.systemGray5))
            Capsule()
                .fill(Color(hex: "381E72"))
                .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * 240)
            HStack {
                ForEach(0..<6) { i in
                    Spacer()
                    Circle()
                        .fill(Color.white.opacity(0.7))
                        .frame(width: 6, height: 6)
                }
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    VStack(spacing: 24) {
        EnergyModuleCard(iconName: "mentalEnergy", title: "Mental Energy", subtitle: "You are great to go", valueText: "100%", progress: 1.0, timeText: "39min", valueIsCurrency: false, valueUnit: nil, secondaryValue: nil)
        EnergyModuleCard(iconName: "physicalEnergy", title: "Physical Energy", subtitle: "Your body is ready to conquer the world", valueText: "100%", progress: 1.0, timeText: "39min", valueIsCurrency: false, valueUnit: nil, secondaryValue: nil)
        EnergyModuleCard(iconName: "financialEnergy", title: "Financial Energy", subtitle: "Your daily expense must make 15,000 KRW", valueText: "15,000", progress: 0.9, timeText: "5,000 KRW", valueIsCurrency: true, valueUnit: "KRW", secondaryValue: "5,000 KRW")
    }
    .padding()
    .background(Color(hex: "EEF2FF"))
} 
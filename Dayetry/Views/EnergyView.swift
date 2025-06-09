import SwiftUI

struct EnergyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                Text("Dayetry Energy")
                    .font(.custom("PPMori-SemiBold", size: 36))
                    .foregroundColor(.black)
                    .padding(.top, 24)
                    .padding(.horizontal, 16)
                VStack(spacing: 24) {
                    EnergyModuleCard(
                        iconName: "mentalEnergy",
                        title: "Mental Energy",
                        subtitle: "You are great to go",
                        valueText: "100%",
                        progress: 1.0,
                        timeText: "39min",
                        valueIsCurrency: false,
                        valueUnit: nil,
                        secondaryValue: nil
                    )
                    EnergyModuleCard(
                        iconName: "physicalEnergy",
                        title: "Physical Energy",
                        subtitle: "Your body is ready to conquer the world",
                        valueText: "100%",
                        progress: 1.0,
                        timeText: "39min",
                        valueIsCurrency: false,
                        valueUnit: nil,
                        secondaryValue: nil
                    )
                    EnergyModuleCard(
                        iconName: "financialEnergy",
                        title: "Financial Energy",
                        subtitle: "Your daily expense must make 15,000 KRW",
                        valueText: "15,000",
                        progress: 0.9,
                        timeText: "5,000 KRW",
                        valueIsCurrency: true,
                        valueUnit: "KRW",
                        secondaryValue: "5,000 KRW"
                    )
                }
                .padding(.horizontal, 8)
            }
        }
        .background(Color(hex: "EEF2FF").ignoresSafeArea())
    }
}

#Preview {
    EnergyView()
} 
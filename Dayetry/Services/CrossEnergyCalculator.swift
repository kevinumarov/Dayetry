import Foundation

class CrossEnergyCalculator {
    func applyCrossEnergyInfluences(
        mental: Double,
        physical: Double,
        financial: Double,
        emotional: Double,
        config: [String: CrossEnergyDependency]
    ) -> (mental: Double, physical: Double, financial: Double, emotional: Double) {
        
        var adjustedMental = mental
        var adjustedPhysical = physical
        var adjustedFinancial = financial
        var adjustedEmotional = emotional
        
        // Apply cross-energy dependencies
        for (key, dependency) in config {
            switch key {
            case "mental_to_emotional":
                if mental < dependency.threshold {
                    adjustedEmotional += dependency.impact
                }
            case "physical_to_mental":
                if physical < dependency.threshold {
                    adjustedMental += dependency.impact
                }
            case "financial_to_emotional":
                if financial < dependency.threshold {
                    adjustedEmotional += dependency.impact
                }
            case "emotional_to_mental":
                if emotional < dependency.threshold {
                    adjustedMental += dependency.impact
                }
            default:
                break
            }
        }
        
        return (
            mental: max(0, min(100, adjustedMental)),
            physical: max(0, min(100, adjustedPhysical)),
            financial: max(0, min(100, adjustedFinancial)),
            emotional: max(0, min(100, adjustedEmotional))
        )
    }
}

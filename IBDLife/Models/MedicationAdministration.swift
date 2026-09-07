import Foundation

enum AdministrationForm: String, CaseIterable, Identifiable, Hashable {

    case autoInjector = "Auto-injector pen"
    case prefilledSyringe = "Pre-filled syringe"
    case ivInfusion = "IV infusion"

    case oralTablet = "Oral tablet"
    case oralCapsule = "Oral capsule"

    case oralNutritionDrink = "Oral nutrition drink"

    case rectalSuppository = "Rectal suppository"
    case rectalEnema = "Rectal enema"
    case rectalFoam = "Rectal foam"

    var id: String {
        rawValue
    }

    var icon: String {
        switch self {
        case .autoInjector:
            return "💉"

        case .prefilledSyringe:
            return "💉"

        case .ivInfusion:
            return "🏥"

        case .oralTablet:
            return "💊"

        case .oralCapsule:
            return "💊"

        case .oralNutritionDrink:
            return "🥤"

        case .rectalSuppository:
            return "🧴"

        case .rectalEnema:
            return "💧"

        case .rectalFoam:
            return "🫧"
        }
    }

    var description: String {
        switch self {

        case .autoInjector:
            return "A prefilled device designed for subcutaneous injection."

        case .prefilledSyringe:
            return "A ready-to-use syringe for subcutaneous injection."

        case .ivInfusion:
            return "Medication administered intravenously by a healthcare professional."

        case .oralTablet:
            return "Taken by mouth as a tablet."

        case .oralCapsule:
            return "Taken by mouth as a capsule."

        case .oralNutritionDrink:
            return "A nutrition formula taken by mouth as a liquid drink."

        case .rectalSuppository:
            return "A medication inserted rectally for local treatment."

        case .rectalEnema:
            return "A liquid medication delivered rectally."

        case .rectalFoam:
            return "A foam medication delivered rectally."
        }
    }
}

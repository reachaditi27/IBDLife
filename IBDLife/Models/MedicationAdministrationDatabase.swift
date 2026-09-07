import Foundation

struct MedicationAdministrationDatabase {

    static func forms(
        for medication: String
    ) -> [AdministrationForm] {

        let name = medication
            .lowercased()
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        switch name {

        // MARK: - Adalimumab products

        case "humira",
             "hyrimoz",
             "adalimumab",
             "adalimumab-adaz":

            return [
                .autoInjector,
                .prefilledSyringe
            ]

        // MARK: - Infliximab

        case "remicade",
             "infliximab",
             "inflectra",
             "renflexis":

            return [
                .ivInfusion
            ]

        // MARK: - Stelara

        case "stelara",
             "ustekinumab":

            return [
                .ivInfusion,
                .prefilledSyringe
            ]

        // MARK: - Entyvio

        case "entyvio",
             "vedolizumab":

            return [
                .ivInfusion,
                .prefilledSyringe,
                .autoInjector
            ]

        // MARK: - Skyrizi

        case "skyrizi",
             "risankizumab",
             "risankizumab-rzaa":

            return [
                .ivInfusion,
                .prefilledSyringe,
                .autoInjector
            ]

        // MARK: - Rinvoq

        case "rinvoq",
             "upadacitinib":

            return [
                .oralTablet
            ]

        // MARK: - Zeposia

        case "zeposia",
             "ozanimod":

            return [
                .oralCapsule
            ]

        // MARK: - Mesalamine

        case "mesalamine":

            return [
                .oralTablet,
                .oralCapsule,
                .rectalSuppository,
                .rectalEnema,
                .rectalFoam
            ]

        // MARK: - Nutrition

        case "ensure plus",
             "ensure plus nutrition shake":

            return [
                .oralNutritionDrink
            ]

        case "boost plus":

            return [
                .oralNutritionDrink
            ]

        case "modulen ibd":

            return [
                .oralNutritionDrink
            ]

        case "kate farms standard 1.4":

            return [
                .oralNutritionDrink
            ]

        // MARK: - Unknown

        default:

            return []
        }
    }
}

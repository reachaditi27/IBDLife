import Foundation

enum MedicationCategory: String, CaseIterable {
    case biologic
    case smallMolecule
    case aminosalicylate
    case immunomodulator
    case corticosteroid
    case antibiotic
    case nutrition

    var title: String {
        switch self {
        case .biologic:
            return "BIOLOGIC"
        case .smallMolecule:
            return "SMALL MOLECULE"
        case .aminosalicylate:
            return "5-ASA"
        case .immunomodulator:
            return "IMMUNOMODULATOR"
        case .corticosteroid:
            return "CORTICOSTEROID"
        case .antibiotic:
            return "ANTIBIOTIC"
        case .nutrition:
            return "NUTRITION"
        }
    }
}



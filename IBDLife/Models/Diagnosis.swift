import Foundation

enum Diagnosis: String, CaseIterable, Hashable, Codable {
    case crohns
    case ulcerativeColitis
    case microscopicColitis
    case ibdUnclassified

    var displayName: String {
        switch self {
        case .crohns:
            return "Crohn's Disease"
        case .ulcerativeColitis:
            return "Ulcerative Colitis"
        case .microscopicColitis:
            return "Microscopic Colitis"
        case .ibdUnclassified:
            return "IBD Unclassified (IBDU)"
        }
    }
}

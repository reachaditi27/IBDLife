import Foundation

enum InjectionSite:
    String,
    CaseIterable,
    Identifiable,
    Hashable, Codable {

    case leftAbdomen
    case rightAbdomen
    case leftThigh
    case rightThigh
    case leftUpperArm
    case rightUpperArm

    var id: String {
        rawValue
    }

    var title: String {

        switch self {

        case .leftAbdomen:
            return "Left abdomen"

        case .rightAbdomen:
            return "Right abdomen"

        case .leftThigh:
            return "Left thigh"

        case .rightThigh:
            return "Right thigh"

        case .leftUpperArm:
            return "Left upper arm"

        case .rightUpperArm:
            return "Right upper arm"
        }
    }

    var subtitle: String {

        switch self {

        case .leftAbdomen:
            return "2 inches to the left of your belly button"

        case .rightAbdomen:
            return "2 inches to the right of your belly button"

        case .leftThigh:
            return "Middle of your left outer thigh"

        case .rightThigh:
            return "Middle of your right outer thigh"

        case .leftUpperArm:
            return "Back of your left upper arm"

        case .rightUpperArm:
            return "Back of your right upper arm"
        }
    }
}



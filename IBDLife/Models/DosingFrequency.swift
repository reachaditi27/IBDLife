import Foundation

enum DosingFrequency:
    String,
    CaseIterable,
    Identifiable,
    Hashable, Codable {

    case onceDaily
    case twiceDaily
    case threeTimesDaily
    case weekly
    case everyTwoWeeks
    case everyFourWeeks
    case everySixWeeks
    case everyEightWeeks
    case everyTwelveWeeks
    case asNeeded

    var id: String {
        rawValue
    }

    var title: String {

        switch self {

        case .onceDaily:
            return "Once daily"

        case .twiceDaily:
            return "Twice daily"

        case .threeTimesDaily:
            return "Three times daily"

        case .weekly:
            return "Weekly"

        case .everyTwoWeeks:
            return "Every 2 weeks"

        case .everyFourWeeks:
            return "Every 4 weeks"

        case .everySixWeeks:
            return "Every 6 weeks"

        case .everyEightWeeks:
            return "Every 8 weeks"

        case .everyTwelveWeeks:
            return "Every 12 weeks"

        case .asNeeded:
            return "As needed"
        }
    }

    var subtitle: String {

        switch self {

        case .onceDaily:
            return "Every day"

        case .twiceDaily:
            return "Morning & evening"

        case .threeTimesDaily:
            return "Three times each day"

        case .weekly:
            return "Same day each week"

        case .everyTwoWeeks:
            return "Every 14 days"

        case .everyFourWeeks:
            return "Every 28 days"

        case .everySixWeeks:
            return "Every 6 weeks"

        case .everyEightWeeks:
            return "Every 8 weeks"

        case .everyTwelveWeeks:
            return "Every 12 weeks"

        case .asNeeded:
            return "On-demand or flare use"
        }
    }
}



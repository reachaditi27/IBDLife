import Foundation
import Combine

enum Gender: String, CaseIterable, Identifiable {
    case male = "Male"
    case female = "Female"
    case nonBinary = "Non-binary"
    case preferNotToSay = "Prefer not to say"

    var id: String { rawValue }
}

enum UnitSystem: String, CaseIterable, Identifiable {
    case imperial = "Imperial (lbs / ft)"
    case metric = "Metric (kg / cm)"

    var id: String { rawValue }
}

final class OnboardingData: ObservableObject {

    @Published var name = ""

    @Published var age = ""

    @Published var gender: Gender?

    @Published var unitSystem: UnitSystem = .imperial

    @Published var weight = ""

    @Published var heightFeet = ""

    @Published var heightInches = ""

    @Published var heightCentimeters = ""

    @Published var diagnoses: [String] = []

    @Published var medications: [String] = []
}

import Foundation

struct Medication: Identifiable, Hashable {

    var id: String { brandName.lowercased() }

    let brandName: String
    let genericName: String?
    let category: MedicationCategory
    let diagnoses: Set<Diagnosis>
    let details: String?

    /// Lower numbers appear first within each category.
    let displayOrder: Int
}

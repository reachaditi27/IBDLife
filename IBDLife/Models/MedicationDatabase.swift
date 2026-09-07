import Foundation

struct MedicationDatabase {

    static let medications: [Medication] = [

        // MARK: - BIOLOGICS

        Medication(
            brandName: "Humira",
            genericName: "adalimumab",
            category: .biologic,
            diagnoses: [.crohns, .ulcerativeColitis, .ibdUnclassified],
            details: nil,
            displayOrder: 1
        ),

        Medication(
            brandName: "Remicade",
            genericName: "infliximab",
            category: .biologic,
            diagnoses: [.crohns, .ulcerativeColitis, .ibdUnclassified],
            details: nil,
            displayOrder: 2
        ),

        Medication(
            brandName: "Stelara",
            genericName: "ustekinumab",
            category: .biologic,
            diagnoses: [.crohns, .ulcerativeColitis, .ibdUnclassified],
            details: nil,
            displayOrder: 3
        ),

        Medication(
            brandName: "Entyvio",
            genericName: "vedolizumab",
            category: .biologic,
            diagnoses: [.crohns, .ulcerativeColitis, .ibdUnclassified],
            details: nil,
            displayOrder: 4
        ),

        Medication(
            brandName: "Skyrizi",
            genericName: "risankizumab",
            category: .biologic,
            diagnoses: [.crohns, .ibdUnclassified],
            details: nil,
            displayOrder: 5
        ),

        Medication(
            brandName: "Omvoh",
            genericName: "mirikizumab",
            category: .biologic,
            diagnoses: [.ulcerativeColitis, .ibdUnclassified],
            details: nil,
            displayOrder: 6
        ),

        Medication(
            brandName: "Inflectra",
            genericName: "infliximab-dyyb",
            category: .biologic,
            diagnoses: [.crohns, .ulcerativeColitis, .ibdUnclassified],
            details: "Biosimilar",
            displayOrder: 7
        ),

        Medication(
            brandName: "Renflexis",
            genericName: "infliximab-abda",
            category: .biologic,
            diagnoses: [.crohns, .ulcerativeColitis, .ibdUnclassified],
            details: "Biosimilar",
            displayOrder: 8
        ),

        Medication(
            brandName: "Avsola",
            genericName: "infliximab-axxq",
            category: .biologic,
            diagnoses: [.crohns, .ulcerativeColitis, .ibdUnclassified],
            details: "Biosimilar",
            displayOrder: 9
        ),

        Medication(
            brandName: "Amjevita",
            genericName: "adalimumab-atto",
            category: .biologic,
            diagnoses: [.crohns, .ulcerativeColitis, .ibdUnclassified],
            details: "Biosimilar",
            displayOrder: 10
        ),

        Medication(
            brandName: "Hadlima",
            genericName: "adalimumab-bwwd",
            category: .biologic,
            diagnoses: [.crohns, .ulcerativeColitis, .ibdUnclassified],
            details: "Biosimilar",
            displayOrder: 11
        ),

        Medication(
            brandName: "Hyrimoz",
            genericName: "adalimumab-adaz",
            category: .biologic,
            diagnoses: [.crohns, .ulcerativeColitis, .ibdUnclassified],
            details: "Biosimilar",
            displayOrder: 12
        ),

        Medication(
            brandName: "Cyltezo",
            genericName: "adalimumab-adbm",
            category: .biologic,
            diagnoses: [.crohns, .ulcerativeColitis, .ibdUnclassified],
            details: "Biosimilar",
            displayOrder: 13
        ),

        // MARK: - SMALL MOLECULES

        Medication(
            brandName: "Rinvoq",
            genericName: "upadacitinib",
            category: .smallMolecule,
            diagnoses: [.crohns, .ulcerativeColitis, .ibdUnclassified],
            details: nil,
            displayOrder: 1
        ),

        Medication(
            brandName: "Xeljanz",
            genericName: "tofacitinib",
            category: .smallMolecule,
            diagnoses: [.ulcerativeColitis, .ibdUnclassified],
            details: nil,
            displayOrder: 2
        ),

        Medication(
            brandName: "Zeposia",
            genericName: "ozanimod",
            category: .smallMolecule,
            diagnoses: [.ulcerativeColitis],
            details: nil,
            displayOrder: 3
        ),

        Medication(
            brandName: "Velsipity",
            genericName: "etrasimod",
            category: .smallMolecule,
            diagnoses: [.ulcerativeColitis],
            details: nil,
            displayOrder: 4
        ),
        // MARK: - 5-ASA

        Medication(
            brandName: "Lialda",
            genericName: "mesalamine",
            category: .aminosalicylate,
            diagnoses: [.ulcerativeColitis, .ibdUnclassified],
            details: nil,
            displayOrder: 1
        ),

        Medication(
            brandName: "Pentasa",
            genericName: "mesalamine",
            category: .aminosalicylate,
            diagnoses: [.crohns, .ulcerativeColitis, .ibdUnclassified],
            details: nil,
            displayOrder: 2
        ),

        Medication(
            brandName: "Asacol HD",
            genericName: "mesalamine",
            category: .aminosalicylate,
            diagnoses: [.ulcerativeColitis, .ibdUnclassified],
            details: nil,
            displayOrder: 3
        ),

        Medication(
            brandName: "Apriso",
            genericName: "mesalamine",
            category: .aminosalicylate,
            diagnoses: [.ulcerativeColitis, .ibdUnclassified],
            details: nil,
            displayOrder: 4
        ),

        Medication(
            brandName: "Delzicol",
            genericName: "mesalamine",
            category: .aminosalicylate,
            diagnoses: [.ulcerativeColitis, .ibdUnclassified],
            details: nil,
            displayOrder: 5
        ),

        Medication(
            brandName: "Sulfasalazine",
            genericName: nil,
            category: .aminosalicylate,
            diagnoses: [.ulcerativeColitis],
            details: nil,
            displayOrder: 6
        ),

        Medication(
            brandName: "Balsalazide",
            genericName: nil,
            category: .aminosalicylate,
            diagnoses: [.ulcerativeColitis],
            details: nil,
            displayOrder: 7
        ),

        Medication(
            brandName: "Olsalazine",
            genericName: nil,
            category: .aminosalicylate,
            diagnoses: [.ulcerativeColitis],
            details: nil,
            displayOrder: 8
        ),

        Medication(
            brandName: "Canasa",
            genericName: "mesalamine",
            category: .aminosalicylate,
            diagnoses: [.ulcerativeColitis],
            details: "Rectal suppository",
            displayOrder: 9
        ),

        Medication(
            brandName: "Rowasa",
            genericName: "mesalamine",
            category: .aminosalicylate,
            diagnoses: [.ulcerativeColitis],
            details: "Rectal enema",
            displayOrder: 10
        ),

        // MARK: - IMMUNOMODULATORS

        Medication(
            brandName: "Imuran",
            genericName: "azathioprine",
            category: .immunomodulator,
            diagnoses: [.crohns, .ulcerativeColitis, .ibdUnclassified],
            details: nil,
            displayOrder: 1
        ),

        Medication(
            brandName: "Trexall",
            genericName: "methotrexate",
            category: .immunomodulator,
            diagnoses: [.crohns],
            details: nil,
            displayOrder: 2
        ),

        Medication(
            brandName: "Purinethol",
            genericName: "mercaptopurine",
            category: .immunomodulator,
            diagnoses: [.crohns, .ulcerativeColitis, .ibdUnclassified],
            details: "6-MP",
            displayOrder: 3
        ),
        // MARK: - ANTIBIOTICS

        Medication(
            brandName: "Flagyl",
            genericName: "metronidazole",
            category: .antibiotic,
            diagnoses: [.crohns],
            details: nil,
            displayOrder: 1
        ),

        Medication(
            brandName: "Cipro",
            genericName: "ciprofloxacin",
            category: .antibiotic,
            diagnoses: [.crohns],
            details: nil,
            displayOrder: 2
        ),

        Medication(
            brandName: "Xifaxan",
            genericName: "rifaximin",
            category: .antibiotic,
            diagnoses: [.crohns],
            details: nil,
            displayOrder: 3
        ),
        //Nutrition
        Medication(
            brandName: "Modulen IBD",
            genericName: nil,
            category: .nutrition,
            diagnoses: [.crohns],
            details: "Exclusive enteral nutrition",
            displayOrder: 1
        ),

        Medication(
            brandName: "Ensure Plus",
            genericName: nil,
            category: .nutrition,
            diagnoses: [.crohns, .ulcerativeColitis],
            details: "Oral nutrition supplement",
            displayOrder: 2
        ),

        Medication(
            brandName: "Boost Plus",
            genericName: nil,
            category: .nutrition,
            diagnoses: [.crohns, .ulcerativeColitis],
            details: "Oral nutrition supplement",
            displayOrder: 3
        ),

        Medication(
            brandName: "Kate Farms Standard 1.4",
            genericName: nil,
            category: .nutrition,
            diagnoses: [.crohns, .ulcerativeColitis],
            details: "Plant-based nutrition formula",
            displayOrder: 4
        )
    ]
}

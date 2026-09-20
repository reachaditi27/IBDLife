import Foundation

enum SupportAffirmations {
    static let sets = [
        [
            "You deserve patience and care today.",
            "Showing up for yourself is meaningful progress.",
            "One gentle step is enough for right now."
        ],
        [
            "Your difficult days do not erase your strength.",
            "Rest is part of caring for yourself.",
            "You can take today at your own pace."
        ],
        [
            "You are more than what your body is managing today.",
            "Asking for support is an act of strength.",
            "This moment will pass; you do not have to rush it."
        ],
        [
            "Small acts of care still count.",
            "You are allowed to make room for what you need.",
            "Your effort matters, even when no one else can see it."
        ],
        [
            "You do not have to solve everything right now.",
            "Your feelings make sense, and you are not alone in them.",
            "A slower day is still a day moving forward."
        ],
        [
            "Your body deserves kindness, not judgment.",
            "You have handled hard moments before.",
            "Take the next step only when you are ready."
        ]
    ]

    static func nextIndex(after previousIndex: Int) -> Int {
        let choices = sets.indices.filter { $0 != previousIndex }
        return choices.randomElement() ?? sets.startIndex
    }
}

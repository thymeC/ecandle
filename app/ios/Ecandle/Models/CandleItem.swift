import Foundation

struct CandleItem: Identifiable, Equatable {
    let id: UUID
    let digitLabel: String?
    var isLit: Bool
    var isOut: Bool
    /// Monotonic token bumped when this candle is blown out, so smoke can replay.
    var extinguishToken: Int

    init(
        id: UUID = UUID(),
        digitLabel: String? = nil,
        isLit: Bool = false,
        isOut: Bool = false,
        extinguishToken: Int = 0
    ) {
        self.id = id
        self.digitLabel = digitLabel
        self.isLit = isLit
        self.isOut = isOut
        self.extinguishToken = extinguishToken
    }

    var isDigit: Bool { digitLabel != nil }
}

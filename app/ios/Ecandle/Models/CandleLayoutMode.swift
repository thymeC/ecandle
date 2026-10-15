import Foundation

enum CandleLayoutMode: String, CaseIterable, Identifiable {
    case count = "多根蜡烛"
    case digits = "数字蜡烛"

    var id: String { rawValue }
}

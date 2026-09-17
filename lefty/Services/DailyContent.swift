import Foundation

enum DailyContent {
    static func todayIndex(poolSize: Int, date: Date = .now) -> Int {
        guard poolSize > 0 else { return 0 }
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        return (dayOfYear - 1) % poolSize
    }
}

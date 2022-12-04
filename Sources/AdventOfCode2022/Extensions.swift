import Foundation

extension Array where Element == Int {
    var sum: Int { self.reduce(0, +) }
}

extension Array {
    func chunk(by size: Int) -> [Self] {
        self.enumerated().reduce(into: [Self]()) {
            if $1.offset % size == 0 {
                $0.append([$1.element])
            } else {
                $0[$1.offset / size].append($1.element)
            }
        }
    }
}

extension ClosedRange {
    func contains(_ elements: Bound...) -> Bool {
        elements.allSatisfy { contains($0) }
    }
}

extension StringProtocol {
    func toInt() -> Int {
        Int(self)!
    }
}

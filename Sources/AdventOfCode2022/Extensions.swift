import Foundation

extension Array where Element == Int {
    var sum: Int { self.reduce(0, +) }
}

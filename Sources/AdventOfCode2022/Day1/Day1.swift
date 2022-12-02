import Foundation

struct Day1: Runnable {
    let elves = Self.input
        .components(separatedBy: "\n\n")
        .map { group in
            group.components(separatedBy: "\n").map { Int($0)! }.sum
        }
    
    func partOne() -> String {
        elves.sorted().last!.description
    }
    
    func partTwo() -> String {
        elves.sorted().suffix(3).sum.description
    }
}

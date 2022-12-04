import Foundation

struct Day4: Runnable {
    
    let ranges: [(ClosedRange<Int>, ClosedRange<Int>)] = Self.input
        .split(separator: "\n")
        .map {
            let strings = $0.split(separator: ",")
            let elf1 = strings[0].split(separator: "-").map { $0.toInt() }
            let elf2 = strings[1].split(separator: "-").map { $0.toInt() }
            return (elf1[0]...elf1[1], elf2[0]...elf2[1])
        }
    
    func partOne() -> String {
        ranges.filter {
            $0.0.contains($0.1.lowerBound, $0.1.upperBound) ||
            $0.1.contains($0.0.lowerBound, $0.0.upperBound)
        }.count.description
    }
    
    func partTwo() -> String {
        ranges.filter {
            $0.0.overlaps($0.1)
        }.count.description
    }
}

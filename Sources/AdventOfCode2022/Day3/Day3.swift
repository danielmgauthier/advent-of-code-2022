import Foundation

struct Day3: Runnable {
    let priorityArray = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
    let rucksacks = Self.input.split(separator: "\n")
    
    func partOne() -> String {
        var total = 0
        rucksacks.forEach {
            let comp1 = $0.prefix($0.count / 2)
            let comp2 = $0.suffix($0.count / 2)
            let seen = Set(comp1)
            let commonCharacter = comp2.first { seen.contains($0) }!
            total += priority(for: commonCharacter)
        }
        return total.description
    }
    
    func partTwo() -> String {
        let elfGroups = rucksacks.chunk(by: 3)
        var total = 0
        elfGroups.forEach {
            let seen1 = Set($0[0])
            let seen2 = Set($0[1])
            let commonCharacter = $0[2].first { seen1.contains($0) && seen2.contains($0) }!
            total += priority(for: commonCharacter)
        }
        
        return total.description
    }
    
    private func priority(for character: Character) -> Int {
        priorityArray.firstIndex(of: character)! + 1
    }
}

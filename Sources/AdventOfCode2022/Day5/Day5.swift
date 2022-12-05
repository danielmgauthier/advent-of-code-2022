import Foundation

struct Day5: Runnable {
    let parts = Self.input.components(separatedBy: "\n\n")
    
    struct Instruction {
        var moveCount: Int = 0
        var fromIndex: Int = 0
        var toIndex: Int = 0
        
        init(array: [Int]) {
            self.moveCount = array[0]
            self.fromIndex = array[1] - 1
            self.toIndex = array[2] - 1
        }
    }
    
    func partOne() -> String {
        var stacks = parseStacks()
        let instructions = parseInstructions()
        
        for instruction in instructions {
            for _ in (1...instruction.moveCount) {
                stacks[instruction.toIndex].append(stacks[instruction.fromIndex].removeLast())
            }
        }
        
        return String(stacks.map { $0.last! })
    }
    
    func partTwo() -> String {
        var stacks = parseStacks()
        let instructions = parseInstructions()
        
        for instruction in instructions {
            stacks[instruction.toIndex].append(contentsOf: stacks[instruction.fromIndex].suffix(instruction.moveCount))
            stacks[instruction.fromIndex].removeLast(instruction.moveCount)
        }
        
        return String(stacks.map { $0.last! })
    }
    
    private func parseStacks() -> [[Character]] {
        let diagramLines = parts[0].components(separatedBy: "\n")
        let numberOfStacks = diagramLines.last!.compactMap { $0.wholeNumberValue }.max()!
        var stacks = Array<[Character]>(repeating: [], count: numberOfStacks)
        
        for line in diagramLines {
            for character in line.enumerated() {
                if character.element.isLetter {
                    let stackIndex = (character.offset - 1) / 4
                    stacks[stackIndex].insert(character.element, at: 0)
                }
            }
        }
        return stacks
    }
    
    private func parseInstructions() -> [Instruction] {
        parts[1].components(separatedBy: "\n").map {
            Instruction(array: $0.split(separator: " ").compactMap({ Int($0) }))
        }
    }
}

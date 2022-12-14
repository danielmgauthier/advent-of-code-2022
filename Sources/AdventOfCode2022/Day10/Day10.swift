import Foundation

struct Day10: Runnable {
    
    enum Instruction {
        case noop
        case addx(value: Int)
        
        init(components: [String]) {
            if components[0] == "noop" {
                self = .noop
            } else {
                self = .addx(value: components[1].toInt())
            }
        }
    }
    
    let instructions: [Instruction] = Self.input.components(separatedBy: "\n").map {
        Instruction(components: $0.components(separatedBy: " "))
    }
    
    func partOne() -> String {
        var currentCycle = 1
        var registerValue = 1
        var signalStrengths: [Int] = []
        
        runInstructions(add: { value in
            registerValue += value
        }, onCycleTick: {
            if currentCycle % 40 == 20 {
                signalStrengths.append(currentCycle * registerValue)
            }
            currentCycle += 1
        })
        
        return signalStrengths.sum.description
    }
    
    func partTwo() -> String {
        var currentCycle = 1
        var registerValue = 1
        
        runInstructions(add: { value in
            registerValue += value
        }, onCycleTick: {
            drawPixel(currentCycle: currentCycle, spriteCenter: registerValue)
            currentCycle += 1
        })
        
        print("")
        
        return "^^ Look up! ^^"
    }
    
    private func runInstructions(add: (Int) -> Void, onCycleTick: () -> Void) {
        for instruction in instructions {
            switch instruction {
            case .noop:
                onCycleTick()
            case .addx(let value):
                onCycleTick()
                onCycleTick()
                add(value)
            }
        }
    }
    
    private func drawPixel(currentCycle: Int, spriteCenter: Int) {
        let horizontalPosition = (currentCycle - 1) % 40
        if ((spriteCenter - 1)...(spriteCenter + 1)).contains(horizontalPosition) {
            print("#", terminator: "")
        } else {
            print(" ", terminator: "")
        }
        
        if currentCycle % 40 == 0 { print("") }
    }
}

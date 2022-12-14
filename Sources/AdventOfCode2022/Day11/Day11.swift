import Foundation

struct Day11: Runnable {
    
    enum Operation {
        case plus(Int)
        case times(Int)
        case timesSelf
        
        func process(_ value: Int) -> Int {
            switch self {
            case .plus(let value2): return value + value2
            case .times(let value2): return value * value2
            case .timesSelf: return value * value
            }
        }
    }
    
    class Monkey {
        var items: [Int]
        var operation: Operation
        var divisibilityTest: Int
        var trueIndex: Int
        var falseIndex: Int
        var inspectionCount = 0
        
        init(string: String) {
            self.items = []
            self.operation = .timesSelf
            self.divisibilityTest = 0
            self.trueIndex = 0
            self.falseIndex = 0
            
            let lines = string.components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
            for line in lines {
                if line.starts(with: "Starting items") {
                    self.items = line.components(separatedBy: ": ")[1].components(separatedBy: ", ").map { $0.toInt() }
                }
                
                if line.starts(with: "Operation") {
                    if line.contains("+") {
                        let element = line.components(separatedBy: "+ ")[1]
                        self.operation = .plus(element.toInt())
                    } else {
                        let element = line.components(separatedBy: "* ")[1]
                        if element ==  "old" {
                            self.operation = .timesSelf
                        } else {
                            self.operation = .times(element.toInt())
                        }
                    }
                }
                
                if line.starts(with: "Test") {
                    self.divisibilityTest = line.components(separatedBy: " ").last!.toInt()
                }
                
                if line.starts(with: "If true") {
                    self.trueIndex = line.components(separatedBy: " ").last!.toInt()
                }
                
                if line.starts(with: "If false") {
                    self.falseIndex = line.components(separatedBy: " ").last!.toInt()
                }
            }
        }
        
        func inspectNext(divisor: Int = 1) -> (value: Int, monkeyIndex: Int) {
            let worryLevel = operation.process(items.removeFirst()) / divisor
            if worryLevel % divisibilityTest == 0 {
                return (worryLevel, trueIndex)
            } else {
                return (worryLevel, falseIndex)
            }
        }
    }
    
    func partOne() -> String {
        let monkeys = Self.input.components(separatedBy: "\n\n").map { Monkey(string: $0) }
        for _ in 0..<20 {
            for monkey in monkeys {
                while monkey.items.count > 0 {
                    let inspectionResult = monkey.inspectNext(divisor: 3)
                    monkey.inspectionCount += 1
                    monkeys[inspectionResult.monkeyIndex].items.append(inspectionResult.value)
                }
            }
        }
        
        let sortedInspectionCount = monkeys.map(\.inspectionCount).sorted(by: >)
        return (sortedInspectionCount[0] * sortedInspectionCount[1]).description
    }
    
    func partTwo() -> String {
        let monkeys = Self.input.components(separatedBy: "\n\n").map { Monkey(string: $0) }
        for _ in 0..<10000 {
            for monkey in monkeys {
                while monkey.items.count > 0 {
                    let inspectionResult = monkey.inspectNext()
                    monkey.inspectionCount += 1
                    monkeys[inspectionResult.monkeyIndex].items.append(reduce(inspectionResult.value, for: monkeys))
                }
            }
        }
        
        let sortedInspectionCount = monkeys.map(\.inspectionCount).sorted(by: >)
        return (sortedInspectionCount[0] * sortedInspectionCount[1]).description
    }
    
    private func reduce(_ value: Int, for monkeys: [Monkey]) -> Int {
        value % monkeys.map(\.divisibilityTest).reduce(1, *)
    }
}

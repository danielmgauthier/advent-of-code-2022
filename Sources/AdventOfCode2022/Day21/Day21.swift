import Foundation

struct Day21: Runnable {
    struct Equation {
        enum Operation: String {
            case add = "+"
            case sub = "-"
            case mul = "*"
            case div = "/"
        }
        var first: String
        var second: String
        var operation: Operation
        
        init(string: String) {
            let components = string.components(separatedBy: " ")
            self.first = components[0]
            self.second = components[2]
            self.operation = Operation(rawValue: components[1])!
        }
    }
    
    enum Job {
        case equation(Equation)
        case value(Int)
    }
    
    let monkeys = input.components(separatedBy: "\n").reduce(into: [String: Job](), {
        let components = $1.components(separatedBy: ": ")
        let job: Job
        if let value = Int(components[1]) {
            job = Job.value(value)
        } else {
            job = Job.equation(Equation(string: components[1]))
        }
        
        $0[components[0]] = job
    })
    
    func partOne() -> String {
        solve(monkeys["root"]!, monkeys: monkeys).description
    }
    
    func partTwo() -> String {
        guard case let .equation(equation) = monkeys["root"]! else { fatalError() }
        var monkeys = monkeys
        
        var value = 10_000_000_000_000
        var travel = value
        while true {
            monkeys["humn"] = .value(value)
            let comparisonResult = checkEquality(equation, monkeys: monkeys)
            if comparisonResult == .orderedSame {
                break
            } else if comparisonResult == .orderedDescending {
                travel = travel / 2
                value += travel
            } else {
                travel = travel / 2
                value -= travel
            }
            
        }
        
        while true {
            monkeys["humn"] = .value(value - 1)
            let comparisonResult = checkEquality(equation, monkeys: monkeys)
            if comparisonResult == .orderedSame {
                value = value - 1
            } else {
                break
            }
        }
        
        return value.description
    }
    
    private func checkEquality(_ equation: Equation, monkeys: [String: Job]) -> ComparisonResult {
        let firstValue = solve(monkeys[equation.first]!, monkeys: monkeys)
        let secondValue = solve(monkeys[equation.second]!, monkeys: monkeys)
        
        if firstValue > secondValue {
            return .orderedDescending
        } else if firstValue < secondValue {
            return .orderedAscending
        } else {
            return .orderedSame
        }
    }
    
    private func solve(_ job: Job, monkeys: [String: Job]) -> Int {
        switch job {
        case .equation(let equation):
            switch equation.operation {
            case .add:
                return solve(monkeys[equation.first]!, monkeys: monkeys) + solve(monkeys[equation.second]!, monkeys: monkeys)
            case .sub:
                return solve(monkeys[equation.first]!, monkeys: monkeys) - solve(monkeys[equation.second]!, monkeys: monkeys)
            case .mul:
                return solve(monkeys[equation.first]!, monkeys: monkeys) * solve(monkeys[equation.second]!, monkeys: monkeys)
            case .div:
                return solve(monkeys[equation.first]!, monkeys: monkeys) / solve(monkeys[equation.second]!, monkeys: monkeys)
            }
        case .value(let value):
            return value
        }
    }
}

import Foundation

struct Day13: Runnable {
    
    enum Component: Hashable {
        case value(Int)
        case list([Component])
        
        init(string: [Character]) {
            guard string.contains(where: { $0 == "[" }) else {
                self = .value(String(string).toInt())
                return
            }
            
            var components: [Component] = []
            let charArray = Array(string.dropFirst().dropLast())
            
            var index = 0
            while index < charArray.count {
                if charArray[index] == "[" {
                    var depthCount = 1
                    let endIndex = charArray[(index + 1)...].firstIndex {
                        if $0 == "[" { depthCount += 1 }
                        if $0 == "]" { depthCount -= 1 }
                        return depthCount == 0
                    }!
                    
                    components.append(Component(string: Array(charArray[index...endIndex])))
                    index = endIndex + 1
                    
                } else if charArray[index].isNumber {
                    let endIndex = (charArray[(index + 1)...].firstIndex { character in
                        !character.isNumber
                    } ?? charArray.count) - 1
                    
                    components.append(Component(string: Array(charArray[index...endIndex])))
                    index = endIndex + 1
                    
                } else {
                    index += 1
                }
            }
            
            self = .list(components)
        }
    }
    
    enum ComparisonResult {
        case correct
        case incorrect
        case undetermined
    }
    
    struct Pair {
        var left: Component
        var right: Component
    }
    
    var pairs = input.components(separatedBy: "\n\n").map {
        let lines = $0.components(separatedBy: "\n")
        let components = lines.map { line in
            let line = line
            return Component(string: Array(line))
        }
        
        return Pair(left: components[0], right: components[1])
    }
    
    func partOne() -> String {
        var correctIndices: [Int] = []
        pairs.indexed().forEach {
            if compare(left: $0.element.left, right: $0.element.right) ?? true {
                correctIndices.append($0.index + 1)
            }
        }
        
        return correctIndices.sum.description
    }
    
    func partTwo() -> String {
        let divider1 = Component(string: Array("[[2]]"))
        let divider2 = Component(string: Array("[[6]]"))
        
        var packets = pairs.reduce(into: [Component]()) { partialResult, pair in
            partialResult.append(pair.left)
            partialResult.append(pair.right)
        } + [divider1, divider2]
        
        packets.sort { compare(left: $0, right: $1) ?? true }
        
        return ((packets.firstIndex(of: divider1)! + 1) * (packets.firstIndex(of: divider2)! + 1)).description
    }
    
    private func compare(left: Component, right: Component) -> Bool? {
        guard case let .list(leftList) = left,
              case let .list(rightList) = right else {
            fatalError("top level components should always be lists")
        }
        
        var comparisonResult: Bool?
        
        for index in (0..<max(rightList.count, leftList.count)) {
            if index > leftList.count - 1 {
                comparisonResult = true
                break
            }
            
            if index > rightList.count - 1 {
                comparisonResult = false
                break
            }
            
            if case let .value(leftValue) = leftList[index],
               case let .value(rightValue) = rightList[index] {
                if leftValue < rightValue {
                    comparisonResult = true
                    break
                }
                if leftValue > rightValue {
                    comparisonResult = false
                    break
                }
                continue
            }
            
            if case .list = leftList[index],
               case .list = rightList[index] {
                comparisonResult = compare(left: leftList[index], right: rightList[index])
                if comparisonResult != nil { break } else { continue }
            }
            
            let newLeftComponent: Component
            let newRightComponent: Component
            
            switch leftList[index] {
            case .list(let list): newLeftComponent = .list(list)
            case .value(let value): newLeftComponent = .list([.value(value)])
            }
            
            switch rightList[index] {
            case .list(let list): newRightComponent = .list(list)
            case .value(let value): newRightComponent = .list([.value(value)])
            }
            
            comparisonResult = compare(left: newLeftComponent, right: newRightComponent)
            if comparisonResult != nil { break } else { continue }
        }
        
        return comparisonResult
    }
}

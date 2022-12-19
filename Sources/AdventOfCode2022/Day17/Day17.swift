import Foundation

struct Day17: Runnable {
    enum RockType: Int {
        case dash = 0
        case plus = 1
        case ell = 2
        case line = 3
        case square = 4
        
        func rockPoints(bottom: Int) -> Set<Point> {
            switch self {
            case .dash:
                return [
                    .init(x: 2, y: bottom + 3),
                    .init(x: 3, y: bottom + 3),
                    .init(x: 4, y: bottom + 3),
                    .init(x: 5, y: bottom + 3)
                ]
            case .plus:
                return [
                    .init(x: 3, y: bottom + 5),
                    .init(x: 2, y: bottom + 4),
                    .init(x: 3, y: bottom + 4),
                    .init(x: 4, y: bottom + 4),
                    .init(x: 3, y: bottom + 3)
                ]
                
            case .ell:
                return [
                    .init(x: 4, y: bottom + 5),
                    .init(x: 4, y: bottom + 4),
                    .init(x: 4, y: bottom + 3),
                    .init(x: 3, y: bottom + 3),
                    .init(x: 2, y: bottom + 3)
                ]
            case .line:
                return [
                    .init(x: 2, y: bottom + 6),
                    .init(x: 2, y: bottom + 5),
                    .init(x: 2, y: bottom + 4),
                    .init(x: 2, y: bottom + 3)
                ]
                
            case .square:
                return [
                    .init(x: 2, y: bottom + 4),
                    .init(x: 2, y: bottom + 3),
                    .init(x: 3, y: bottom + 4),
                    .init(x: 3, y: bottom + 3)
                ]
            }
        }
    }
    
    struct Point: Hashable {
        var x: Int
        var y: Int
    }
    
    enum WindDirection: Character {
        case left = "<"
        case right = ">"
    }
    
    var windInstructions = input.map { WindDirection(rawValue: $0)! }
    
    func partOne() -> String {
        var allRocks: Set<Point> = []
        var currentHeight = 0
        var currentInstructionIndex = 0
        for rockIndex in 0..<2022 {
            var rockPoints = RockType(rawValue: rockIndex % 5)!.rockPoints(bottom: currentHeight)
            var settled = false
            while !settled {
                rockPoints = rockPoints
                    .nudged(windInstructions[currentInstructionIndex % windInstructions.count], allRocks: allRocks)
                    .dropped(didSettle: &settled, allRocks: allRocks)
                currentInstructionIndex += 1
            }
            
            allRocks.formUnion(rockPoints)
            currentHeight = max(currentHeight, rockPoints.map(\.y).max()! + 1)
        }
        
        return currentHeight.description
    }
    
    func partTwo() -> String {
        var allRocks: Set<Point> = []
        var terrainMap: [Int: (rockIndex: Int, height: Int)] = [:]
        var heightPerColumn: [Int] = [0, 0, 0, 0, 0, 0, 0]
        var currentHeight = 0
        var currentInstructionIndex = 0
        var addedCycleHeight = 0
        var rockIndex = 0
        var foundCycle = false
        while rockIndex < 1_000_000_000_000 {
            var rockPoints = RockType(rawValue: rockIndex % 5)!.rockPoints(bottom: currentHeight)
            var settled = false
            while !settled {
                rockPoints = rockPoints
                    .nudged(windInstructions[currentInstructionIndex % windInstructions.count], allRocks: allRocks)
                    .dropped(didSettle: &settled, heightPerColumn: &heightPerColumn, allRocks: allRocks)
                currentInstructionIndex += 1
            }
            
            allRocks.formUnion(rockPoints)
            let minimumRelevantHeight = heightPerColumn.min()!
            allRocks = allRocks.filter { $0.y >= minimumRelevantHeight }
            
            currentHeight = max(currentHeight, rockPoints.map(\.y).max()! + 1)
            
            if !foundCycle {
                let terrainHash = {
                    var hasher = Hasher()
                    let normalizationValue = allRocks.map { $0.y }.min()!
                    hasher.combine(Set(allRocks.map { Point(x: $0.x, y: $0.y - normalizationValue) }))
                    hasher.combine(currentInstructionIndex % windInstructions.count)
                    hasher.combine(rockIndex % 5)
                    return hasher.finalize()
                }()
                
                if let (cycleIndex, initialCycleHeight) = terrainMap[terrainHash] {
                    let cycleLength = rockIndex - cycleIndex
                    let cycleHeight = currentHeight - initialCycleHeight

                    let cycleCountRemaining = (1_000_000_000_000 - rockIndex) / cycleLength
                    addedCycleHeight = cycleCountRemaining * cycleHeight
                    rockIndex += cycleCountRemaining * cycleLength
                    foundCycle = true
                }
                
                terrainMap[terrainHash] = (rockIndex, currentHeight)
            }
            
            rockIndex += 1
        }
        
        return (currentHeight + addedCycleHeight).description
    }
}

extension Set where Element == Day17.Point {
    func normalized() -> Self {
        let normalizationValue = map { $0.y }.min()!
        return Set(map { Day17.Point(x: $0.x, y: $0.y - normalizationValue) })
    }
    
    func nudged(_ direction: Day17.WindDirection, allRocks: Set<Day17.Point>) -> Self {
        if direction == .left {
            var invalid = false
            let nudgedShape = Set(map {
                if $0.x - 1 < 0 { invalid = true }
                return Day17.Point(x: $0.x - 1, y: $0.y)
            })
            
            invalid = invalid || !nudgedShape.isDisjoint(with: allRocks)
            
            if invalid { return self } else { return nudgedShape }
            
        } else {
            var invalid = false
            let nudgedShape = Set(map {
                if $0.x + 1 > 6 { invalid = true }
                return Day17.Point(x: $0.x + 1, y: $0.y)
            })
            
            invalid = invalid || !nudgedShape.isDisjoint(with: allRocks)
            
            if invalid { return self } else { return Set(nudgedShape) }
        }
    }
    
    func dropped(didSettle: inout Bool, allRocks: Set<Day17.Point>) -> Self {
        var invalid = false
        let droppedShape = Set(map {
            if $0.y - 1 < 0 { invalid = true }
            return Day17.Point(x: $0.x, y: $0.y - 1)
        })
        
        invalid = invalid || !droppedShape.isDisjoint(with: allRocks)
        
        if invalid {
            didSettle = true
            return self
        } else {
            didSettle = false
            return Set(droppedShape)
        }
    }
    
    func dropped(didSettle: inout Bool, heightPerColumn: inout [Int], allRocks: Set<Day17.Point>) -> Self {
        var invalid = false
        let droppedShape = Set(map {
            if $0.y - 1 < 0 { invalid = true }
            return Day17.Point(x: $0.x, y: $0.y - 1)
        })
        
        invalid = invalid || !droppedShape.isDisjoint(with: allRocks)
        
        if invalid {
            didSettle = true
            droppedShape.forEach {
                heightPerColumn[$0.x] = Swift.max(heightPerColumn[$0.x], $0.y)
            }
            return self
        } else {
            didSettle = false
            return Set(droppedShape)
        }
    }
}

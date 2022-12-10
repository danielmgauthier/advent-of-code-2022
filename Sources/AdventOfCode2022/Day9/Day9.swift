import Foundation

struct Day9: Runnable {

    enum Direction {
        case up
        case down
        case left
        case right
    }
    
    struct Instruction {
        
        var direction: Direction
        var distance: Int
        
        init(letter: String, number: Int) {
            switch letter {
            case "U": self.direction = .up
            case "D": self.direction = .down
            case "L": self.direction = .left
            case "R": self.direction = .right
            default: fatalError()
            }
            self.distance = number
        }
    }
    
    struct Point: Hashable {
        var x: Int
        var y: Int
        
        static var zero: Point {
            Point(x: 0, y: 0)
        }
        
        func move(_ direction: Direction) -> Point {
            switch direction {
            case .up:
                return Point(x: x, y: y - 1)
            case .down:
                return Point(x: x, y: y + 1)
            case .left:
                return Point(x: x - 1, y: y )
            case .right:
                return Point(x: x + 1, y: y)
            }
        }
        
        func moveTowards(head: Point) -> Point {
            var newX = x
            var newY = y
            let xDistance = head.x - x
            let yDistance = head.y - y
            
            if abs(xDistance) == 2 {
                newX = x + xDistance / 2
                if abs(yDistance) == 1 { newY = y + yDistance }
            }
            
            if abs(yDistance) == 2 {
                newY = y + yDistance / 2
                if abs(xDistance) == 1 { newX = x + xDistance }
            }
            
            return Point(x: newX, y: newY)
        }
    }
    
    let instructions: [Instruction] = Self.input.components(separatedBy: "\n").map {
        let components = $0.components(separatedBy: " ")
        return Instruction(letter: components[0], number: components[1].toInt())
    }
    
    func partOne() -> String {
        getVisitedPoints(
            knots: Array(repeating: Point.zero, count: 2),
            instructions: instructions
        ).count.description
    }
    
    func partTwo() -> String {
        getVisitedPoints(
            knots: Array(repeating: Point.zero, count: 10),
            instructions: instructions
        ).count.description
    }
    
    private func getVisitedPoints(knots: [Point], instructions: [Instruction]) -> Set<Point> {
        var visitedPoints: Set<Point> = [knots.last!]
        var knots = knots
        
        instructions.forEach {
            for _ in 1...$0.distance {
                knots[0] = knots[0].move($0.direction)
                for index in 1...(knots.count - 1) {
                    knots[index] = knots[index].moveTowards(head: knots[index - 1])
                }
                visitedPoints.insert(knots.last!)
            }
        }
        
        return visitedPoints
    }
}

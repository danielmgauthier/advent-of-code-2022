import Foundation
import Algorithms

struct Day14: Runnable {
    struct Point: Hashable {
        var x: Int
        var y: Int
        
        init(string: String) {
            let components = string.components(separatedBy: ",")
            self.x = components[0].toInt()
            self.y = components[1].toInt()
        }
        
        init(x: Int, y: Int) {
            self.x = x
            self.y = y
        }
        
        var down: Point { .init(x: x, y: y + 1) }
        var left: Point { .init(x: x - 1, y: y) }
        var right: Point { .init(x: x + 1, y: y) }
        
        func pointsBetween(_ point: Point) -> [Point] {
            let xDifference = point.x - x
            var points: [Point] = []
            
            if xDifference != 0 {
                ([point.x, x].min()!...[point.x, x].max()!).forEach { points.append(.init(x: $0, y: y)) }
            } else {
                ([point.y, y].min()!...[point.y, y].max()!).forEach { points.append(.init(x: x, y: $0)) }
            }
            
            return points
        }
    }
    
    let walls: Set<Point> = input.components(separatedBy: "\n").reduce(into: []) { partialResult, line in
        let components = line.components(separatedBy: " -> ")
        components.windows(ofCount: 2).forEach {
            let array = Array($0)
            let startPoint = Point(string: array[0])
            let endPoint = Point(string: array[1])
            for point in startPoint.pointsBetween(endPoint) {
                partialResult.insert(point)
            }
        }
    }
    
    func partOne() -> String {
        var abyss = false
        var sandMap: Set<Point> = []
        let abyssCutoff = walls.sorted {
            $0.y < $1.y
        }.last!.y
        
        while !abyss {
            var sand = Point(x: 500, y: 0)
            var settled = false
            while !settled {
                (sand, settled) = gravityStep(sand: sand, sandMap: &sandMap)
                if sand.y >= abyssCutoff {
                    abyss = true
                    break
                }
            }
            
        }
        return sandMap.count.description
    }
    
    func partTwo() -> String {
        var sandMap: Set<Point> = []
        let floor = walls.sorted {
            $0.y < $1.y
        }.last!.y + 2
        
        while !sandMap.contains(Point(x: 500, y: 0)) {
            var sand = Point(x: 500, y: 0)
            var settled = false
            while !settled {
                (sand, settled) = gravityStep(sand: sand, sandMap: &sandMap, floor: floor)
            }
            
        }
        return sandMap.count.description
    }
    
    // returns new sand position, and whether sand has settled
    private func gravityStep(sand: Point, sandMap: inout Set<Point>, floor: Int = .max) -> (Point, Bool) {
        for possibleNextPoint in [sand.down, sand.down.left, sand.down.right] {
            if !(sandMap.contains(possibleNextPoint) || walls.contains(possibleNextPoint)) && possibleNextPoint.y < floor {
                return (possibleNextPoint, false)
            }
        }
        
        sandMap.insert(sand)
        return (sand, true)
    }
}

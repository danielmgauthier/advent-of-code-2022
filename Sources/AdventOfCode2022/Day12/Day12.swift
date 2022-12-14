import Foundation

struct Day12: Runnable {
    struct Point: Hashable {
        var x: Int
        var y: Int
        
        func adjacentPoints(xBound: Int, yBound: Int) -> Set<Point> {
            var set = Set<Point>()
            if x > 0 { set.insert(Point(x: x - 1, y: y)) }
            if y > 0 { set.insert(Point(x: x, y: y - 1)) }
            if x < xBound { set.insert(Point(x: x + 1, y: y)) }
            if y < yBound { set.insert(Point(x: x, y: y + 1))}
            
            return set
        }
        
        static var zero: Point {
            .init(x: 0, y: 0)
        }
    }
    
    struct TravelNode {
        var point: Point
        var distance: Int
    }
    
    var elevationMap = input
        .components(separatedBy: "\n")
        .map { Array($0) }
        .enumerated()
        .reduce(into: [Point: Character]()) { partialResult, characterArray in
            for character in characterArray.element.enumerated() {
                partialResult[Point(x: character.offset, y: characterArray.offset)] = character.element
            }
    }
    
    var terrainWidth = input.components(separatedBy: "\n")[0].count
    var terrainHeight = input.components(separatedBy: "\n").count
    
    func partOne() -> String {
        var endPoint = Point.zero
        var startPoints: [Point] = []
        let elevationMap = processStartEndPoints(startPoints: &startPoints, endPoint: &endPoint)
        
        return travel(from: startPoints[0], to: endPoint, in: elevationMap)!.description
    }
    
    func partTwo() -> String {
        var endPoint = Point.zero
        var startPoints: [Point] = []
        let elevationMap = processStartEndPoints(startPoints: &startPoints, endPoint: &endPoint)
        
        return startPoints.compactMap {
            travel(from: $0, to: endPoint, in: elevationMap)
        }.min()!.description
    }
    
    private func travel(
        from startingPoint: Point,
        to destinationPoint: Point,
        in elevationMap: [Point: Int]
    ) -> Int? {
        var visited: Set<Point> = [startingPoint]
        var searchQueue: [TravelNode] = [.init(point: startingPoint, distance: 0)]
        
        while !searchQueue.isEmpty {
            let node = searchQueue.removeFirst()
            if node.point == destinationPoint { return node.distance }
            
            let options = node.point.adjacentPoints(xBound: terrainWidth - 1, yBound: terrainHeight - 1).filter {
                !visited.contains($0) && elevationMap[$0]! - elevationMap[node.point]! <= 1
            }
            
            for option in options {
                visited.insert(option)
                searchQueue.append(.init(point: option, distance: node.distance + 1))
            }
        }
        
        return nil
    }
    
    private func processStartEndPoints(
        startPoints: inout [Point],
        endPoint: inout Point
    ) -> [Point: Int] {
        startPoints.append(elevationMap.first { $0.value == "S" }!.key)
        endPoint = elevationMap.first { $0.value == "E" }!.key
        
        startPoints.append(contentsOf: Array(elevationMap.filter {
            $0.value == "a"
        }.keys))
        
        let elevationMap = elevationMap.mapValues {
            if $0 == "S" { return Int(Character("a").asciiValue!) }
            if $0 == "E" { return Int(Character("z").asciiValue!) }
            return Int($0.asciiValue!)
        }
        
        return elevationMap
    }
}

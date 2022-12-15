import Foundation

struct Day15: Runnable {
    struct Sensor: Hashable {
        var location: Point
        var closestBeacon: Point
    }
    
    struct Point: Hashable {
        var x: Int
        var y: Int
        
        init(x: Int, y: Int) {
            self.x = x
            self.y = y
        }
        
        init(string: String) {
            let components = string.components(separatedBy: ", ")
            self.x = components[0].components(separatedBy: "=")[1].toInt()
            self.y = components[1].components(separatedBy: "=")[1].toInt()
        }
        
        func distance(to point: Point) -> Int {
            abs(point.x - x) + abs(point.y - y)
        }
    }
    
    
    let sensorMap: Set<Sensor> = Set(input.components(separatedBy: "\n").map {
        let sensorPoint = Point(string: String(Array($0)[10...].split(separator: ":")[0]))
        let beaconPoint = Point(string: $0.components(separatedBy: "is at ")[1])
        return Sensor(location: sensorPoint, closestBeacon: beaconPoint)
    })
    
    let beaconMap: Set<Point> = Set(input.components(separatedBy: "\n").map {
        Point(string: $0.components(separatedBy: "is at ")[1])
    })
    
    func partOne() -> String {
        let verificationRow = 2000000
        var emptyRanges: [(Int, Int)] = []
        
        for sensor in sensorMap {
            let distance = sensor.location.distance(to: sensor.closestBeacon)
            if verificationRow >= sensor.location.y - distance && verificationRow <= sensor.location.y + distance {
                let currentDistanceFromSensor = abs(verificationRow - sensor.location.y)
                let lowerHorizontalLimit = sensor.location.x - (distance - currentDistanceFromSensor)
                let upperHorizontalLimit = sensor.location.x + (distance - currentDistanceFromSensor)
                emptyRanges.append((lowerHorizontalLimit, upperHorizontalLimit))
            }
        }
        
        let combinedRanges = combineRanges(emptyRanges)
        
        var emptyCount = combinedRanges.map { ($0.1 - $0.0) + 1 }.sum
        emptyCount -= beaconMap.filter { $0.y == verificationRow }.count
        return emptyCount.description
    }
    
    func partTwo() -> String {
        let lowerClamp = 0
        let upperClamp = 4000000
        var emptyRanges: [Int: [(Int, Int)]] = [:]
        
        for sensor in sensorMap {
            let distance = sensor.location.distance(to: sensor.closestBeacon)
            for row in max(lowerClamp, sensor.location.y - distance)...min(upperClamp, sensor.location.y + distance) {
                let currentDistanceFromSensor = abs(row - sensor.location.y)
                let lowerHorizontalLimit = sensor.location.x - (distance - currentDistanceFromSensor)
                let upperHorizontalLimit = sensor.location.x + (distance - currentDistanceFromSensor)
                let range = (lowerHorizontalLimit, upperHorizontalLimit)
                if emptyRanges[row] == nil {
                    emptyRanges[row] = [range]
                } else {
                    emptyRanges[row] = emptyRanges[row]! + [range]
                }   
            }
        }
        
        for (row, ranges) in emptyRanges {
            let combinedRanges = combineRanges(ranges)
            if combinedRanges.count > 1 {
                return ((combinedRanges[1].0 - 1) * 4000000 + row).description
            }
        }
        
        return "uh oh"
    }
    
    private func combineRanges(_ ranges: [(Int, Int)]) -> [(Int, Int)] {
        let sortedRanges = ranges.sorted { $0.0 < $1.0 }
        var combinedRanges: [(Int, Int)] = []
        for range in sortedRanges {
            if combinedRanges.isEmpty {
                combinedRanges.append(range)
            } else if range.0 > combinedRanges.last!.1 + 1 {
                combinedRanges.append(range)
            } else {
                let lastRange = combinedRanges[combinedRanges.count - 1]
                combinedRanges[combinedRanges.count - 1] = (lastRange.0, max(range.1, lastRange.1))
            }
        }
        
        return combinedRanges
    }
}

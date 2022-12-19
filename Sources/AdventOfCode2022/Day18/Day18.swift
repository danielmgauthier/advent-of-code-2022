import Foundation

struct Day18: Runnable {
    
    struct Cube: Hashable {
        var x: Int
        var y: Int
        var z: Int
    }
    
    struct Location: Hashable {
        var a: Int
        var b: Int
    }
    
    let cubes: Set<Cube>
    let minX: Int
    let minY: Int
    let minZ: Int
    let maxX: Int
    let maxY: Int
    let maxZ: Int
    
    init() {
        self.cubes = Set(Self.input.components(separatedBy: "\n").map {
            let components = $0.components(separatedBy: ",")
            return Cube(x: components[0].toInt(), y: components[1].toInt(), z: components[2].toInt())
        })
        (self.minX, self.maxX) = cubes.map(\.x).minAndMax()!
        (self.minY, self.maxY) = cubes.map(\.y).minAndMax()!
        (self.minZ, self.maxZ) = cubes.map(\.z).minAndMax()!
    }
    
    enum Axis {
        case x
        case y
        case z
    }
    
    func partOne() -> String {
        (scanForSurfaceArea(along: .x) +
         scanForSurfaceArea(along: .y) +
         scanForSurfaceArea(along: .z)).description
    }
    
    func partTwo() -> String {
        let outsideSpace = findOutsideSpace()
        return (scanForSurfaceArea(along: .x, includeInterior: false, outsideSpace: outsideSpace) +
                scanForSurfaceArea(along: .y, includeInterior: false, outsideSpace: outsideSpace) +
                scanForSurfaceArea(along: .z, includeInterior: false, outsideSpace: outsideSpace)).description
    }
    
    private func scanForSurfaceArea(along axis: Axis, includeInterior: Bool = true, outsideSpace: Set<Cube> = []) -> Int {
        var surfaceArea = 0
        var lastScanMap: Set<Location> = []
        var currentScanMap: Set<Location> = []
        
        func processPlane(x: Int, y: Int, z: Int) {
            let location: Location
            let previousCube: Cube
            switch axis {
            case .x:
                location = .init(a: y, b: z)
                previousCube = .init(x: x - 1, y: y, z: z)
            case .y:
                location = .init(a: x, b: z)
                previousCube = .init(x: x, y: y - 1, z: z)
            case .z:
                location = .init(a: x, b: y)
                previousCube = .init(x: x, y: y, z: z - 1)
            }
            if cubes.contains(.init(x: x, y: y, z: z)) {
                //if we're scanning a cube, and last scanline had no cube, we've hit a surface
                currentScanMap.insert(location)
                if !lastScanMap.contains(location) {
                    if includeInterior || outsideSpace.contains(previousCube) {
                        surfaceArea += 1
                    }
                }
            } else {
                // if we're not scanning a cube, and last scanline had a cube, we've just left a surface
                if lastScanMap.contains(location) {
                    if includeInterior || outsideSpace.contains(.init(x: x, y: y, z: z)) {
                        surfaceArea += 1
                    }
                }
            }
        }
        
        switch axis {
        case .x:
            for x in minX...maxX + 1 {
                for y in minY...maxY {
                    for z in minZ...maxZ {
                        processPlane(x: x, y: y, z: z)
                    }
                }
                lastScanMap = currentScanMap
                currentScanMap = []
            }
        case .y:
            for y in minY...maxY + 1 {
                for x in minX...maxX {
                    for z in minZ...maxZ {
                        processPlane(x: x, y: y, z: z)
                    }
                }
                lastScanMap = currentScanMap
                currentScanMap = []
            }
            
        case .z:
            for z in minZ...maxZ + 1 {
                for x in minX...maxX {
                    for y in minY...maxY {
                        processPlane(x: x, y: y, z: z)
                    }
                }
                lastScanMap = currentScanMap
                currentScanMap = []
            }
        }
        
        return surfaceArea
    }
    
    private func findOutsideSpace() -> Set<Cube> {
        var visited: Set<Cube> = [.init(x: -1, y: -1, z: -1)]
        var searchQueue: [Cube] = [.init(x: -1, y: -1, z: -1)]
        
        while !searchQueue.isEmpty {
            let searchCube = searchQueue.removeFirst()
            let adjacentPositions = [
                Cube(x: searchCube.x, y: searchCube.y, z: searchCube.z + 1),
                Cube(x: searchCube.x, y: searchCube.y, z: searchCube.z - 1),
                Cube(x: searchCube.x, y: searchCube.y + 1, z: searchCube.z),
                Cube(x: searchCube.x, y: searchCube.y - 1, z: searchCube.z),
                Cube(x: searchCube.x + 1, y: searchCube.y, z: searchCube.z),
                Cube(x: searchCube.x - 1, y: searchCube.y, z: searchCube.z)
            ].filter {
                !cubes.contains($0) &&
                !visited.contains($0) &&
                searchCube.x >= -1 &&
                searchCube.x <= maxX + 1 &&
                searchCube.y >= -1 &&
                searchCube.y <= maxY + 1 &&
                searchCube.z >= -1 &&
                searchCube.z <= maxZ + 1
            }
            
            for position in adjacentPositions {
                visited.insert(position)
                searchQueue.append(position)
            }
        }
        
        return visited
    }
}

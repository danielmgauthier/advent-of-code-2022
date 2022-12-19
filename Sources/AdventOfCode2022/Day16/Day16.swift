import Foundation

class Node: Hashable {
    static func == (lhs: Node, rhs: Node) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    var name: String
    var connections: [Node] = []
    var distanceMap: [Node: Int] = [:]
    var flowRate: Int!
    
    init(name: String) {
        self.name = name
    }
    
    init(string: String) {
        let words = string.components(separatedBy: " ")
        self.name = words[1]
        self.flowRate = words.last!.components(separatedBy: "=").last!.toInt()
    }
    
    func updateWithString(_ string: String) {
        let words = string.components(separatedBy: " ")
        self.name = words[1]
        self.flowRate = words.last!.components(separatedBy: "=").last!.toInt()
    }
}

struct Agent {
    var arrivalNode: Node
    var arrivalTime: Int
}

struct Day16: Runnable {
    
    var startingNode: Node!
    var nodes: Set<Node> = []
    
    init() {
        var createdNodes: [Node] = []
        for line in Day16.input.replacingOccurrences(of: "valves", with: "valve").components(separatedBy: "\n") {
            let components = line.components(separatedBy: "; ")
            var node: Node
            if let existingNode = createdNodes.first(where: { $0.name == components[0].components(separatedBy: " ")[1] }) {
                node = existingNode
                existingNode.updateWithString(components[0])
            } else {
                node = Node(string: components[0])
                createdNodes.append(node)
            }
            
            let connections = components[1].components(separatedBy: "valve ")[1].components(separatedBy: ", ").map { name in
                if let existingNode = createdNodes.first(where: { node in node.name == name }) {
                    return existingNode
                } else {
                    let node = Node(name: name)
                    createdNodes.append(node)
                    return node
                }
                
            }
            node.connections.append(contentsOf: connections)
        }
        
        startingNode = createdNodes.first { $0.name == "AA" }
        nodes.formUnion(createdNodes)
        
        for node in nodes {
            for destinationNode in nodes {
                node.distanceMap[destinationNode] = distance(from: node, to: destinationNode) ?? .max
            }
        }
    }
    
    func partOne() -> String {
        var bestResult = 0
        travel(from: startingNode, minutesRemaining: 30, enabledMap: [startingNode: 30], bestResult: &bestResult)
        return bestResult.description
    }
    
    func partTwo() -> String {
        var bestResult = 0
        travel(
            actingAgent: Agent(arrivalNode: startingNode, arrivalTime: 26),
            otherAgent: Agent(arrivalNode: startingNode, arrivalTime: 26),
            enabledMap: [startingNode: 26],
            bestResult: &bestResult
        )
        return bestResult.description
    }
    
    
    private func distance(
        from startingPoint: Node,
        to destinationPoint: Node
    ) -> Int? {
        var visited: Set<Node> = [startingPoint]
        var searchQueue: [(Node, Int)] = [(startingPoint, 0)]
        
        while !searchQueue.isEmpty {
            let searchNode = searchQueue.removeFirst()
            if searchNode.0 == destinationPoint { return searchNode.1 }
            
            let options = searchNode.0.connections.filter {
                !visited.contains($0)
            }
            
            for option in options {
                visited.insert(option)
                searchQueue.append((option, searchNode.1 + 1))
            }
        }
        
        return nil
    }
    
    private func travel(from node: Node, minutesRemaining: Int, enabledMap: [Node: Int], bestResult: inout Int) {
        let possibleDestinations = nodes.filter { !enabledMap.keys.contains($0) && $0.flowRate != 0 }
        
        var destinationCount = 0
        for possibleDestination in possibleDestinations {
            let distance = node.distanceMap[possibleDestination]!
            let minutesRemaining = minutesRemaining - distance - 1
            if minutesRemaining < 0 { continue }
            var enabledMap = enabledMap
            enabledMap[possibleDestination] = minutesRemaining
            travel(from: possibleDestination, minutesRemaining: minutesRemaining, enabledMap: enabledMap, bestResult: &bestResult)
            destinationCount += 1
        }
        
        if destinationCount == 0 {
            bestResult = [enabledMap.pressureScore, bestResult].max()!
        }
    }
    
    func travel(actingAgent: Agent, otherAgent: Agent, enabledMap: [Node: Int], bestResult: inout Int) {
        var possibleDestinations = nodes.filter { !enabledMap.keys.contains($0) && $0.flowRate != 0 }
        
        // A sloppy optimization to get things running in a reasonable time — if we know this traversal
        // is already too expensive to compete for best result, bail early
        let unrealisticBestResult = possibleDestinations.map {
            let closestDistance = [actingAgent.arrivalNode.distanceMap[$0]!, otherAgent.arrivalNode.distanceMap[$0]!].min()!
            return $0.flowRate * (actingAgent.arrivalTime - closestDistance)
        }.sum + enabledMap.pressureScore
        
        if unrealisticBestResult < bestResult {
            possibleDestinations = []
        }
        
        var destinationCount = 0
        for possibleDestination in possibleDestinations {
            let distance = actingAgent.arrivalNode.distanceMap[possibleDestination]!
            let minutesRemaining = actingAgent.arrivalTime - distance - 1
            if minutesRemaining < 0 { continue }
            var enabledMap = enabledMap
            enabledMap[possibleDestination] = minutesRemaining
            let newAgent = Agent(arrivalNode: possibleDestination, arrivalTime: minutesRemaining)
            
            if newAgent.arrivalTime > otherAgent.arrivalTime {
                travel(actingAgent: newAgent, otherAgent: otherAgent, enabledMap: enabledMap, bestResult: &bestResult)
            } else {
                travel(actingAgent: otherAgent, otherAgent: newAgent, enabledMap: enabledMap, bestResult: &bestResult)
            }
            
            destinationCount += 1
        }
        
        if destinationCount == 0 {
            bestResult = [enabledMap.pressureScore, bestResult].max()!
        }
    }
}

extension Dictionary where Key == Node, Value == Int {
    var pressureScore: Int {
        reduce(0) { $0 + $1.key.flowRate * $1.value }
    }
}

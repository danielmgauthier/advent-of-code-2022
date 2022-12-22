import Foundation

struct Day20: Runnable {
    class Node {
        var value: Int
        var next: Node!
        var prev: Node!
        
        init(value: Int) {
            self.value = value
        }
    }
    
    private func getInitialNodes() -> [Node] {
        let initialNodeArray = Self.input.components(separatedBy: "\n").map { Node(value: $0.toInt()) }
        let reversedArray = Array(initialNodeArray.reversed())
        for node in initialNodeArray.enumerated() {
            node.element.next = initialNodeArray[(node.offset + 1) % initialNodeArray.count]
        }
        
        for node in reversedArray.enumerated() {
            node.element.prev = reversedArray[(node.offset + 1) % reversedArray.count]
        }
        
        return initialNodeArray
    }
    
    func partOne() -> String {
        let nodes = getInitialNodes()
        for node in nodes {
            mix(node: node, in: nodes)
        }

        return getCoordinates(in: nodes).sum.description
    }
    
    func partTwo() -> String {
        let nodes = getInitialNodes()
        for node in nodes {
            node.value = node.value * 811589153
        }
        
        for _ in 0..<10 {
            for node in nodes {
                mix(node: node, in: nodes)
            }
        }
        
        return getCoordinates(in: nodes).sum.description
    }
    
    private func mix(node: Node, in nodes: [Node]) {
        guard node.value != 0 else { return }
        var steps = node.value
        
        node.prev.next = node.next
        node.next.prev = node.prev
        
        if steps < 0 {
            steps = -(abs(steps) % (nodes.count - 1))
            var destinationNode = node.next!
            while steps != 0 {
                destinationNode = destinationNode.prev
                steps += 1
            }
            
            node.prev = destinationNode.prev
            node.next = destinationNode
            destinationNode.prev.next = node
            destinationNode.prev = node
        } else {
            steps = steps % (nodes.count - 1)
            var destinationNode = node.prev!
            while steps != 0 {
                destinationNode = destinationNode.next
                steps -= 1
            }
            
            node.next = destinationNode.next
            node.prev = destinationNode
            destinationNode.next.prev = node
            destinationNode.next = node
        }
    }
    
    private func getCoordinates(in nodes: [Node]) -> [Int] {
        let zeroNode = nodes.first { $0.value == 0 }!
        var coordinates: [Int] = []
        
        var destinationNode = zeroNode
        for n in 1...3000 {
            destinationNode = destinationNode.next
            if n == 1000 || n == 2000 || n == 3000 {
                coordinates.append(destinationNode.value)
            }
        }
        
        return coordinates
    }
}

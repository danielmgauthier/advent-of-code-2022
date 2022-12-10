import Foundation

struct Day8: Runnable {
    
    let trees: [[Int]]
    let width: Int
    let height: Int
    
    init() {
        trees = Self.input.components(separatedBy: "\n").map { row in
            row.map { $0.toInt() }
        }
        width = trees.count
        height = trees[0].count
    }
    
    func partOne() -> String {
        var visibleTrees = 0
        for row in 1..<height - 1 {
            for column in 1..<width - 1 {
                if isVisible(row: row, column: column) {
                    visibleTrees += 1
                }
            }
        }
        
        visibleTrees += width * 2 + height * 2 - 4
        return visibleTrees.description
    }
    
    func partTwo() -> String {
        var bestScenicScore = 0
        for row in 1..<height - 1 {
            for column in 1..<width - 1 {
                let score = scenicScore(row: row, column: column)
                if  score > bestScenicScore {
                    bestScenicScore = score
                }
            }
        }
        
        return bestScenicScore.description
    }
    
    private func isVisible(row: Int, column: Int) -> Bool {
        let treeHeight = trees[row][column]
        return (0...(row - 1)).allSatisfy { trees[$0][column] < treeHeight } ||
        ((row + 1)...(height - 1)).allSatisfy { trees[$0][column] < treeHeight } ||
        (0...(column - 1)).allSatisfy { trees[row][$0] < treeHeight } ||
        ((column + 1)...(width - 1)).allSatisfy { trees[row][$0] < treeHeight }
    }
    
    private func scenicScore(row: Int, column: Int) -> Int {
        let height = trees[row][column]
        var topCount = 0
        var bottomCount = 0
        var leftCount = 0
        var rightCount = 0
        
        for row in (0...(row - 1)).reversed() {
            topCount += 1
            if trees[row][column] >= height { break }
        }
        
        for row in ((row + 1)...(trees[0].count - 1)) {
            bottomCount += 1
            if trees[row][column] >= height { break }
        }
        
        for column in (0...(column - 1)).reversed() {
            leftCount += 1
            if trees[row][column] >= height { break }
        }
        
        for column in ((column + 1)...(trees.count - 1)) {
            rightCount += 1
            if trees[row][column] >= height { break }
        }
        
        return topCount * bottomCount * leftCount * rightCount
    }
}

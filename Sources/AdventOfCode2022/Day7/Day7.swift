import Foundation

struct Day7: Runnable {
    
    class Directory {
        var size: Int = 0
        var name: String
        var parentDirectory: Directory?
        var subdirectories: [Directory] = []
        
        init(name: String, parentDirectory: Directory? = nil) {
            self.name = name
            self.parentDirectory = parentDirectory
        }
    }
    
    func partOne() -> String {
        let rootDirectory = processInstructions()
        return getSummableSizes(root: rootDirectory).sum.description
    }
    
    func partTwo() -> String {
        let rootDirectory = processInstructions()
        return getSmallestFreeingSize(root: rootDirectory).description
    }
    
    private func processInstructions() -> Directory {
        let instructions = Self.input.components(separatedBy: "\n").dropFirst()
        var currentDirectory = Directory(name: "/")
        let rootDirectory = currentDirectory
        
        for instruction in instructions {
            let components = instruction.components(separatedBy: " ")
            if components[0] == "$" {
                if components[1] == "cd" {
                    if components[2] == ".." {
                        currentDirectory = currentDirectory.parentDirectory!
                    } else {
                        currentDirectory = currentDirectory.subdirectories.first(where: { $0.name == components[2] })!
                    }
                }
            } else {
                let components = instruction.components(separatedBy: " ")
                if components[0] == "dir" {
                    if !currentDirectory.subdirectories.contains(where: { $0.name ==  components[1] }) {
                        currentDirectory.subdirectories.append(Directory(name: components[1], parentDirectory: currentDirectory))
                    }
                } else {
                    currentDirectory.size += components[0].toInt()
                }
            }
        }
        
        return rootDirectory
    }
    
    private func getSummableSizes(root: Directory) -> [Int] {
        var summableSizes: [Int] = []
        getTotalDirectorySize(root: root, directorySizes: &summableSizes, sizeLimit: 100000)
        return summableSizes
    }
    
    private func getSmallestFreeingSize(root: Directory) -> Int {
        var sizes: [Int] = []
        let totalDirectorySize = getTotalDirectorySize(root: root, directorySizes: &sizes)
        
        return sizes.sorted().first {
            $0 >= 30000000 - (70000000 - totalDirectorySize)
        }!
    }
    
    @discardableResult
    private func getTotalDirectorySize(root: Directory, directorySizes: inout [Int], sizeLimit: Int = Int.max) -> Int {
        let size = root.size + root.subdirectories.map {
            getTotalDirectorySize(root: $0, directorySizes: &directorySizes, sizeLimit: sizeLimit)
        }.sum
        if size <= sizeLimit {
            directorySizes.append(size)
        }
        return size
    }
}

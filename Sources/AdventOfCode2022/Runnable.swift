protocol Runnable {
    func run()
    func partOne() -> String
    func partTwo() -> String
}

extension Runnable {
    func run() {
        printResult(name: "Part 1", result: partOne())
        print("")
        printResult(name: "Part 2", result: partTwo())
        print("\n")
    }
    
    private func printResult(name: String, result: String) {
        print("------\(name)------")
        print("|                |")
        let result = result
        let length = result.count
        let space = 10 + name.count - length
        let leftSpace = space / 2
        let rightSpace = space - leftSpace
        print("|", terminator: "")
        print(String(repeating: " ", count: leftSpace), terminator: "")
        print(result, terminator: "")
        print(String(repeating: " ", count: rightSpace), terminator: "|\n")
        print("|                |")
        print("|-----\(String(repeating: "-", count: name.count))-----|")
        print("|\(String(repeating: " ", count: name.count + 10))|")
        print("º\(String(repeating: " ", count: name.count + 10))º")
    }
}

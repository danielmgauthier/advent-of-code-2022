import Foundation

// Ran out of energy to make this more elegant, so, just came up with a few heuristics to cull the search space and get this running
// in a reasonable amount of time. With my input, part 1 and 2 run in about 45 seconds each. ¯\_(ツ)_/¯
struct Day19: Runnable {
    enum Resource: String, Hashable {
        case ore
        case clay
        case obsidian
        case geode
        case doNothing
    }
    
    struct Cost: Hashable {
        var amount: Int
        var resource: Resource
    }
    
    struct Robot: Hashable {
        var type: Resource
        var costs: [Resource: Int]
        
        init(type: Resource, costs: [Resource: Int]) {
            self.type = type
            self.costs = costs
        }
        
        init(string: String) {
            self.costs = [:]
            if string.contains("Each ore") {
                self.type = .ore
            } else if string.contains("Each clay") {
                self.type = .clay
            } else if string.contains("Each obsidian") {
                self.type = .obsidian
            } else {
                self.type = .geode
            }
            
            let words = string.components(separatedBy: " ")
            for word in words.enumerated() {
                if let amount = Int(word.element) {
                    self.costs[.init(rawValue: words[word.offset + 1])!] = amount
                }
            }
        }
        
        func canAfford(with resources: [Resource: Int]) -> Bool {
            costs.allSatisfy {
                resources[$0.key]! >= $0.value
            }
        }
    }
    
    struct Blueprint {
        var id: Int
        var oreRobot: Robot!
        var clayRobot: Robot!
        var obsidianRobot: Robot!
        var geodeRobot: Robot!
        
        init(string: String) {
            let topLevelComponents = string.components(separatedBy: ":")
            self.id = topLevelComponents[0].components(separatedBy: " ").last!.toInt()
            let costComponents = topLevelComponents[1].components(separatedBy: ". ").map { $0.trimmingCharacters(in: .punctuationCharacters) }
            for costComponent in costComponents {
                let robot = Robot(string: costComponent)
                if costComponent.contains("Each ore") {
                    self.oreRobot = robot
                } else if costComponent.contains("Each clay") {
                    self.clayRobot = robot
                } else if costComponent.contains("Each obsidian") {
                    self.obsidianRobot = robot
                } else {
                    self.geodeRobot = robot
                }
            }
        }
        
        func affordableRobots(resources: [Resource: Int]) -> [Robot] {
            [oreRobot, clayRobot, obsidianRobot, geodeRobot].filter { $0.canAfford(with: resources) }
        }
    }
    
    static var totalMinutes = 25
    let blueprints = input.components(separatedBy: "\n").map(Blueprint.init)
    
    
    func partOne() -> String {
        Self.totalMinutes = 25
        
        return blueprints.map {
            $0.id * bestGeodeOutcome(blueprint: $0)
        }.sum.description
    }
    
    func partTwo() -> String {
        Self.totalMinutes = 33
        
        return blueprints.prefix(3).reduce(1, {
            $0 * bestGeodeOutcome(blueprint: $1)
        }).description
    }
    
    private func bestGeodeOutcome(blueprint: Blueprint) -> Int {
        let miners = [Resource.ore]
        let resources: [Resource: Int] = [
            .ore: 0,
            .clay: 0,
            .obsidian: 0,
            .geode: 0
        ]
        
        var currentBest = 0
        
        let bestGeodeOutcome = processMinute(1, miners: miners, resources: resources, blueprint: blueprint, currentBest: &currentBest)
        return bestGeodeOutcome
    }
    
    private func performOptimisticRun(minutesRemaining: Int, miners: [Resource], resources: [Resource: Int], blueprint: Blueprint) -> Int {
        var miners = miners
        var resources = resources
        for _ in 1...minutesRemaining {
            if blueprint.geodeRobot.canAfford(with: resources) {
                miners.append(.geode)
                resources = resources.afterPayingFor(blueprint.geodeRobot)
            }
            if blueprint.obsidianRobot.canAfford(with: resources) {
                miners.append(.obsidian)
                resources = resources.afterPayingFor(blueprint.obsidianRobot)
            }
            if blueprint.clayRobot.canAfford(with: resources) {
                miners.append(.clay)
            }
            if blueprint.oreRobot.canAfford(with: resources) {
                miners.append(.ore)
            }
            
            resources = resources.afterCollectingFrom(miners)
        }
        
        return resources[.geode]!
    }
    
    private func processMinute(_ minute: Int, miners: [Resource], resources: [Resource: Int], blueprint: Blueprint, currentBest: inout Int) -> Int {
        if minute == Self.totalMinutes {
            if resources[.geode]! > currentBest {
                currentBest = resources[.geode]!
            }
            return resources[.geode]!
        }
        
        // performOptimisticRun does a simple, unrealistic run of the remaining minutes that buys whatever it can and doesn't charge anything
        //for new clay or ore robots. If this optimistic run still can't outperform our current best, then we can cut this run short.
        let optimisticGeodeCount = performOptimisticRun(minutesRemaining: Self.totalMinutes - minute, miners: miners, resources: resources, blueprint: blueprint)
        if optimisticGeodeCount <= currentBest {
            return resources[.geode]!
        }
        
        var buildOptions = blueprint.affordableRobots(resources: resources)
        
        if let geodeRobot = buildOptions.first(where: { $0.type == .geode }) {
            // Always build a geode robot if we can afford it.
            let resources = resources.afterPayingFor(geodeRobot).afterCollectingFrom(miners)
            var miners = miners
            miners.append(.geode)
            
            return processMinute(minute + 1, miners: miners, resources: resources, blueprint: blueprint, currentBest: &currentBest)
        } else if let obsidianRobot = buildOptions.first(where: { $0.type == .geode }), resources[.obsidian]! < blueprint.geodeRobot.costs[.obsidian]! {
            // Always build an obsidian robot if we can afford it, AND we can't afford a geode robot, AND the *reason* we can't afford a geode bot is
            // lack of obsidian.
            let resources = resources.afterPayingFor(obsidianRobot).afterCollectingFrom(miners)
            var miners = miners
            miners.append(.obsidian)
            
            return processMinute(minute + 1, miners: miners, resources: resources, blueprint: blueprint, currentBest: &currentBest)
            
        } else if buildOptions.isEmpty {
            let resources = resources.afterCollectingFrom(miners)
            return processMinute(minute + 1, miners: miners, resources: resources, blueprint: blueprint, currentBest: &currentBest)
        } else {
            buildOptions.append(.init(type: .doNothing, costs: [:]))
            
            // If we already have 4 ore robots — where 4 is the most ore it ever costs to build a single robot in the input data —
            // there is never a need to build any more.
            if miners.filter({ $0 == .ore }).count >= 4 {
                buildOptions.removeAll { $0.type == .ore }
            }
            
            let bestOptionResult = buildOptions.map {
                let resources = resources.afterPayingFor($0).afterCollectingFrom(miners)
                var miners = miners
                miners.append($0.type)
                
                return processMinute(minute + 1, miners: miners, resources: resources, blueprint: blueprint, currentBest: &currentBest)
            }.max()!
            
            return bestOptionResult
        }
    }
}

extension Dictionary where Key == Day19.Resource, Value == Int {
    func afterPayingFor(_ robot: Day19.Robot) -> Self {
        var newResources = self
        robot.costs.forEach {
            newResources[$0.key] = newResources[$0.key]! - $0.value
        }
        return newResources
    }
    
    func afterCollectingFrom(_ miners: [Day19.Resource]) -> Self {
        var newResources = self
        miners.forEach {
            guard $0 != .doNothing else { return }
            newResources[$0] = newResources[$0]! + 1
        }
        return newResources
    }
}

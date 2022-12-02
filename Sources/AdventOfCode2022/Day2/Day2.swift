import Foundation

struct Day2: Runnable {
    enum Play: Int {
        case rock = 0
        case paper = 1
        case scissors = 2
        
        init(_ letter: String) {
            switch letter {
            case "A", "X":
                self = .rock
            case "B", "Y":
                self = .paper
            case "C", "Z":
                self = .scissors
            default:
                self = .rock
            }
        }
        
        var score: Int {
            self.rawValue + 1
        }
        
        func resultScore(against play: Play) -> Int {
            if self == play {
                return 3
            } else if [1, -2].contains(self.rawValue - play.rawValue) {
                return 6
            } else {
                return 0
            }
        }
        
        var superiorPlay: Play {
            Play(rawValue: (self.rawValue + 1) % 3)!
        }
        
        var inferiorPlay: Play {
            var rawValue = self.rawValue - 1
            if rawValue < 0 { rawValue = 2 }
            return Play(rawValue: rawValue)!
        }
    }

    struct Round {
        var opponent: Play
        var you: Play
        
        var totalScore: Int {
            you.score + you.resultScore(against: opponent)
        }
    }

    let rawRounds = input.split(separator: "\n")
    
    func partOne() -> String {
        rawRounds.map { string -> Round in
            let plays = string.components(separatedBy: .whitespaces)
            return Round(opponent: .init(plays[0]), you: .init(plays[1]))
        }
        .reduce(0) { partialResult, round in
            return partialResult + round.totalScore
        }
        .description
    }
    
    func partTwo() -> String {
        rawRounds.map { string -> Round in
            let inputs = string.components(separatedBy: .whitespaces)
            let opponentPlay = Play(inputs[0])
            let outcome = inputs[1]
            let youPlay: Play
            if outcome == "X" {
                youPlay = opponentPlay.inferiorPlay
            } else if outcome == "Y" {
                youPlay = opponentPlay
            } else {
                youPlay = opponentPlay.superiorPlay
            }
            return Round(opponent: opponentPlay, you: youPlay)
        }
        .reduce(0) { partialResult, round in
            return partialResult + round.totalScore
        }
        .description
    }
}

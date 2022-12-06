import Foundation
import Algorithms

struct Day6: Runnable {
    
    let stream = Self.input
    
    func partOne() -> String {
        getMarkerPosition(uniqueStringLength: 4).description
    }
    
    func partTwo() -> String {
        getMarkerPosition(uniqueStringLength: 14).description
    }
    
    private func getMarkerPosition(uniqueStringLength: Int) -> Int {
        stream
            .windows(ofCount: uniqueStringLength)
            .enumerated()
            .first { Set($0.element).count == uniqueStringLength }!
            .offset + uniqueStringLength
    }
}

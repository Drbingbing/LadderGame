//
//  LadderGameObject.swift
//  GhostLeg
//
//  Created by Bing Bing on 2022/3/14.
//

import SwiftUI
import UIKit


class LadderGame: ObservableObject {
    
    @Published var players: [String] = ["hare", "ant", "pawprint", "ladybug"]
    
    @Published var currentPlayed: Set<String> = Set()
    
    @Published var rewards: [String] = ["", "", "", ""]
    
    @Published var endLocations: [CGPoint] = [CGPoint](repeating: .zero, count: 10)

    @Published var startLocations: [CGPoint] = [CGPoint](repeating: .zero, count: 10)
    
    @Published var routings: [[CGPoint]] = []
    
    var intersectRoutings = [Intersection]()
    
    var totalLadders = 10
    
    private var cachedRandom: [Int] = []
    private var cachedLadders = [String: [Int]]()
    
    
    func randoms(for player: String) -> [Int] {
        
        if let value = self.cachedLadders[player] {
            return value
        }
        
        let randoms = (0..<totalLadders)
            .filter({ !cachedRandom.contains($0) })
            .randomElementWithoutRepeating(self.ladder()).sorted()
        
        self.cachedRandom = randoms
        
        self.cachedLadders[player] = randoms
        
        return randoms
    }
    
    func ladder() -> Int {
        Int.random(in: 3...5)
    }
    
    func updatingRoute(for player: String) {
        guard let index = self.players.firstIndex(of: player) else { return }
        
        let startLocation = self.routings[index].last!
        
        if startLocation.y > endLocations[index].y {
            return
        }
        
        if let matchingPoint = self.nextVerticalPoint(for: startLocation) {
            
            withAnimation(.linear(duration: 0.2)) {
                self.routings[index].append(matchingPoint.current)
                
            }
            
            withAnimation(.linear(duration: 0.2).delay(0.2)) {
                self.routings[index].append(matchingPoint.nearest)
                
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.updatingRoute(for: player)
            }
        }
        
        else {
            
            for (endLocationIndex, endLocation) in endLocations.enumerated() {
                if endLocation.x == startLocation.x {
                    self.routings[index].append(endLocation)
                    withAnimation(.linear) {
                        self.rewards[endLocationIndex] = player
                    }
                    self.currentPlayed.remove(player)
                }
            }
        }
    }
    
    private func nextVerticalPoint(for current: CGPoint) -> Intersection? {
        
        if let matchingPoint = self.intersectRoutings.filter({
            $0.current.x == current.x &&
            $0.current.y > current.y
        }).sorted(by: {
            $0.current.y < $1.current.y
        }).first {
            return matchingPoint
        }
        
        return nil
    }
}

//
//  GhostLeg.swift
//  GhostLeg
//
//  Created by Bing Bing on 2022/3/9.
//

import SwiftUI


struct Intersection {
    
    var current: CGPoint
    
    var nearest: CGPoint
}


struct LadderGameView: View {
    
    @StateObject var ladderGame: LadderGame = LadderGame()
    
    var body: some View {
        
        VStack {
            
            self.ladderGameView()
                .overlay(
                    self.routingPaths()
                )
                .overlay(
                    self.runners()
                )
                .overlay(
                    self.markers()
                )
                .onTapGesture {
                    self.prepareRoute()
                }
                .padding()
            
        }
        .padding()
        .padding(.top, 20)
        .padding(.bottom, 20)
    }
    
    func ladderGameView() -> some View {
        
        GeometryReader { geo in
            
            if !self.ladderGame.players.isEmpty  {
                
                VStack {
                    
                    let columns = 4
                    
                    let width = geo.size.width / CGFloat(columns - 1)
                    
                    ZStack {
                        
                        ColumnsView(columns: ladderGame.players.count)
                            .stroke(Color(uiColor: .label))
                        
                        ForEach(0..<columns - 1, id: \.self) { index in
                            
                            BarShape(
                                ladders: ladderGame.totalLadders,
                                bars: ladderGame.randoms(for: ladderGame.players[index]),
                                barWidth: width,
                                offset: width * CGFloat(index),
                                intersections: { intersection in
                                    
                                    let instersections = [
                                        Intersection(current: intersection[0],
                                                     nearest: intersection[1]),
                                        Intersection(current: intersection[1],
                                                     nearest: intersection[0])
                                    ]
                                    
                                    self.ladderGame.intersectRoutings.append(contentsOf: instersections)
                                }
                            ).stroke()
                        }
                    }
                }
            }
        }
    }
    
    func markers() -> some View {
        GeometryReader { geo in
            
            ForEach(0..<self.ladderGame.players.count, id: \.self) { index in
                
                let startLocation = self.ladderGame.startLocations[index]
                let endLocation = self.ladderGame.endLocations[index]
                
                let player = self.ladderGame.players[index]
                
                ZStack {
                    Image(systemName: player)
                        .resizable()
                        .foregroundColor(
                            self.ladderGame.currentPlayed.contains(player) ? Color.yellow : Color(uiColor: .label)
                        )
                        .frame(width: 40, height: 40)
                        .position(startLocation)
                        .offset(y: -20)
                        .onTapGesture {
                            self.ladderGame.currentPlayed.insert(player)
                            self.ladderGame.updatingRoute(for: player)
                        }
                    
                    let reward = self.ladderGame.rewards[index]
                    
                    Image(systemName: reward)
                        .resizable()
                        .foregroundColor(
                            self.ladderGame.currentPlayed.contains(reward) ? Color.yellow : Color(uiColor: UIColor.label)
                        )
                        .frame(width: 40, height: 40)
                        .position(endLocation)
                        .offset(y: 20)
                        
                }
                
            }
            .onAppear {
                self.calculateEndLocations(in: geo.size)
                self.calculateStartLocation(in: geo.size)
                self.prepareRoute()
            }
        }
    }
    
    func runners() -> some View {
        
        GeometryReader { geo in
            ForEach(0..<self.ladderGame.routings.count, id: \.self) { index in
                let player = self.ladderGame.players[index]
                
                let last = self.ladderGame.routings[index].last ?? .zero
                
                Circle()
                    .fill(
                        self.ladderGame.rewards.contains(player) ? Color.clear :
                        
                            self.ladderGame.currentPlayed.contains(player) ? Color.yellow : Color.clear
                    )
                    .frame(width: 20, height: 20)
                    .position(last)
            }
        }
    }
    
    func routingPaths() -> some View {
        ZStack {

            let routings = self.ladderGame.routings
            ForEach(0..<routings.count, id: \.self) { index in

                let player = self.ladderGame.players[index]
                let routes = self.ladderGame.routings[index]
                
                let shouildDrop = (routes.last?.y ?? 0) < self.ladderGame.endLocations[index].y
                
                
                CustomPathShape(routes: shouildDrop ? routes.dropLast() :
                                    routes)
                    .stroke(
                        self.ladderGame.currentPlayed.contains(player) ? Color.yellow : Color.gray,
                        lineWidth: 3
                    )
                    .zIndex(self.ladderGame.currentPlayed.contains(player) ? 1 : 0)
            }
        }
    }
    
    func calculateEndLocations(in size: CGSize) {
        
        let space = size.width / CGFloat(self.ladderGame.players.count - 1)
        
        var endLocations = [CGPoint](repeating: .zero, count: self.ladderGame.players.count)
        
        for index in 0..<self.ladderGame.players.count {
            let offset = space * CGFloat(index)
            endLocations[index] = CGPoint(x: offset, y: size.height)
        }
        
        self.ladderGame.endLocations = endLocations
    }
    
    func calculateStartLocation(in size: CGSize) {
        
        let space = size.width / CGFloat(self.ladderGame.players.count - 1)
        
        var startLocations = [CGPoint](repeating: .zero, count: self.ladderGame.players.count)
        
        for index in 0..<self.ladderGame.players.count {
            
            let offset = space * CGFloat(index)
            startLocations[index] = CGPoint(x: offset, y: 0)
        }
        
        self.ladderGame.startLocations = startLocations
    }
    
    func prepareRoute() {
        
        self.ladderGame.currentPlayed = []
        
        self.ladderGame.routings = .init(repeating: [], count: self.ladderGame.players.count)
        
        self.ladderGame.rewards = .init(repeating: "questionmark.circle", count: self.ladderGame.players.count)
        
        for (index, startLocation) in self.ladderGame.startLocations.enumerated() {
            
            self.ladderGame.routings[index] = [startLocation]
        }
    }
    
}

extension RangeExpression where Bound: FixedWidthInteger {
    func randomElements(_ n: Int) -> [Bound] {
        precondition(n > 0)
        
        switch self {
        case let range as Range<Bound>: return (0..<n).map { _ in .random(in: range) }
        case let range as ClosedRange<Bound>: return (0..<n).map { _ in .random(in: range) }
        default: return []
        }
    }
    
    func randomElementWithoutRepeating(_ n: Int) -> [Bound] {
        
        precondition(n > 0)
        
        var bounds = [Bound]()
        
        switch self {
            
        case let range as Range<Bound>:
            
            while bounds.count < n {
                
                let randomNum = Bound.random(in: range)
                
                if !bounds.contains(randomNum) {
                    bounds.append(randomNum)
                }
                
            }
            
        case let range as ClosedRange<Bound>:
            
            while bounds.count < n {
                
                let randomNum = Bound.random(in: range)
                
                if !bounds.contains(randomNum) {
                    bounds.append(randomNum)
                }
                
            }
            
        default: bounds = []
        }
        
        return bounds
    }
}

extension Range where Bound: FixedWidthInteger {
    var randomElement: Bound { .random(in: self) }
}

extension ClosedRange where Bound: FixedWidthInteger {
    var randomElement: Bound { .random(in: self) }
}

extension Array where Element: Hashable {
    
    func randomElementWithoutRepeating(_ n: Int) -> [Element] {
        
        precondition(n > 0)
        precondition(self.count > 0)
        
        var elements = [Element]()
        
        while elements.count < n {
            
            let randomNum = self.randomElement()!
            
            if !elements.contains(randomNum) {
                elements.append(randomNum)
            }
            
        }
        
        return elements
    }
    
}

struct GhostLeg_Previews: PreviewProvider {
    static var previews: some View {
        LadderGameView()
    }
}

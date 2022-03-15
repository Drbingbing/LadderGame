//
//  BarShape.swift
//  GhostLeg
//
//  Created by Bing Bing on 2022/3/14.
//

import SwiftUI

struct BarShape: Shape {
    
    var ladders: Int

    var bars: [Int]
    
    var barWidth: CGFloat
    
    var offset: CGFloat = 0
    
    var intersections: ([CGPoint]) -> Void
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        
        let barSpace = rect.height / (CGFloat(ladders + 1))
        
        let origin = rect.origin
        
        for bar in 0..<ladders {
            
            let y = origin.y + barSpace * CGFloat(bar + 1)
            
            let start = CGPoint(x: origin.x + offset, y: y)
            path.move(to: start)
            
            if self.bars.contains(bar) {
                
                let end = CGPoint(x: barWidth + offset, y: y)
                path.addLine(to: end)
                
                self.intersections([start, end])
            }
        }
        
        return path
    }
    
}


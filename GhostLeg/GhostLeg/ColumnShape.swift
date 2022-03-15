//
//  ColumnShape.swift
//  GhostLeg
//
//  Created by Bing Bing on 2022/3/14.
//

import SwiftUI


struct ColumnsView: Shape {
    
    var columns: Int
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        
        let origin = rect.origin
        
        let space = rect.width / max(1, CGFloat(columns) - 1)
        
        for column in 0..<columns {
            
            let x = origin.x + space * CGFloat(column)
            
            let start = CGPoint(x: x, y: origin.y)
            
            path.move(to: start)
            
            let end = CGPoint(x: x, y: rect.height)
            
            path.addLine(to: end)
        }
        
        return path
    }
}

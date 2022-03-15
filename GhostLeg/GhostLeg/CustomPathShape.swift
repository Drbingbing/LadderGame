//
//  CustomPathShape.swift
//  GhostLeg
//
//  Created by Bing Bing on 2022/3/14.
//

import SwiftUI

struct CustomPathShape: Shape {
    
    var routes: [CGPoint]
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        
        for (index, route) in routes.enumerated() {
            
            if index == 0 {
                path.move(to: route)
            }
            
            else {
                
                path.addLine(to: route)
            }
            
        }
        
        return path
    }
}

struct CustomPathShape_Previews: PreviewProvider {
    static var previews: some View {
        CustomPathShape(routes: [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 0, y: 100),
            CGPoint(x: 100, y: 100)
        ])
            .stroke()
            .frame(width: 100, height: 100)
    }
}

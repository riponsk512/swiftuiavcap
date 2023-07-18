//
//  ProgressBar.swift
//  swiftuiavcap
//
//  Created by Ripon sk on 17/07/23.
//

import SwiftUI

struct ProgressBar: View {
    @Binding var val:CGFloat
    var colors =  Color.red
    var body: some View {
        ZStack{
            Circle()
                .stroke(lineWidth: 20)
                .fill(.gray)
            Circle().trim(from: 0,to: min(val, 1.0)).stroke(style: StrokeStyle(lineWidth: 12,lineCap: .round,lineJoin: .round))
                .foregroundColor(colors)
                .rotationEffect(Angle(degrees: 270))
                .animation(.easeInOut(duration: 2.0))
        }
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(val: .constant(0.8))
    }
}

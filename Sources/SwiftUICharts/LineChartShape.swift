//
//  SwiftUIView.swift
//  
//
//  Created by Majid Jabrayilov on 24.09.20.
//
import SwiftUI

struct LineChartShape: Shape {
    let dataPoints: [DataPoint]
    var closePath: Bool = true
    var lineStyle: LineChartStyle.LineStyle

    func path(in rect: CGRect) -> Path {
        Path { path in
            let start = CGFloat(dataPoints.first?.value ?? 0) / CGFloat(dataPoints.max()?.value ?? 1)
            path.move(to: CGPoint(x: 0, y: rect.height - rect.height * start))
            let stepX = rect.width / CGFloat(dataPoints.count)
            var currentX: CGFloat = 0
            dataPoints.forEach {
                currentX += stepX
                let y = CGFloat($0.value / (dataPoints.max()?.value ?? 1)) * rect.height
                path.addLine(to: CGPoint(x: currentX, y: rect.height - y))
            }
            
            switch lineStyle {
            case .fill:
                if closePath {
                    path.addLine(to: CGPoint(x: currentX, y: rect.height))
                    path.addLine(to: CGPoint(x: 0, y: rect.height))
                    path.closeSubpath()
                }
            case .line:
                //currentX += 2
                dataPoints.reversed().forEach {
                    let y = CGFloat($0.value / (dataPoints.max()?.value ?? 1)) * rect.height - 3
                    path.addLine(to: CGPoint(x: currentX, y: rect.height - y))
                    currentX -= stepX
                }
                path.closeSubpath()
            }
        }
    }
}

#if DEBUG
struct LineChartShape_Previews: PreviewProvider {
    static var previews: some View {
        LineChartShape(dataPoints: DataPoint.mock, lineStyle: .line)
    }
}
#endif

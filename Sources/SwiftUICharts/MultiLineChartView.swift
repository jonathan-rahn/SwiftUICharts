//
//  MultiLineChartView.swift
//
//  Created by Jonathan Rahn on 2/26/21.
//  Copyright © 2021 Jonathan Rahn. All rights reserved.
//
import SwiftUI

/// Type that defines a line chart style.
public struct MultiLineChartStyle: ChartStyle {
    
    public enum LineStyle {
        case fill, line(StrokeStyle)
    }
    
    public let lineMinHeight: CGFloat
    public let showAxis: Bool
    public let axisLeadingPadding: CGFloat
    public let showLabels: Bool
    public let labelCount: Int?
    public let showLegends: Bool
    public let lineStyle: LineStyle

    /**
     Creates new line chart style with the following parameters.

     - Parameters:
        - lineMinHeight: The minimal height for the point that presents the biggest value. Default is 100.
        - showAxis: Bool value that controls whenever to show axis.
        - axisLeadingPadding: Leading padding for axis line. Default is 0.
        - showLabels: Bool value that controls whenever to show labels.
        - labelCount: The count of labels that should be shown below the the chart. Default is all.
        - showLegends: Bool value that controls whenever to show legends.
     */

    public init(
        lineMinHeight: CGFloat = 100,
        showAxis: Bool = true,
        axisLeadingPadding: CGFloat = 0,
        showLabels: Bool = true,
        labelCount: Int? = nil,
        showLegends: Bool = true,
        lineStyle: LineStyle = .fill
    ) {
        self.lineMinHeight = lineMinHeight
        self.showAxis = showAxis
        self.axisLeadingPadding = axisLeadingPadding
        self.showLabels = showLabels
        self.labelCount = labelCount
        self.showLegends = showLegends
        self.lineStyle = lineStyle
    }
}

public struct DataSeries: Identifiable {
    let dataPoints: [DataPoint]
    let legend: Legend
    public let id = UUID()
}

/// SwiftUI view that draws data points by drawing a line.
public struct MultiLineChartView: View {
    @Environment(\.chartStyle) var chartStyle
    
    let dataSeries: [DataSeries]

    /**
     Creates new line chart view with the following parameters.

     - Parameters:
        - dataPoints: The array of data points that will be used to draw the bar chart.
     */
    public init(dataSeries: [DataSeries]) {
        self.dataSeries = dataSeries
    }

    private var style: LineChartStyle {
        (chartStyle as? LineChartStyle) ?? .init()
    }

    private func gradient(series: DataSeries) -> LinearGradient {
        let colors = [series.legend.color, series.legend.color]
        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var maxDataPoints: [DataPoint] {
        dataSeries
            .max {
                $0.dataPoints.map(\.value).max()! < $1.dataPoints.map(\.value).max()!
            }!.dataPoints
            
    }

    private var grid: some View {
        ChartGrid(dataPoints: maxDataPoints)
            .stroke(
                style.showAxis ? Color.secondary : .clear,
                style: StrokeStyle(
                    lineWidth: 1,
                    lineCap: .round,
                    lineJoin: .round,
                    miterLimit: 0,
                    dash: [1, 8],
                    dashPhase: 1
                )
            )
    }

    public var body: some View {
        VStack {
            HStack(spacing: 0) {
                ZStack {
                    ForEach(dataSeries) { serie in
                        Group {
                            switch style.lineStyle {
                            case .fill:
                                LineChartShape(dataPoints: serie.dataPoints, closePath: true)
                                    .fill(gradient(series: serie))
                            case .line:
                                LineChartShape(dataPoints: serie.dataPoints, closePath: false)
                                    .stroke(gradient(series: serie), style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                                
                            }
                        }
                        .drawingGroup()
                        .frame(minHeight: style.lineMinHeight)
                        .background(grid)
                    }
                }

                if style.showAxis {
                    AxisView(dataPoints: maxDataPoints)
                        .accessibilityHidden(true)
                        .padding(.leading, style.axisLeadingPadding)
                }
            }

            if style.showLabels {
                LabelsView(dataPoints: maxDataPoints, labelCount: style.labelCount ?? maxDataPoints.count)
                    .accessibilityHidden(true)
            }

            if style.showLegends {
                LegendView(legends: dataSeries.map(\.legend))
                    .padding()
                    .accessibilityHidden(true)
            }
        }
    }
}

#if DEBUG
struct MultiLineChartView_Previews: PreviewProvider {
    
    static let series = [DataSeries(dataPoints: DataPoint.mock, legend: Legend(color: .blue, label: "Series 1")), DataSeries(dataPoints: DataPoint.mock2, legend: Legend(color: .orange, label: "Series 1"))]
    
    static var previews: some View {
        HStack {
            MultiLineChartView(dataSeries: series)
                .chartStyle(LineChartStyle(showAxis: false, showLabels: false, lineStyle: .line(StrokeStyle())))
            MultiLineChartView(dataSeries: series)
        }.chartStyle(LineChartStyle(showAxis: false, showLabels: false))
    }
}
#endif

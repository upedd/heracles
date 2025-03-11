//
//  ExerciseChartView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 15/02/2025.
//

import SwiftUI
import Charts

enum ChartType {
    case bar
    case line
}

struct ChartData {
    var value: Double
    var date: Date
}

// TODO: handle no data case for functions
// TODO: handle if only one data point don't show function name!

struct ChartFunction {
    var function: ([Double]) -> Double
    var name: String
    
    static let sum = ChartFunction(function: { $0.reduce(0, +)}, name: "Total")
    static let max = ChartFunction(function: { $0.max() ?? 0 }, name: "Max")
}


struct ExerciseChartHeader : View {
    var title: String
    var value: String
    var unit: String
    var range: Range<Date>
    
    var body : some View {
        VStack(alignment: .leading) {
            Text(title)
                .textCase(.uppercase)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline) {
                Text(value)
                    .font(.system(.largeTitle, design: .rounded, weight: .medium))
                Text(unit)
                    .font(.headline.bold())
                    .foregroundStyle(.secondary)
            }
            Text((range.lowerBound..<range.upperBound.addingTimeInterval(-1)).formatted(.interval.day().month(.abbreviated).year()))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }
}


struct ChartInterval {
    var addAmount: TimeInterval // TODO: ideally eliminate this
    var length: TimeInterval
    var unit: Calendar.Component
    var format: Date.FormatStyle
    var axisLabelPredicate: (Date) -> Bool // whetever to show axis label for given date
    var majorAlignment: DateComponents? // scroll alignment when swipped also draws continuous axis line
    var dateBinsGenerator: ([ChartData]) -> DateBins
    
    // TODO: more complete date bins endings
    
    static let week = ChartInterval(
        addAmount: 86400 * 6,
        length: 86400 * 7,
        unit: .day,
        format: Date.FormatStyle().weekday(.abbreviated),
        axisLabelPredicate: {_ in true},
        majorAlignment: DateComponents(weekday: 2),
        dateBinsGenerator: { data in
            DateBins(unit: .day, range: data.last!.date...data.first!.date)
        }
    )
    
    static let month = ChartInterval(
        addAmount: 86400 * 30,
        length: 86400 * 31,
        unit: .day,
        format: Date.FormatStyle().day(),
        axisLabelPredicate: {date in Calendar.current.component(.weekday, from: date) == 2 },
        majorAlignment: DateComponents(day: 1),
        dateBinsGenerator: { data in
            DateBins(unit: .day, range: data.last!.date...data.first!.date)
        }
    )
    
    static let sixMonths = ChartInterval(
        addAmount: 86400 * 31 * 6 - 86400,
        length: 86400 * 31 * 6,
        unit: .weekOfYear,
        format: Date.FormatStyle().month(.abbreviated),
        axisLabelPredicate: {date in Calendar.current.component(.day, from: date) == 1},
        majorAlignment: nil,
        dateBinsGenerator: { data in
            DateBins(unit: .weekOfYear, range: data.last!.date...data.first!.date)
        }
    )
    
    static let year = ChartInterval(
        addAmount: 86400 * 365 - 86400,
        length: 86400 * 365,
        unit: .month,
        format: Date.FormatStyle().month(.narrow),
        axisLabelPredicate: {date in Calendar.current.component(.day, from: date) == 1},
        majorAlignment: DateComponents(day: 1),
        dateBinsGenerator: { data in
            DateBins(unit: .month, range: data.last!.date...data.first!.date)
        }
    )
}

extension ChartBinRange {
    // NOTE: that this technically can lose information as chart bin ranges can be both closed and opened. We assume that they are always opened.
    func toRange() -> Range<Bound> {
        lowerBound..<upperBound
    }
}
extension Collection {
    // Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}


struct ExerciseChart : View {
    static let SelectionIndicatorShape: Color = Color.gray.opacity(0.3)

    struct ChartSelectionIndicator: ChartContent {
        var value: Date
            
        var body : some ChartContent {
            RuleMark(
                x: .value("Selected", value, unit: .day)
            )
            .foregroundStyle(SelectionIndicatorShape)
            .zIndex(-1)

        }
    }
    
    
    struct SelectionIndicatorHeaderPart: View {
        var x: CGFloat
        var height: CGFloat
        var body : some View {
            SelectionIndicatorShape
                .frame(width: 2, height: height)
                .position(x: x)
                .offset(y: -height / 2)
        }
    }
    
    struct SelectionHeader : View {
        var containerWidth: CGFloat
        var x: CGFloat
        var endX: CGFloat?
        var sum: Double
        var range: Range<Date>
        var distanceFromChart: CGFloat
        var functionName: String
        
        @State private var size: CGSize = .zero
        
        private var anchorX: CGFloat {
            if let endX {
                return (x + endX) / 2
            }
            return x
        }
        
        var body : some View {
            Group {
                ExerciseChartHeader(title: functionName, value: sum.formatted(), unit: "kg", range: range)
                    .frame(minWidth: endX != nil ? endX! - x : 0, alignment: .leading)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 0.5)
                    .background(Material.regular)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .onGeometryChange(for: CGSize.self) { proxy in
                        proxy.size
                    } action: {
                        size = $0
                    }
                
                    .position(x: min(max(anchorX, size.width / 2), containerWidth - size.width / 2))
                    .offset(y: -size.height / 2 - distanceFromChart)
                SelectionIndicatorHeaderPart(x: x, height: distanceFromChart)
                if let endX {
                    SelectionIndicatorHeaderPart(x: endX, height: distanceFromChart)
                }
            }
        }
    }
    private let intervals: KeyValuePairs<String, ChartInterval> = [
        "W": .week,
        "M": .month,
        "6M": .sixMonths,
        "Y": .year
        ]
    
    var data: [ChartData]
    var type: ChartType
    var function: ChartFunction
    @State private var rawInterval: String = "W"
    
    @State private var chartBars: [(range: Range<Date>, value: Double)] = []
    
    func makeChartBars() -> [(range: Range<Date>, value: Double)] {
        interval.dateBinsGenerator(data).map { bin in
            (bin.toRange(),
             function.function(data.filter { bin.contains($0.date) }.map(\.value)))
        }
    }
    
    @State private var visibleChartBars: [(range: Range<Date>, value: Double)] = []
    
    func getVisibleChartBars() -> [(range: Range<Date>, value: Double)] {
        chartBars.filter { currentDateRange.contains($0.range.lowerBound) }
    }
    
    private var interval: ChartInterval {
        intervals.first(where: { k, _ in
            k == rawInterval
        })?.value ?? .week
    }
    
    // TODO: fix scroll position between ranges
    // TODO: fix weird animation!
    // TODO: only show current month when on the first day of the month in monthly interval
    
    @State private var _scrollPosition: Date?
    private var scrollPosition: Binding<Date> {
        Binding { _scrollPosition ?? Calendar.current.startOfDay(for: Date.now).addingTimeInterval(-interval.addAmount) }
        set: { newValue in
            _scrollPosition = newValue.roundToNearestHour() // is this bad?
            visibleChartBars = getVisibleChartBars()
        }
    }
    
    
    private var currentDateRange: Range<Date> {
        return scrollPosition.wrappedValue..<(scrollPosition.wrappedValue.addingTimeInterval(interval.length))
    }
    // TODO: rename
    private var visibleSum: Double {
        function.function(visibleChartBars.map(\.value))
    }
    
    @State private var yAxisValues: [Double]  = []
    
    func calculateYAxisValues() -> [Double] {
        let data = visibleChartBars.map(\.value)
        let minBins = NumberBins(data: data, desiredCount: 2).thresholds
        let autoBins = NumberBins(data: data).thresholds
        if autoBins.count > minBins.count {
            return autoBins
        }
        return minBins
    }
    
    
    @State private var rawSelectedDate: Date?
    private var selectedBin: Range<Date>? {
        if let rawSelectedDate {
            let bar = visibleChartBars.filter { _, value in
                value > 0
            }.min { a, b in
                abs(a.range.midpoint.timeIntervalSince(rawSelectedDate)) < abs(b.range.midpoint.timeIntervalSince(rawSelectedDate))
            }
            if let bar {
                return bar.range
            }
        }
        return nil
    }
    
    @State private var rawSelectedRange: ClosedRange<Date>?
    
    private var selectedRangeStart: Range<Date>? {
        if let rawSelectedRange {
            let start = visibleChartBars.filter { _, value in
                value > 0
            }.min { a, b in
                abs(a.range.midpoint.timeIntervalSince(rawSelectedRange.lowerBound)) < abs(b.range.midpoint.timeIntervalSince(rawSelectedRange.lowerBound))
            }
            return start?.range
        }
        return nil
    }
    
    private var selectedRangeEnd: Range<Date>? {
        if let rawSelectedRange {
            let end = visibleChartBars.filter { _, value in
                value > 0
            }.min { a, b in
                abs(a.range.midpoint.timeIntervalSince(rawSelectedRange.upperBound)) < abs(b.range.midpoint.timeIntervalSince(rawSelectedRange.upperBound))
            }
            return end?.range
        }
        return nil
    }
    
    
    private var selectedChartRange: Range<Date>? {
        if selectedRangeStart != nil && selectedRangeEnd != nil {
            return selectedRangeStart!.lowerBound..<selectedRangeEnd!.upperBound
        }
        return nil
    }
    
    var selectedAmount: Double? {
        if let selectedBin {
            return function.function(data.filter { selectedBin.contains(Calendar.current.startOfDay(for: $0.date)) }.map(\.value))
            
        } else if let selectedChartRange {
            return function.function(
                data.filter {
                    selectedChartRange.contains($0.date)
                }
                    .map(\.value)
            )
        }
        return nil
    }
    
    var body : some View {
        VStack {
            Picker("Date Range", selection: $rawInterval) {
                ForEach(Array(intervals), id: \.key) { key, _ in
                    Text(key)
                }
            }
            .pickerStyle(.segmented)
            ExerciseChartHeader(title: function.name, value: visibleSum.formatted(), unit: "kg", range: currentDateRange)
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(selectedAmount != nil ? 0.0 : 1.0)
                .accessibilityHidden(selectedAmount != nil)
            
            
            Chart {
                ForEach(chartBars, id: \.range.lowerBound) {range, value in
                    if type == .bar {
                        BarMark(
                            x: .value("Date", range.lowerBound, unit: interval.unit),
                            y: .value("Volume", value)
                        )
                    } else if type == .line {
                        if value > 0 {
                            LineMark(
                                x: .value("Date", range.lowerBound, unit: interval.unit),
                                y: .value("Volume", value)
                            )
                            PointMark(
                                x: .value("Date", range.lowerBound, unit: interval.unit),
                                y: .value("Volume", value)
                            )
                        }
                    }
                    
                }
                if let selectedBin {
                    ChartSelectionIndicator(value: selectedBin.midpoint)
                } else if selectedChartRange != nil {
                    ChartSelectionIndicator(value: selectedRangeStart!.midpoint)
                    ChartSelectionIndicator(value: selectedRangeEnd!.midpoint)
                }
            }
            .chartYScale(domain: [0.0, yAxisValues.max() ?? 100.0])
            .onChange(of: rawInterval) {
                chartBars = makeChartBars()
                visibleChartBars = getVisibleChartBars()
                withAnimation {
                    yAxisValues = calculateYAxisValues()
                }
            }
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: interval.length)
            .chartScrollTargetBehavior(
                .valueAligned(
                    matching: DateComponents(hour: 0, minute: 0, second: 0),
                    majorAlignment: interval.majorAlignment != nil ? .matching(interval.majorAlignment!) : .page
                ))
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { date in
                    if interval.majorAlignment != nil && Calendar.current.date(date.as(Date.self)!, matchesComponents: interval.majorAlignment!) {
                        AxisGridLine(stroke: .init(lineWidth: 0.5))
                            .foregroundStyle(Color(uiColor: .systemGray4))
                        AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                    } else if interval.axisLabelPredicate(date.as(Date.self)!) {
                        AxisGridLine()
                            .foregroundStyle(Color(uiColor: .systemGray4))
                        AxisTick()
                    }
                    if interval.axisLabelPredicate(date.as(Date.self)!) {
                        AxisValueLabel(format: interval.format)
                            .foregroundStyle(Color(uiColor: .systemGray4))
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: yAxisValues) { value in
                    AxisGridLine()
                        .foregroundStyle(Color(uiColor: .systemGray4))
                    AxisValueLabel()
                        .foregroundStyle(Color(uiColor: .systemGray4))
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                }
            }
            
            .chartScrollPosition(x: scrollPosition)
            .onScrollPhaseChange { oldPhase, newPhase in
                guard oldPhase != newPhase else {return}
                if newPhase == .idle {
                    withAnimation{
                        yAxisValues = calculateYAxisValues()
                    }
                }
            }
            .chartXSelection(value: $rawSelectedDate)
            .chartXSelection(range: $rawSelectedRange)
            .animation(.spring(), value: rawInterval)
            .chartOverlay{ proxy in
                GeometryReader { geometry in
                    let plotFrameGeometry = geometry[proxy.plotFrame!]
                    let origin = plotFrameGeometry.origin
                    if let selectedBin {
                        let position = proxy.position(forX: selectedBin.midpoint)!
                        let x = position + origin.x
                        SelectionHeader(containerWidth: geometry.size.width, x: x, sum: selectedAmount!, range: selectedBin, distanceFromChart: 10, functionName: function.name)
                    } else if let selectedChartRange {
                        let lower_position = proxy.position(forX: selectedRangeStart!.midpoint)!
                        let x1 = lower_position + origin.x
                        let upper_position = proxy.position(forX: selectedRangeEnd!.midpoint)!
                        let x2 = upper_position + origin.x
                        SelectionHeader(containerWidth: geometry.size.width, x: x1, endX: x2, sum: selectedAmount!, range: selectedChartRange, distanceFromChart: 10, functionName: function.name)
                    }
                }
            }
            .frame(height: 270)
            .onAppear {
                chartBars = makeChartBars()
                visibleChartBars = getVisibleChartBars()
                yAxisValues = calculateYAxisValues()
            }
        }
    }
}

struct ExerciseChartView: View {
    var title: String
    var data: [ChartData]
    var type: ChartType
    var function: ChartFunction
    var body: some View {
        ScrollView {
            ExerciseChart(data: data, type: type, function: function)
        }
        .padding()
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let data: [ChartData] = [
        .init(value: 250, date: Date()),
        .init(value: 220, date: Date().addingTimeInterval(-86400)),
        .init(value: 220, date: Date().addingTimeInterval(-86400 * 2)),
        .init(value: 200, date: Date().addingTimeInterval(-86400 * 3)),
        .init(value: 210, date: Date().addingTimeInterval(-86400 * 5)),
        .init(value: 190, date: Date().addingTimeInterval(-86400 * 6)),
        .init(value: 180, date: Date().addingTimeInterval(-86400 * 8)),
        .init(value: 180, date: Date().addingTimeInterval(-86400 * 11)),
        .init(value: 190, date: Date().addingTimeInterval(-86400 * 12)),
        .init(value: 185, date: Date().addingTimeInterval(-86400 * 14)),
        .init(value: 170, date: Date().addingTimeInterval(-86400 * 16)),
        .init(value: 170, date: Date().addingTimeInterval(-86400 * 17)),
        .init(value: 165, date: Date().addingTimeInterval(-86400 * 20)),
        .init(value: 160, date: Date().addingTimeInterval(-86400 * 22)),
        .init(value: 170, date: Date().addingTimeInterval(-86400 * 25)),
        .init(value: 160, date: Date().addingTimeInterval(-86400 * 26)),
        .init(value: 150, date: Date().addingTimeInterval(-86400 * 28)),
        .init(value: 150, date: Date().addingTimeInterval(-86400 * 31)),
        .init(value: 150, date: Date().addingTimeInterval(-86400 * 33)),
        .init(value: 145, date: Date().addingTimeInterval(-86400 * 34)),
        .init(value: 140, date: Date().addingTimeInterval(-86400 * 37)),
        .init(value: 135, date: Date().addingTimeInterval(-86400 * 39)),
        .init(value: 140, date: Date().addingTimeInterval(-86400 * 40)),
        .init(value: 145, date: Date().addingTimeInterval(-86400 * 41)),
        .init(value: 130, date: Date().addingTimeInterval(-86400 * 44)),
        .init(value: 125, date: Date().addingTimeInterval(-86400 * 45)),
    ]
    NavigationStack {
        ExerciseChartView(title: "Volume", data: data, type: .bar, function: .sum)
    }
}

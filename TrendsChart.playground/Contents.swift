import Foundation
import SwiftUI
import Charts
import PlaygroundSupport

/// Data holder classes
struct TrendsLineChartData {
    let date: Date
    let burned: Double
    let consumed: Double
}
struct DateToCalories {
    let date: Date
    let calories: Double
}
struct DailyCalorieMap{
    let restingByDay:[DateToCalories]
    let dietaryByDay:[DateToCalories]
    let activeByDay:[DateToCalories]
}

/// ViewModel for managing chart data
struct TrendsLineChartViewModel {
    let calendar = Calendar.autoupdatingCurrent
    let data: [TrendsLineChartData]
    let chartRange: ClosedRange<Double>
    
    init(dailyCalorieMap: DailyCalorieMap){
        self.data = TrendsLineChartViewModel.calculateData(dailyCalorieMap: dailyCalorieMap)
        self.chartRange = TrendsLineChartViewModel.calculateRange(dailyCalorieMap: dailyCalorieMap)
    }
    
    private static func calculateData(dailyCalorieMap: DailyCalorieMap) -> [TrendsLineChartData] {
        var trendsLineChartData: [TrendsLineChartData] = []
        
        for day in 0...6 {
            let restingValue = dailyCalorieMap.restingByDay[day].calories
            let activeValue = dailyCalorieMap.activeByDay[day].calories
            let dietaryValue = dailyCalorieMap.dietaryByDay[day].calories
            
            trendsLineChartData.append(
                TrendsLineChartData(
                    date: dailyCalorieMap.activeByDay[day].date,
                    burned: restingValue + activeValue,
                    consumed: dietaryValue
                )
            )
        }
        
        return trendsLineChartData
    }
    
    private static func calculateRange(dailyCalorieMap:DailyCalorieMap) -> ClosedRange<Double> {
        var values:[Double] = []
        for day in 0...6{
            let restingValue = dailyCalorieMap.restingByDay[day].calories
            let activeValue = dailyCalorieMap.activeByDay[day].calories
            let dietaryValue = dailyCalorieMap.dietaryByDay[day].calories
            values += [restingValue + activeValue, dietaryValue]
        }
        let min = values.min()!
        let max = values.max()!
        let diff = max - min
        let padding = diff*0.1
        let paddedMin = min - padding
        let paddedMax = max + padding
        return paddedMin...paddedMax
    }
}

/// Generate `DailyCalorieMap` data for preview
func randomizedDailyCalorieMap() -> DailyCalorieMap {
    let calendar = Calendar.autoupdatingCurrent
    let dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
    let dateFromDateComponents = calendar.date(from: dateComponents)!
    
    let restingByDay: [DateToCalories] = (0...7).reduce(into: []){partialResult,next in
        partialResult.append(
            DateToCalories(
                date: calendar.date(byAdding: .day, value: next-7, to: dateFromDateComponents)!,
                calories: 2000.0
            )
        )
    }
    let activeByDay: [DateToCalories] = (0...7).reduce(into: []){partialResult,next in
        partialResult.append(
            DateToCalories(
                date: calendar.date(byAdding: .day, value: next-7, to: dateFromDateComponents)!,
                calories: Double.random(in: 0.0...1000.0)
            )
        )
    }
    let dietaryByDay: [DateToCalories] = (0...7).reduce(into: []){partialResult,next in
        partialResult.append(
            DateToCalories(
                date: calendar.date(byAdding: .day, value: next-7, to: dateFromDateComponents)!,
                calories: Double.random(in: 0.0...3000.0)
            )
        )
    }
    
    return DailyCalorieMap(
        restingByDay: restingByDay,
        dietaryByDay: dietaryByDay,
        activeByDay: activeByDay
    )
}

struct TrendsLineChart: View {
    let trendsLineChartViewModel: TrendsLineChartViewModel
    
    var body: some View {
        Chart {
            ForEach(trendsLineChartViewModel.data, id: \.date){
                LineMark(x: .value("Day", $0.date), y: .value("Burned", $0.burned))
                    .foregroundStyle(by: .value("BURNED", "BURNED"))
                    .interpolationMethod(.catmullRom)
                    .symbol(.square)
                LineMark(x: .value("Day", $0.date), y: .value("Burned", $0.consumed))
                    .foregroundStyle(by: .value("DIET", "DIET"))
                    .interpolationMethod(.catmullRom)
                    .symbol(.circle)
            }
        }
        .chartForegroundStyleScale(["DIET": Color.orange, "BURNED": Color.blue])
        .chartPlotStyle{plotArea in
            plotArea.frame(maxWidth: .infinity, minHeight: 200.0, maxHeight: 200.0)
        }
        .chartXScale(range: .plotDimension(padding: 20.0))
        .chartXAxis{
            AxisMarks(preset: .aligned, position: .top, values: .stride(by: .day)){ value in
                AxisValueLabel(format: .dateTime.day().weekday(.narrow))
            }
        }
        .chartYAxis{
            AxisMarks(position: .leading)
        }
        .chartYScale(domain: trendsLineChartViewModel.chartRange)
    }
}

// Preview SwiftUI View
PlaygroundPage.current.setLiveView(
    TrendsLineChart(
        trendsLineChartViewModel: TrendsLineChartViewModel(
            dailyCalorieMap: randomizedDailyCalorieMap()
        )
    )
    .padding()
    .frame(width: 450)
)


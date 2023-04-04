import SwiftUI
import PlaygroundSupport
import Charts

import SwiftUI
import PlaygroundSupport
import Charts

struct Diet {
    let dateLabel: String = "Day"
    let date: Date
    let valueLabel: String = "Diet"
    let value: Double
}

struct Burned {
    let dateLabel: String = "Day"
    let date: Date
    let valueLabel: String = "Burned"
    let value: Double
}

let diet: [Diet] = [
    Diet(
        date: Calendar.current.date(
            from: .init(
                year: 2023,
                month: 1,
                day: 1
            )
        ) ?? Date(),
        value: 2000.0
    ),
    Diet(
        date: Calendar.current.date(
            from: .init(
                year: 2023,
                month: 1,
                day: 2
            )
        ) ?? Date(),
        value: 1800.0
    ),
    Diet(
        date: Calendar.current.date(
            from: .init(
                year: 2023,
                month: 1,
                day: 3
            )
        ) ?? Date(),
        value: 2300.0
    ),
    Diet(
        date: Calendar.current.date(
            from: .init(
                year: 2023,
                month: 1,
                day: 4
            )
        ) ?? Date(),
        value: 2100.0
    ),
    Diet(
        date: Calendar.current.date(
            from: .init(
                year: 2023,
                month: 1,
                day: 5
            )
        ) ?? Date(),
        value: 1500.0
    ),
]

struct SimpleLineChartView: View {
    var body: some View {
        VStack {
            Chart {
                ForEach(diet, id: \.date){ dataPoint in
                    LineMark(x: .value(dataPoint.dateLabel, dataPoint.date), y: .value(dataPoint.valueLabel, dataPoint.value))
                        .foregroundStyle(by: .value("BURNED", "BURNED"))
                        .interpolationMethod(.catmullRom)
                        .symbol(.square)
                    LineMark(x: .value(dataPoint.dateLabel, dataPoint.date), y: .value(dataPoint.valueLabel, (dataPoint.value - 300.0)))
                        .foregroundStyle(by: .value("DIET", "DIET"))
                        .interpolationMethod(.catmullRom)
                        .symbol(.circle)
                }
            }
            .chartForegroundStyleScale(["DIET": Color.orange, "BURNED": Color.blue])
            .chartXScale(range: .plotDimension(padding: 20.0))
            .chartXAxis{
                AxisMarks(preset: .aligned, position: .top, values: .stride(by: .day)){ value in
                    AxisValueLabel(format: .dateTime.day().weekday(.narrow))
                }
            }
            .chartPlotStyle{plotArea in
                plotArea.frame(maxWidth: .infinity, minHeight: 250.0, maxHeight: 250.0)
            }
            .chartYAxis{
                AxisMarks(position: .leading)
            }
        }
    }
}


/// Present the view controller in the Live View window
PlaygroundPage.current.setLiveView(
    SimpleLineChartView()
        .padding()
        .frame(width: 500, height: 350)
)

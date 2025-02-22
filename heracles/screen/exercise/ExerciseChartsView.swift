//
//  ExerciseChartsView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 14/02/2025.
//

import SwiftUI
import Charts

struct ExerciseChartsCardView : View {
    var body: some View {
            NavigationLink {
                ExerciseChartView()
            } label: {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Volume")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color(uiColor: UIColor.systemBlue))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                            .fontWeight(.semibold)
                            .imageScale(.small)
                    }
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Last 7 Days")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                            HStack(alignment: .firstTextBaseline) {
                                Text("1400")
                                    .font(.system(.largeTitle, design: .rounded, weight: .medium))
                                Text("kg")
                                    .font(.headline.bold())
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(alignment: .bottom)
                        Spacer()
                        Chart {
                            ForEach(0..<6, id: \.self) { idx in
                                if (idx == 0) {
                                    BarMark(
                                        x: .value("Date", data[idx].date),
                                        y: .value("Volume", data[idx].value)
                                    )
                                    .foregroundStyle(Color.blue)
                                } else {
                                    BarMark(
                                        x: .value("Date", data[idx].date),
                                        y: .value("Volume", data[idx].value)
                                    )
                                    .foregroundStyle(Color.gray.opacity(0.3))
                                }
                            }
                        }
                        
                        .chartXAxis(.hidden)
                        .chartYAxis(.hidden)
                        .frame(width: 70, height: 50)
                        .padding(.trailing, 5)
                        
                    }
                }
                .padding()
                .background(Material.regular)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundColor(.primary)
            }
        
    }
}

struct ExerciseChartsView: View {
    var body: some View {
        ScrollView {
            ExerciseChartsCardView()
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        ExerciseChartsView()
    }
}

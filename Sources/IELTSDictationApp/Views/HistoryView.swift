import SwiftUI
import IELTSDictationCore

struct HistoryView: View {
    @ObservedObject var viewModel: DictationViewModel
    @State private var reports: [DailyReport] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("历史报告")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)

            if reports.isEmpty {
                Spacer()
                Text("暂无历史记录")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                List(reports.sorted(by: { $0.dateUTC8 > $1.dateUTC8 })) { report in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("第 \(report.lessonNumber) 课")
                                .font(.headline)
                            Spacer()
                            Text(report.dateUTC8)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("正确率：\(Int(report.accuracy * 100))%")
                                .font(.subheadline)
                            Text("（\(report.correctCount)/\(report.totalCount)）")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            if !report.wrongItems.isEmpty {
                                Text("错词 \(report.wrongItems.count)")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }

                        if !report.wrongItems.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(report.wrongItems) { item in
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.word.zh)
                                                .font(.caption2)
                                            Text("→ \(item.word.en)")
                                                .font(.caption2.bold())
                                                .foregroundColor(.orange)
                                        }
                                        .padding(6)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(4)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(.vertical)
        .onAppear {
            reports = viewModel.loadHistory()
        }
    }
}

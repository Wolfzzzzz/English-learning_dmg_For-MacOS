import SwiftUI
import IELTSDictationCore

struct GradingReportView: View {
    @ObservedObject var viewModel: DictationViewModel
    @State private var showGradeAlert = false

    var body: some View {
        VStack(spacing: 8) {
            // Submit / Grade button
            if viewModel.report == nil && !viewModel.hasCompletedToday {
                Button(action: { showGradeAlert = true }) {
                    Text("校  对")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.session == nil)
                .alert("确认提交批改", isPresented: $showGradeAlert) {
                    Button("取消", role: .cancel) { }
                    Button("确认提交") { viewModel.grade() }
                } message: {
                    Text("提交后将无法修改答案。")
                }
            }

            // Report (shown after grading)
            if let report = viewModel.report {
                reportContent(report)
            }
        }
    }

    @ViewBuilder
    private func reportContent(_ report: GradingReport) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Accuracy summary
            HStack {
                Text("正确率：\(Int(report.accuracy * 100))%（\(report.correctCount) / \(report.totalCount)）")
                    .font(.headline)
                Spacer()
                if !report.wrongItems.isEmpty {
                    Text("错误 \(report.wrongItems.count) 个")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }
            .padding(.vertical, 4)

            if !report.wrongItems.isEmpty {
                Divider()

                Text("错误单词：")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                // Wrong items list
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 6) {
                        ForEach(report.wrongItems) { item in
                            HStack(alignment: .top, spacing: 8) {
                                Text("\(item.index + 1).")
                                    .font(.caption.monospacedDigit())
                                    .foregroundColor(.secondary)
                                    .frame(width: 24, alignment: .trailing)

                                Text("\(item.word.pos.map { "\($0) " } ?? "")\(item.word.zh)")
                                    .font(.caption)
                                    .frame(width: 160, alignment: .leading)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("你填：\(item.userAnswer.isEmpty ? "（空）" : item.userAnswer)")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                    Text("正确：\(item.word.en)")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                .frame(maxHeight: 150)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.windowBackgroundColor).opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

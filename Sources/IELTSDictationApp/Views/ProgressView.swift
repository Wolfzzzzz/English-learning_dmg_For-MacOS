import SwiftUI
import IELTSDictationCore

struct ProgressView: View {
    @ObservedObject var viewModel: DictationViewModel
    @State private var showResetAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("学习进度")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)

            let stats = viewModel.progressStats

            VStack(spacing: 16) {
                statCard(
                    title: "已学课程",
                    value: "\(stats.totalLessons) 课",
                    icon: "book.fill",
                    color: .blue
                )

                statCard(
                    title: "连续练习",
                    value: "\(stats.streakDays) 天",
                    icon: "flame.fill",
                    color: .orange
                )

                statCard(
                    title: "累计正确率",
                    value: stats.totalWords > 0
                        ? "\(Int(Double(stats.totalCorrect) / Double(stats.totalWords) * 100))%"
                        : "-",
                    icon: "chart.pie.fill",
                    color: .green
                )

                statCard(
                    title: "练习总词数",
                    value: "\(stats.totalWords) 词",
                    icon: "text.word.spacing",
                    color: .purple
                )
            }
            .padding(.horizontal)

            // Accuracy bar
            if stats.totalWords > 0 {
                let accuracy = Double(stats.totalCorrect) / Double(stats.totalWords)
                VStack(alignment: .leading, spacing: 4) {
                    Text("总体正确率")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 20)
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [.red, .orange, .green],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(accuracy), height: 20)
                        }
                    }
                    .frame(height: 20)
                    Text("\(Int(accuracy * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal)
            }

            Spacer()

            // Factory reset
            Divider()
                .padding(.horizontal)

            Button(role: .destructive) {
                showResetAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                        .font(.title3)
                    Text("恢复出厂设置")
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
            .alert("确认恢复出厂设置", isPresented: $showResetAlert) {
                Button("取消", role: .cancel) { }
                Button("确认恢复", role: .destructive) {
                    viewModel.resetAllData()
                }
            } message: {
                Text("所有练习记录、历史报告和错词本将被永久清除，此操作不可撤销。")
            }
        }
        .padding(.vertical)
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.windowBackgroundColor).opacity(0.5))
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        )
    }
}

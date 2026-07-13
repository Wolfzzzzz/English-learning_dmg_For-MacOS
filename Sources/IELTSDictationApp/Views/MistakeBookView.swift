import SwiftUI
import IELTSDictationCore

struct MistakeBookView: View {
    @ObservedObject var viewModel: DictationViewModel
    @State private var mistakes: [WrongItem] = []
    @State private var reviewMode = false
    @State private var reviewAnswers: [Int: String] = [:]
    @State private var reviewReport: GradingReport?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(reviewMode ? "错词复习" : "错词本")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                if !mistakes.isEmpty && !reviewMode {
                    Button("开始复习") {
                        startReview()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
            .padding(.horizontal)

            if mistakes.isEmpty {
                Spacer()
                Text("暂无错词记录")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else if reviewMode {
                reviewContent
            } else {
                listContent
            }
        }
        .padding(.vertical)
        .onAppear {
            mistakes = viewModel.loadMistakes()
        }
    }

    private var listContent: some View {
        List(Array(mistakes.enumerated()), id: \.offset) { _, item in
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.word.zh)
                        .font(.body)
                        .foregroundColor(.secondary)
                    Text(item.word.en)
                        .font(.body.bold())
                }
                Spacer()
                Text("你曾填：\(item.userAnswer.isEmpty ? "（空）" : item.userAnswer)")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            .padding(.vertical, 4)
        }
    }

    private var reviewContent: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(mistakes.enumerated()), id: \.offset) { index, item in
                    HStack(spacing: 12) {
                        Text("\(index + 1).")
                            .font(.body.monospacedDigit())
                            .foregroundColor(.secondary)
                            .frame(width: 30, alignment: .trailing)

                        Text("\(item.word.pos.map { "\($0) " } ?? "")\(item.word.zh)")
                            .frame(width: 200, alignment: .leading)

                        TextField("填写英文", text: Binding(
                            get: { reviewAnswers[index] ?? "" },
                            set: { reviewAnswers[index] = $0 }
                        ))
                        .textFieldStyle(.plain)
                        .disabled(reviewReport != nil)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )

                        if let report = reviewReport {
                            let wrongItem = report.wrongItems.first(where: { $0.word.en == item.word.en })
                            if wrongItem != nil {
                                Text(item.word.en)
                                    .font(.body.bold())
                                    .foregroundColor(.orange)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                if reviewReport == nil {
                    Button("提交复习") {
                        gradeReview()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }

                if let report = reviewReport {
                    Text("复习正确率：\(Int(report.accuracy * 100))%（\(report.correctCount)/\(report.totalCount)）")
                        .font(.headline)
                        .padding()

                    Button("返回错词本") {
                        reviewMode = false
                        reviewReport = nil
                        reviewAnswers = [:]
                    }
                    .buttonStyle(.bordered)
                    .padding()
                }
            }
            .padding(.vertical)
        }
    }

    private func startReview() {
        reviewMode = true
        reviewAnswers = [:]
        reviewReport = nil
    }

    private func gradeReview() {
        // Create fake session for grading review
        let words = mistakes.map { $0.word }
        let lesson = Lesson(number: 0, dateUTC8: "复习", listIds: [], questions: words)
        let session = DictationSession(lesson: lesson)
        for (index, answer) in reviewAnswers {
            session.submit(answer, at: index)
        }
        reviewReport = Grading.grade(session: session)
    }
}

import SwiftUI
import IELTSDictationCore

struct DictationQuestionView: View {
    let index: Int
    let word: Word
    @Binding var userAnswer: String
    let isSubmitted: Bool
    @Binding var isFocused: Bool

    @FocusState private var textFieldFocused: Bool

    private var isCorrect: Bool {
        guard isSubmitted else { return false }
        return Grading.isCorrect(user: userAnswer, word: word)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Index
            Text("\(index + 1).")
                .font(.body.monospacedDigit())
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)

            // Word info
            VStack(alignment: .leading, spacing: 2) {
                if let pos = word.pos {
                    Text("\(pos) \(word.zh)")
                        .font(.body)
                } else {
                    Text(word.zh)
                        .font(.body)
                }
            }
            .frame(width: 200, alignment: .leading)

            // Input field
            TextField("填写英文", text: $userAnswer)
                .textFieldStyle(.plain)
                .focused($textFieldFocused)
                .onChange(of: textFieldFocused) { newValue in
                    isFocused = newValue
                }
                .onChange(of: isFocused) { newValue in
                    if newValue { textFieldFocused = true }
                }
                .disabled(isSubmitted)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    inputBackground
                )
                .overlay(alignment: .trailing) {
                    if isSubmitted {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isCorrect ? .green : .red)
                            .padding(.trailing, 8)
                    }
                }

            // Correct answer (shown after submission)
            if isSubmitted && !isCorrect {
                Text(word.en)
                    .font(.body.bold())
                    .foregroundColor(.orange)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSubmitted && !isCorrect
                      ? Color.red.opacity(0.05)
                      : Color.clear)
        )
    }

    @ViewBuilder
    private var inputBackground: some View {
        if isSubmitted {
            RoundedRectangle(cornerRadius: 6)
                .stroke(isCorrect ? Color.green.opacity(0.5) : Color.red.opacity(0.5), lineWidth: 1)
        } else {
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        }
    }
}

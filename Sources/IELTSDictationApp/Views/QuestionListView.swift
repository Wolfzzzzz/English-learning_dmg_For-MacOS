import SwiftUI
import IELTSDictationCore

struct QuestionListView: View {
    @ObservedObject var viewModel: DictationViewModel
    @FocusState private var focusedIndex: Int?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if let questions = viewModel.lesson?.questions {
                        ForEach(Array(questions.enumerated()), id: \.offset) { index, word in
                            DictationQuestionView(
                                index: index,
                                word: word,
                                userAnswer: Binding(
                                    get: { viewModel.session?.answer(at: index) ?? "" },
                                    set: { viewModel.submitAnswer($0, at: index) }
                                ),
                                isSubmitted: viewModel.report != nil,
                                isFocused: Binding(
                                    get: { focusedIndex == index },
                                    set: { if $0 { focusedIndex = index } }
                                )
                            )
                            .id(index)
                            .onSubmit {
                                let next = index + 1
                                if next < questions.count {
                                    focusedIndex = next
                                    withAnimation {
                                        proxy.scrollTo(next, anchor: .center)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
        }
        .onAppear {
            focusedIndex = 0
        }
    }
}

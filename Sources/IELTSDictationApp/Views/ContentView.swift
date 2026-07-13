import SwiftUI
import IELTSDictationCore

struct ContentView: View {
    @ObservedObject var viewModel: DictationViewModel
    @State private var selectedTab: Tab = .dictation

    enum Tab: String, CaseIterable {
        case dictation = "默写"
        case history = "历史"
        case mistakes = "错词本"
        case progress = "进度"

        var icon: String {
            switch self {
            case .dictation: return "pencil.and.outline"
            case .history: return "clock.arrow.circlepath"
            case .mistakes: return "exclamationmark.triangle"
            case .progress: return "chart.bar"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            dictationTab
                .tabItem {
                    Label(Tab.dictation.rawValue, systemImage: Tab.dictation.icon)
                }
                .tag(Tab.dictation)

            HistoryView(viewModel: viewModel)
                .tabItem {
                    Label(Tab.history.rawValue, systemImage: Tab.history.icon)
                }
                .tag(Tab.history)

            MistakeBookView(viewModel: viewModel)
                .tabItem {
                    Label(Tab.mistakes.rawValue, systemImage: Tab.mistakes.icon)
                }
                .tag(Tab.mistakes)

            ProgressView(viewModel: viewModel)
                .tabItem {
                    Label(Tab.progress.rawValue, systemImage: Tab.progress.icon)
                }
                .tag(Tab.progress)
        }
        .frame(minWidth: 580, minHeight: 550)
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var dictationTab: some View {
        VStack(spacing: 0) {
            HeaderView(viewModel: viewModel)
                .padding(.horizontal)
                .padding(.top, 8)

            Divider()
                .padding(.vertical, 8)

            if viewModel.isLoading {
                Spacer()
                VStack(spacing: 8) {
                    SwiftUI.ProgressView()
                    Text("加载中…")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else if let error = viewModel.errorMessage {
                Spacer()
                Text(error)
                    .font(.title3)
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                QuestionListView(viewModel: viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider()
                    .padding(.vertical, 8)

                GradingReportView(viewModel: viewModel)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
        }
    }
}

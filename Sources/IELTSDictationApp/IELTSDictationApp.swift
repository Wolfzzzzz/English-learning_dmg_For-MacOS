import SwiftUI
import IELTSDictationCore

@main
struct IELTSDictationApp: App {
    @State private var viewModel: DictationViewModel?

    var body: some Scene {
        WindowGroup {
            if let viewModel = viewModel {
                ContentView(viewModel: viewModel)
            } else {
                VStack(spacing: 16) {
                    SwiftUI.ProgressView()
                    Text("正在准备今日课程…")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(width: 400, height: 300)
                .preferredColorScheme(.dark)
                .onAppear {
                    Task { await initializeViewModel() }
                }
            }
        }
        .windowResizability(.contentSize)
    }

    private func initializeViewModel() async {
        do {
            let vocabulary = try Vocabulary.load(from: .coreModule)
            let juniorHigh = try JuniorHighWordSet.load(from: .coreModule)
            let store = FileReportStore()

            let schedule = CourseSchedule(
                anchorDate: DictationConstants.effectiveAnchorDate,
                startListId: DictationConstants.startListId,
                overflow: DictationConstants.overflowPolicy
            )

            let selector = WordSelector(dailyTarget: DictationConstants.dailyTarget)

            let overrideKeep: Set<String> = {
                guard let url = Bundle.module.url(forResource: "override_keep", withExtension: "json") else {
                    return []
                }
                guard let data = try? Data(contentsOf: url) else { return [] }
                guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return [] }
                guard let words = json["words"] as? [String] else { return [] }
                return Set(words.map { $0.lowercased().trimmingCharacters(in: .whitespaces) })
            }()

            let vm = DictationViewModel(
                vocabulary: vocabulary,
                juniorHigh: juniorHigh,
                overrideKeep: overrideKeep,
                selector: selector,
                schedule: schedule,
                store: store,
                dateProvider: SystemDateProvider()
            )

            try vm.prepareTodayLesson()
            viewModel = vm
        } catch {
            print("Failed to initialize: \(error)")
        }
    }
}

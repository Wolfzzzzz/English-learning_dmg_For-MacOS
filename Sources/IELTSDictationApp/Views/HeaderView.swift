import SwiftUI
import IELTSDictationCore

struct HeaderView: View {
    @ObservedObject var viewModel: DictationViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.lessonDisplayTitle)
                    .font(.headline)
                Text("日期：\(viewModel.dateDisplay) (UTC+8)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(viewModel.wordCountText)
                    .font(.subheadline)
                HStack(spacing: 4) {
                    Circle()
                        .fill(viewModel.statusText == "已完成 ✓" ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                    Text(viewModel.statusText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

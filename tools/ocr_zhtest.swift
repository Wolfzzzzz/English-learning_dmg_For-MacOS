import Foundation
import PDFKit
import Vision
import AppKit

let pdfPath = "/Users/zzn/Desktop/雅思词汇绿宝书(1).pdf"
let outPath = "/Users/zzn/WorkBuddy/2026-07-13-22-35-34/ielts-dictation/tools/ocr_zh_sample.txt"
let url = URL(fileURLWithPath: pdfPath)
guard let doc = PDFDocument(url: url) else { fatalError("open failed") }
let outURL = URL(fileURLWithPath: outPath)

let end = min(14, doc.pageCount)
var sections: [String] = []
for i in 0..<end {
    autoreleasepool {
        guard let page = doc.page(at: i) else { return }
        let b = page.bounds(for: .mediaBox)
        let s: CGFloat = 2.0
        let img = page.thumbnail(of: NSSize(width: b.width * s, height: b.height * s), for: .mediaBox)
        guard let cg = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
        let req = VNRecognizeTextRequest()
        req.recognitionLanguages = ["zh-Hans", "en"]
        req.usesLanguageCorrection = true
        req.recognitionLevel = .accurate
        let h = VNImageRequestHandler(cgImage: cg, options: [:])
        try? h.perform([req])
        let t = (req.results ?? []).compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
        sections.append("===== PAGE \(i+1) =====\n" + t)
    }
}
let text = sections.joined(separator: "\n")
try? text.write(to: outURL, atomically: true, encoding: .utf8)
let han = text.filter { ("\u{4e00}"..."\u{9fff}").contains($0) }.count
print("pages=\(end) chars=\(text.count) chinese=\(han)")

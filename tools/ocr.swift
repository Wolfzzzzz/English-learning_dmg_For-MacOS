import Foundation
import PDFKit
import Vision
import AppKit

let pdfPath = "/Users/zzn/Desktop/雅思词汇绿宝书(1).pdf"
let outPath = "/Users/zzn/WorkBuddy/2026-07-13-22-35-34/ielts-dictation/tools/ocr_output.txt"

let url = URL(fileURLWithPath: pdfPath)
guard let doc = PDFDocument(url: url) else { fatalError("无法打开 PDF: \(pdfPath)") }
let outURL = URL(fileURLWithPath: outPath)

var sections: [String] = []
let total = doc.pageCount
print("开始 OCR，共 \(total) 页…", terminator: " ")

for i in 0..<total {
    autoreleasepool {
        guard let page = doc.page(at: i) else { return }
        let bounds = page.bounds(for: .mediaBox)
        let scale: CGFloat = 2.0
        let thumbSize = NSSize(width: bounds.width * scale, height: bounds.height * scale)
        let image = page.thumbnail(of: thumbSize, for: .mediaBox)
        guard let cg = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }

        let request = VNRecognizeTextRequest()
        request.recognitionLanguages = ["zh-Hans", "en"]
        request.usesLanguageCorrection = true
        request.recognitionLevel = .accurate

        let handler = VNImageRequestHandler(cgImage: cg, options: [:])
        do { try handler.perform([request]) } catch {
            fputs("page \(i+1) OCR error: \(error)\n", stderr)
            return
        }
        let obs = request.results ?? []
        let pageText = obs.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
        sections.append("===== PAGE \(i+1) =====")
        sections.append(pageText)
    }
    if (i + 1) % 50 == 0 { print("\(i+1)/\(total)", terminator: " ") }
}

let text = sections.joined(separator: "\n")
try? text.write(to: outURL, atomically: true, encoding: .utf8)
print("\nOCR 完成：pages=\(total) chars=\(text.count) -> \(outPath)")

//
//  TransactionDetailView.swift
//  DiamaPay
//
//  Created by Bits on 13/11/2025.
//

import SwiftUI
import UIKit

struct TransactionDetailView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.dismiss) private var dismiss
    let transaction: Transaction
    @State private var receiptToShare: ShareItem?
    @State private var showReceiptError = false

    var body: some View {
        ZStack {
            Color(hex: "F4F7FC")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                DiamaPayHeader(title: AppStrings.transactionDetails, headerColor: Color(hex: "174EA6"))
                ScrollView {
                    VStack(spacing: 18) {
                        transactionInfoCard
                        
                        Button(action: {
                            generatePDF()
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "square.and.arrow.up")
                                Text(AppStrings.buttonTitle(AppStrings.shareReceipt))
                            }
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "174EA6"), Color(hex: "0788B9")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color(hex: "174EA6").opacity(0.22), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .sheet(item: $receiptToShare) { shareItem in
            ActivityViewController(activityItems: shareItem.items)
        }
        .alert(AppStrings.error, isPresented: $showReceiptError) {
            Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) { }
        } message: {
            Text(AppStrings.receiptGenerationFailed)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(onSponsors: {}, onQR: {}, onLimits: {}, onSettings: {})
        }
        .navigationBarHidden(true)
    }
    
    private var transactionInfoCard: some View {
        VStack(spacing: 14) {
            summaryCard

            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.transactionInformation2)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.1)
                    .foregroundColor(Color(hex: "174EA6"))
                    .padding(.bottom, 6)

                detailRow(label: AppStrings.reference, value: transaction.transactionReference ?? AppStrings.nA)
                detailRow(label: AppStrings.type, value: transaction.displayTitle)
                detailRow(label: AppStrings.details, value: transaction.details ?? AppStrings.noAdditionalDetails)
                detailRow(label: AppStrings.openingBalance, value: transaction.openingBalance ?? AppStrings.nA)
                detailRow(label: AppStrings.closingBalance, value: transaction.closingBalance ?? AppStrings.nA)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "DCE7F7"), lineWidth: 1))
            .shadow(color: Color(hex: "174EA6").opacity(0.06), radius: 12, x: 0, y: 5)
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
    }

    private var summaryCard: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(
                colors: [Color(hex: "123B7A"), Color(hex: "1768B2"), Color(hex: "0788B9")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 180, height: 180)
                .offset(x: 58, y: -90)

            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 110, height: 110)
                .offset(x: -110, y: 115)

            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 12) {
                    Image(systemName: transaction.isDebit ? "arrow.up.right" : "arrow.down.left")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.16))
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(transaction.displayTitle)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Text(transaction.displayDate)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.76))
                    }

                    Spacer(minLength: 0)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(transaction.isDebit ? AppStrings.moneySent : AppStrings.moneyReceived)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.78))
                    Text(transaction.amount)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.75)
                        .lineLimit(1)
                }

                HStack {
                    Label(transaction.status ?? AppStrings.unknown, systemImage: statusIcon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 7)
                        .background(Color.white.opacity(0.16))
                        .clipShape(Capsule())

                    Spacer()

                    Text(AppStrings.refValue(String(describing: transaction.transactionReference ?? AppStrings.nA)))
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.82))
                        .lineLimit(1)
                }
            }
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.25), lineWidth: 1))
        .shadow(color: Color(hex: "174EA6").opacity(0.24), radius: 16, x: 0, y: 8)
    }

    private var statusIcon: String {
        let status = (transaction.status ?? "").lowercased()
        if status.contains("approv") || status.contains("success") || status == "ok" || status == "000" || status == "completed" {
            return "checkmark.circle.fill"
        }
        if status.contains("pending") || status.contains("processing") {
            return "clock.fill"
        }
        if status.contains("fail") || status.contains("reject") || status.contains("declin") || status.contains("error") {
            return "xmark.circle.fill"
        }
        return "info.circle.fill"
    }
    
    private func detailRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "496589"))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "172B4D"))
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, 11)
    }

    private func generatePDF() {
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = [
            kCGPDFContextCreator as String: AppStrings.brand,
            kCGPDFContextAuthor as String: "GambiaPay",
            kCGPDFContextTitle as String: AppStrings.transactionReceipt
        ]
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let contentRect = CGRect(x: 40, y: 126, width: 532, height: 606)
        let fields = [
            (AppStrings.reference, transaction.transactionReference ?? AppStrings.nA),
            (AppStrings.date, transaction.displayDate),
            (AppStrings.type, transaction.displayTitle),
            (AppStrings.amount, transaction.amount),
            (AppStrings.status, transaction.status ?? AppStrings.unknown),
            (AppStrings.details, transaction.details ?? AppStrings.noAdditionalDetails),
            (AppStrings.openingBalance, transaction.openingBalance ?? AppStrings.nA),
            (AppStrings.closingBalance, transaction.closingBalance ?? AppStrings.nA)
        ]
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.paragraphSpacing = 14
        let body = NSMutableAttributedString(string: "")
        for (label, value) in fields {
            body.append(NSAttributedString(string: label + "\n", attributes: [
                .font: UIFont.boldSystemFont(ofSize: 12),
                .foregroundColor: UIColor.darkGray,
                .paragraphStyle: paragraph
            ]))
            body.append(NSAttributedString(string: value + "\n", attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraph
            ]))
        }
        // Text containers paginate the entire receipt, including unusually long details.
        let storage = NSTextStorage(attributedString: body)
        let layout = NSLayoutManager()
        storage.addLayoutManager(layout)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { context in
            var renderedGlyphs = 0
            var page = 0
            repeat {
                let container = NSTextContainer(size: contentRect.size)
                container.lineFragmentPadding = 0
                layout.addTextContainer(container)
                let range = layout.glyphRange(for: container)
                guard range.length > 0 else { break }
                context.beginPage()
                page += 1
                UIColor.white.setFill()
                context.cgContext.fill(pageRect)
                UIImage(named: "BITSLogo")?.draw(in: CGRect(x: 40, y: 26, width: 110, height: 66))
                (AppStrings.brand as NSString).draw(at: CGPoint(x: 170, y: 35), withAttributes: [
                    .font: UIFont.boldSystemFont(ofSize: 22),
                    .foregroundColor: UIColor(red: 0.09, green: 0.31, blue: 0.65, alpha: 1)
                ])
                (AppStrings.transactionReceipt as NSString).draw(at: CGPoint(x: 170, y: 66), withAttributes: [
                    .font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.darkGray
                ])
                layout.drawBackground(forGlyphRange: range, at: contentRect.origin)
                layout.drawGlyphs(forGlyphRange: range, at: contentRect.origin)
                ("GambiaPay · \(page)" as NSString).draw(at: CGPoint(x: 40, y: 755), withAttributes: [
                    .font: UIFont.systemFont(ofSize: 10), .foregroundColor: UIColor.gray
                ])
                renderedGlyphs = NSMaxRange(range)
            } while renderedGlyphs < layout.numberOfGlyphs
        }
        do {
            // Keep untrusted transaction references out of filesystem paths.
            let directory = FileManager.default.temporaryDirectory
                .appendingPathComponent("Receipts", isDirectory: true)
                .appendingPathComponent(UUID().uuidString, isDirectory: true)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let url = directory.appendingPathComponent("GambiaPay-receipt.pdf")
            try data.write(to: url, options: .atomic)
            receiptToShare = ShareItem(items: [url])
        } catch {
            showReceiptError = true
        }
    }

}

// Helper struct to make the items identifiable
struct ShareItem: Identifiable {
    let id = UUID()
    let items: [Any]
}

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

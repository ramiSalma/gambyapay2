//
//  VoucherSuccessView.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//


//
//  VoucherSuccessView.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//

import SwiftUI
import PDFKit

struct VoucherSuccessView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let transactionId: String
    let transactionDate: String
    let amount: String
    let recipientName: String
    let recipientPhone: String
    let senderName: String
    let senderPhone: String
    let fee: Double
    let withdrawalFee: Double
    let total: Double
    let currency: String
    let paymentDetails: String
    let voucherCode: String
    let onClose: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.58).ignoresSafeArea()

                VStack(spacing: 0) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 70, height: 70)
                        .background(Color(hex: "4CAF50"), in: Circle())
                        .padding(.top, 22)

                    Text(AppStrings.moneyVoucherSentSuccessfully)
                        .font(.system(size: 21, weight: .bold))
                        .foregroundColor(Color(hex: "4CAF50"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 18)
                        .padding(.top, 14)
                        .padding(.bottom, 12)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(AppStrings.idValue(String(describing: transactionId)))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color(hex: "263238"))
                            receiptLine(AppStrings.date, transactionDate)
                            Text(AppStrings.amountValue(String(describing: formatAmount(Double(amount.replacingOccurrences(of: ",", with: ".")) ?? 0))))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(hex: "174EA6"))
                            if withdrawalFee > 0 { receiptLine(AppStrings.availabilityFee, formatAmount(withdrawalFee)) }
                            receiptLine(AppStrings.voucherFee, fee > 0 ? formatAmount(fee) : AppStrings.free)
                            receiptLine(AppStrings.totalDebited2, formatAmount(total))

                            Divider().padding(.vertical, 2)
                            sectionTitle(AppStrings.senderHeading)
                            receiptLine(AppStrings.sender, senderName)
                            receiptLine(AppStrings.phone, senderPhone)

                            Divider().padding(.vertical, 2)
                            sectionTitle(AppStrings.recipientHeading)
                            receiptLine(AppStrings.recipient, recipientName.isEmpty ? AppStrings.notVerified : recipientName)
                            receiptLine(AppStrings.phone, recipientPhone)
                            receiptLine(AppStrings.details, paymentDetails.isEmpty ? AppStrings.moneyVoucher2 : paymentDetails)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: .black.opacity(0.12), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal, 18)

                    HStack(spacing: 12) {
                        Button(action: shareReceipt) {
                            Label(AppStrings.buttonTitle(AppStrings.share), systemImage: "square.and.arrow.up")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(Color(hex: "174EA6"), in: RoundedRectangle(cornerRadius: 11))
                        }
                        Button(action: onClose) {
                            Text(AppStrings.buttonTitle(AppStrings.closeHeading))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color(hex: "0788B9"))
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .overlay(RoundedRectangle(cornerRadius: 11).stroke(Color(hex: "174EA6"), lineWidth: 1.5))
                        }
                    }
                    .padding(16)
                }
                .frame(maxWidth: 460)
                .frame(maxHeight: min(geometry.size.height * 0.92, 760))
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.gray.opacity(0.12), lineWidth: 1))
                .padding(.horizontal, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(Color(hex: "0788B9"))
    }

    private func receiptLine(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 5) {
            Text("\(label):")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "69727E"))
            Text(value.isEmpty ? "—" : value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "263238"))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: localization.language.rawValue)
        return (formatter.string(from: NSNumber(value: amount)) ?? "0") + " " + currency
    }
    
    private func shareReceipt() {
        // Generate PDF
        let pdfData = generatePDF()
        
        // Save to temporary directory
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "Recu_Voucher_\(voucherCode).pdf"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try pdfData.write(to: fileURL)
            
            // Add delay and find topmost view controller
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let rootVC = windowScene.windows.first?.rootViewController else {
                    return
                }
                
                // Find the topmost presented view controller
                var topVC = rootVC
                while let presented = topVC.presentedViewController {
                    topVC = presented
                }
                
                let activityViewController = UIActivityViewController(
                    activityItems: [fileURL, generateReceiptText()],
                    applicationActivities: nil
                )
                
                // For iPad
                if let popover = activityViewController.popoverPresentationController {
                    popover.sourceView = topVC.view
                    popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                
                topVC.present(activityViewController, animated: true)
            }
        } catch {
            //print("Error saving PDF: \(error)")
        }
    }
    private func generatePDF() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "GambiaPay",
            kCGPDFContextAuthor: senderName,
            kCGPDFContextTitle: AppStrings.recuDeMiseADisposition
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4 size
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = 60
            let leftMargin: CGFloat = 50
            let rightMargin: CGFloat = 545
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            let title = AppStrings.recuDeMiseADisposition2
            title.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: titleAttributes)
            yPosition += 40
            
            // Draw line
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setLineWidth(2)
            context.cgContext.move(to: CGPoint(x: leftMargin, y: yPosition))
            context.cgContext.addLine(to: CGPoint(x: rightMargin, y: yPosition))
            context.cgContext.strokePath()
            yPosition += 30
            
            let contentAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]
            
            let boldAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]
            
            // Transaction details
            drawText(AppStrings.statutMiseADispositionGeneree, at: CGPoint(x: leftMargin, y: yPosition), attributes: contentAttributes, context: context)
            yPosition += 25
            
            drawText(AppStrings.codeVoucherValue(String(describing: voucherCode)), at: CGPoint(x: leftMargin, y: yPosition), attributes: boldAttributes, context: context)
            yPosition += 25
            
            drawText(AppStrings.idTransactionValue(String(describing: transactionId)), at: CGPoint(x: leftMargin, y: yPosition), attributes: contentAttributes, context: context)
            yPosition += 25
            
            drawText(AppStrings.dateValue(String(describing: transactionDate)), at: CGPoint(x: leftMargin, y: yPosition), attributes: contentAttributes, context: context)
            yPosition += 25
            
            drawText(AppStrings.montantValue(String(describing: formatAmount(Double(amount.replacingOccurrences(of: ",", with: ".")) ?? 0.0))), at: CGPoint(x: leftMargin, y: yPosition), attributes: contentAttributes, context: context)
            yPosition += 25
            
            drawText(AppStrings.fraisValue(String(describing: fee > 0 ? formatAmount(fee) : AppStrings.gratuit)), at: CGPoint(x: leftMargin, y: yPosition), attributes: contentAttributes, context: context)
            yPosition += 25
            
            drawText(AppStrings.totalDebiteValue(String(describing: formatAmount(total))), at: CGPoint(x: leftMargin, y: yPosition), attributes: boldAttributes, context: context)
            yPosition += 35
            
            // Separator
            context.cgContext.setLineWidth(1)
            context.cgContext.move(to: CGPoint(x: leftMargin, y: yPosition))
            context.cgContext.addLine(to: CGPoint(x: rightMargin, y: yPosition))
            context.cgContext.strokePath()
            yPosition += 25
            
            // Sender section
            drawText(AppStrings.emetteur, at: CGPoint(x: leftMargin, y: yPosition), attributes: boldAttributes, context: context)
            yPosition += 25
            
            drawText(AppStrings.nomValue(String(describing: senderName)), at: CGPoint(x: leftMargin, y: yPosition), attributes: contentAttributes, context: context)
            yPosition += 25
            
            drawText(AppStrings.telephoneValue(String(describing: senderPhone)), at: CGPoint(x: leftMargin, y: yPosition), attributes: contentAttributes, context: context)
            yPosition += 35
            
            // Recipient section
            drawText(AppStrings.destinataire, at: CGPoint(x: leftMargin, y: yPosition), attributes: boldAttributes, context: context)
            yPosition += 25
            
            let recipientNameText = recipientName.isEmpty ? AppStrings.nonVerifie : recipientName
            drawText(AppStrings.nomValue(String(describing: recipientNameText)), at: CGPoint(x: leftMargin, y: yPosition), attributes: contentAttributes, context: context)
            yPosition += 25
            
            drawText(AppStrings.telephoneValue(String(describing: recipientPhone)), at: CGPoint(x: leftMargin, y: yPosition), attributes: contentAttributes, context: context)
            yPosition += 35
            
            // Payment details
            if !paymentDetails.isEmpty {
                drawText(AppStrings.detailsValue2(String(describing: paymentDetails)), at: CGPoint(x: leftMargin, y: yPosition), attributes: contentAttributes, context: context)
                yPosition += 35
            }
            
            // Instructions
            drawText(AppStrings.instructions, at: CGPoint(x: leftMargin, y: yPosition), attributes: boldAttributes, context: context)
            yPosition += 25
            
            drawText(AppStrings.leDestinatairePeutRetirerCesFondsAvecLeCode, at: CGPoint(x: leftMargin, y: yPosition), attributes: contentAttributes, context: context)
            yPosition += 20
            
            drawText(AppStrings.voucherDansNImporteQuelPointDeService, at: CGPoint(x: leftMargin, y: yPosition), attributes: contentAttributes, context: context)
            yPosition += 40
            
            // Footer separator
            context.cgContext.move(to: CGPoint(x: leftMargin, y: yPosition))
            context.cgContext.addLine(to: CGPoint(x: rightMargin, y: yPosition))
            context.cgContext.strokePath()
            yPosition += 25
            
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.gray
            ]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy 'à' HH:mm"
            let footerText = AppStrings.ceRecuAEteGenereAutomatiquementLeValue(String(describing: dateFormatter.string(from: Date())))
            drawText(footerText, at: CGPoint(x: leftMargin, y: yPosition), attributes: footerAttributes, context: context)
        }
        
        return data
    }
    
    private func drawText(_ text: String, at point: CGPoint, attributes: [NSAttributedString.Key: Any], context: UIGraphicsPDFRendererContext) {
        text.draw(at: point, withAttributes: attributes)
    }
    
    private func generateReceiptText() -> String {
        return AppStrings.recuDeMiseADispositionStatutMiseADispositionGeneree(String(describing: voucherCode), String(describing: transactionId), String(describing: transactionDate), String(describing: formatAmount(Double(amount.replacingOccurrences(of: ",", with: ".")) ?? 0.0)), String(describing: fee > 0 ? formatAmount(fee) : AppStrings.gratuit), String(describing: formatAmount(total)), String(describing: senderName), String(describing: senderPhone), String(describing: recipientName.isEmpty ? AppStrings.nonVerifie : recipientName), String(describing: recipientPhone), String(describing: paymentDetails.isEmpty ? AppStrings.miseADispositionDeFonds : paymentDetails))
    }
}


//
//  AccountTransferSuccessView.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//

import SwiftUI
import PDFKit

struct AccountTransferSuccessView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let transactionId: String
    let transactionDate: String
    let amount: String
    let accountName: String
    let accountNumber: String
    let bankName: String
    let senderName: String
    let senderWallet: String
    let senderPhone: String
    let withdrawalFee: Double
    let fee: Double
    let total: Double
    let currency: String
    let paymentDetails: String
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

                    Text(AppStrings.transferToAccountSuccessful)
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

                            Divider().padding(.vertical, 2)
                            sectionTitle(AppStrings.senderHeading)
                            receiptLine(AppStrings.sender, senderName)
                            receiptLine(AppStrings.wallet, senderWallet)
                            if !senderPhone.isEmpty { receiptLine(AppStrings.phone, senderPhone) }

                            Divider().padding(.vertical, 2)
                            sectionTitle(AppStrings.recipientHeading)
                            receiptLine(AppStrings.account, accountName)
                            receiptLine(AppStrings.accountNo, accountNumber)
                            if !bankName.isEmpty { receiptLine(AppStrings.bank, bankName) }
                            receiptLine(AppStrings.details, paymentDetails.isEmpty ? AppStrings.transferToAccount : paymentDetails)
                            if withdrawalFee > 0 { receiptLine(AppStrings.withdrawalFee2, formatAmount(withdrawalFee)) }
                            if fee > 0 { receiptLine(AppStrings.fee, formatAmount(fee)) }
                            if total > 0 { receiptLine(AppStrings.totalDebited2, formatAmount(total)) }
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
        formatter.locale = Locale(identifier: "en_GM")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return (formatter.string(from: NSNumber(value: amount)) ?? "0") + " " + currency
    }
    
    private func shareReceipt() {
        // Generate PDF
        let pdfData = generatePDF()
        
        // Save to temporary directory
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "Recu_Transfert_Compte_\(transactionId).pdf"
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
            kCGPDFContextCreator: AppStrings.brand,
            kCGPDFContextAuthor: senderName,
            kCGPDFContextTitle: AppStrings.recuDeTransfertVersCompte
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
            let title = AppStrings.recuDeTransfertVersCompte2
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
            drawText(AppStrings.statutTransfertVersCompteReussi, at: CGPoint(x: leftMargin, y: yPosition), attributes: contentAttributes, context: context)
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
            drawText(AppStrings.expediteur, at: CGPoint(x: leftMargin, y: yPosition), attributes: boldAttributes, context: context)
            yPosition += 25
            
            drawText(AppStrings.nomValue(String(describing: senderName)), at: CGPoint(x: leftMargin, y: yPosition), attributes: contentAttributes, context: context)
            yPosition += 25
            
            drawText(AppStrings.portefeuilleValue(String(describing: senderWallet)), at: CGPoint(x: leftMargin, y: yPosition), attributes: contentAttributes, context: context)
            yPosition += 25
            
            drawText(AppStrings.telephoneValue(String(describing: senderPhone)), at: CGPoint(x: leftMargin, y: yPosition), attributes: contentAttributes, context: context)
            yPosition += 35
            
            // Recipient section
            drawText(AppStrings.compteDestinataire, at: CGPoint(x: leftMargin, y: yPosition), attributes: boldAttributes, context: context)
            yPosition += 25
            
            drawText(AppStrings.nomDuCompteValue(String(describing: accountName)), at: CGPoint(x: leftMargin, y: yPosition), attributes: contentAttributes, context: context)
            yPosition += 25
            
            drawText(AppStrings.numeroDeCompteValue(String(describing: accountNumber)), at: CGPoint(x: leftMargin, y: yPosition), attributes: contentAttributes, context: context)
            yPosition += 25
            
            drawText(AppStrings.banqueValue(String(describing: bankName)), at: CGPoint(x: leftMargin, y: yPosition), attributes: contentAttributes, context: context)
            yPosition += 35
            
            // Payment details
            if !paymentDetails.isEmpty {
                drawText(AppStrings.detailsValue2(String(describing: paymentDetails)), at: CGPoint(x: leftMargin, y: yPosition), attributes: contentAttributes, context: context)
                yPosition += 35
            }
            
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
            dateFormatter.locale = Locale(identifier: localization.language.rawValue)
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            let footerText = AppStrings.ceRecuAEteGenereAutomatiquementLeValue(String(describing: dateFormatter.string(from: Date())))
            drawText(footerText, at: CGPoint(x: leftMargin, y: yPosition), attributes: footerAttributes, context: context)
        }
        
        return data
    }
    
    private func drawText(_ text: String, at point: CGPoint, attributes: [NSAttributedString.Key: Any], context: UIGraphicsPDFRendererContext) {
        text.draw(at: point, withAttributes: attributes)
    }
    
    private func generateReceiptText() -> String {
        [
            AppStrings.recuDeTransfertVersCompte,
            AppStrings.statutTransfertVersCompteReussi,
            AppStrings.idTransactionValue(transactionId),
            AppStrings.dateValue(transactionDate),
            AppStrings.amountValue(formatAmount(Double(amount.replacingOccurrences(of: ",", with: ".")) ?? 0)),
            AppStrings.fraisValue(fee > 0 ? formatAmount(fee) : AppStrings.gratuit),
            AppStrings.totalDebiteValue(formatAmount(total)),
            AppStrings.senderHeading,
            AppStrings.nameValue(senderName),
            AppStrings.portefeuilleValue(senderWallet),
            AppStrings.phoneValue(senderPhone),
            AppStrings.recipientHeading,
            AppStrings.nomDuCompteValue(accountName),
            AppStrings.numeroDeCompteValue(accountNumber),
            AppStrings.banqueValue(bankName),
            AppStrings.detailsValue(paymentDetails.isEmpty ? AppStrings.transferToAccount : paymentDetails)
        ].joined(separator: "\n")
    }
}

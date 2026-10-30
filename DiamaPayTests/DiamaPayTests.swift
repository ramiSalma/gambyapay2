//
//  DiamaPayTests.swift
//  DiamaPayTests
//
//  Created by Bits on 16/9/2025.
//

import Testing
import SwiftUI
import UIKit
@testable import DIAMACASH

struct DiamaPayTests {

    @Test func pinInputFiltersPastedTextAndPreservesLeadingZeros() {
        var value = ""
        let input = Binding(get: { value }, set: { value = $0 }).walletPIN()
        input.wrappedValue = "0a1 2-3456"
        #expect(value == "0123")
        input.wrappedValue = "１２٣٤abc"
        #expect(value.isEmpty)
        input.wrappedValue = "12"
        #expect(value == "12")
        input.wrappedValue = ""
        #expect(value.isEmpty)
    }

    @Test func pinValidationRequiresExactlyFourASCIIDigits() {
        for valid in ["0000", "0123", "9876"] {
            #expect(valid.isValidWalletPIN)
        }
        for invalid in ["", "123", "12345", "12a4", "12 4", "12-4", "１２３４", "١٢٣٤", "1234\n"] {
            #expect(!invalid.isValidWalletPIN)
        }
    }

    @MainActor
    @Test func nativePinEditorNeverDisplaysMoreThanFourDigits() {
        var value = ""
        let input = WalletPINField("PIN", text: Binding(get: { value }, set: { value = $0 }))
        let coordinator = input.makeCoordinator()
        let field = UITextField()
        field.text = ""
        for digit in "0123456789" {
            let allowsNativeEdit = coordinator.textField(field, shouldChangeCharactersIn: NSRange(location: (field.text ?? "").utf16.count, length: 0), replacementString: String(digit))
            #expect(!allowsNativeEdit)
            #expect((field.text ?? "").count <= 4)
            #expect(field.text == value)
        }
        #expect(field.text == "0123")
        _ = coordinator.textField(field, shouldChangeCharactersIn: NSRange(location: 0, length: 4), replacementString: "9a8 765432")
        #expect(field.text == "9876")
        #expect(value == "9876")
        _ = coordinator.textField(field, shouldChangeCharactersIn: NSRange(location: 0, length: 4), replacementString: "")
        #expect(field.text == "")
        #expect(value.isEmpty)
    }

    @MainActor
    @Test func nativeOtpEditorLimitsTypingPasteAndAutofill() {
        var value = ""
        let input = WalletCodeField("OTP", text: Binding(get: { value }, set: { value = $0 }), isSecure: false, maxLength: 6)
        let coordinator = input.makeCoordinator()
        let field = UITextField()
        field.text = ""
        for digit in "00123456789" {
            _ = coordinator.textField(field, shouldChangeCharactersIn: NSRange(location: (field.text ?? "").utf16.count, length: 0), replacementString: String(digit))
            #expect((field.text ?? "").count <= 6)
            #expect(field.text == value)
        }
        #expect(value == "001234")
        _ = coordinator.textField(field, shouldChangeCharactersIn: NSRange(location: 0, length: 6), replacementString: "09 87-654321")
        #expect(field.text == "098765")
        #expect(value.isValidOTP)
        field.text = "123456789"
        coordinator.editingChanged(field)
        #expect(field.text == "123456")
        #expect(value == "123456")
        #expect(!"12345".isValidOTP)
        #expect(!"12345a".isValidOTP)
    }

    @Test func otpInputFiltersAutofillAndLimitsToSixDigits() {
        var value = ""
        let input = Binding(get: { value }, set: { value = $0 }).digitsOnly(maxLength: 6)
        input.wrappedValue = "00 12-34a567"
        #expect(value == "001234")
        input.wrappedValue = "12345"
        #expect(value == "12345")
        input.wrappedValue = "abcdef"
        #expect(value.isEmpty)
    }

}

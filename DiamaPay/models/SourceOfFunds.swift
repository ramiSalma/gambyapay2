//
//  SourceOfFunds.swift
//  DiamaPay
//
//  Created by Bits on 27/9/2025.
//


import SwiftUI
import Foundation

// MARK: - Enums
enum SourceOfFunds: CaseIterable {
    case wallet
    case sponsor
    
    var title: String {
        switch self {
        case .wallet:
            return AppStrings.monPortefeuille
        case .sponsor:
            return AppStrings.sponsor
        }
    }
}

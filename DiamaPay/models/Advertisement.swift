//
//  Advertisement.swift
//  DiamaPay
//
//  Created by Bits on 18/9/2025.
//
import SwiftUI


struct Advertisement: Codable, Identifiable {
    let id: String
    let title: String?
    let description: String?
    let imageBase64: String?   // ✅ matches backend JSON
    var viewed: Bool?

    enum CodingKeys: String, CodingKey {
        case id, title, description, viewed
        case imageBase64 = "imageBase64"
    }
}

extension Advertisement {
    func decodedImage() -> Image? {
        guard let base64 = imageBase64,
              let data = Data(base64Encoded: base64),
              let uiImage = UIImage(data: data) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
}


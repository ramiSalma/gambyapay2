import Foundation

/// Payload for the authenticated manual document re-upload endpoint.
struct CustomerDocumentUploadRequest: Codable {
    let customerId: String
    let faceImage: String
    let documentFront: String
    let documentBack: String
}

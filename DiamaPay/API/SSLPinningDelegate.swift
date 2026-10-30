//
//  SSLPinningDelegate.swift
//  DiamaPay
//
//  Created by bits dev team on 12/12/2025.
//


import Foundation
import CommonCrypto

class SSLPinningDelegate: NSObject, URLSessionDelegate {
    
    private let certificateHashes = [
        "9e0b840c2bc5f85d128dd3dddc67c1e47be999b43315227ded38a9563da3188b7a"
    ]
    
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        
        // Only handle server trust challenges
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // Get server certificate
        guard let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // Get certificate data and calculate hash
        let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data
        let serverHashString = sha256(data: serverCertificateData)
        
  
        
        // Check if hash matches our pinned certificate
        if certificateHashes.contains(serverHashString) {
            #if DEBUG
            //print("✅ SSL Pinning: Certificate validated successfully")
            #endif
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
                        completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
    
    // Calculate SHA-256 hash
    private func sha256(data: Data) -> String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

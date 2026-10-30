//
//  ComplaintRequest.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//


struct ComplaintRequest: Codable {
    var userPhone: String           // User's phone number
    var userName: String             // User's name
    var complaintType: String        // Type: "Transaction échouée", "Débit non autorisé", etc.
    var priority: String             // Priority: "URGENT", "ÉLEVÉ", "MOYEN", "FAIBLE"
    var title: String                // Short title of the complaint
    var description: String          // Detailed description (up to 1000 chars)
    var incidentDate: String         // When the incident occurred
    var transactionRef: String?      // Optional transaction reference
    var contactMethod: String        // How to contact: SMS, Email, or "Don't contact"
    var alternateContact: String?    // Optional alternate email
}
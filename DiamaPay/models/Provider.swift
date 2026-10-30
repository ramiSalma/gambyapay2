//
//  Provider.swift
//  DiamaPay
//
//  Created by Bits on 17/9/2025.
//


struct Provider: Codable, Hashable {
    let id: String?
    let name: String?
    let code: String?
    let type: String?

    var displayName: String { name ?? code ?? AppStrings.provider }

    enum CodingKeys: String, CodingKey { case id, name, code, type }

    init(id: String?, name: String?, code: String?, type: String?) {
        self.id = id
        self.name = name
        self.code = code
        self.type = type
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let stringId = try? values.decode(String.self, forKey: .id) {
            id = stringId
        } else if let numericId = try? values.decode(Int64.self, forKey: .id) {
            id = String(numericId)
        } else {
            id = nil
        }
        name = try values.decodeIfPresent(String.self, forKey: .name)
        code = try values.decodeIfPresent(String.self, forKey: .code)
        type = try values.decodeIfPresent(String.self, forKey: .type)
    }
}

//
//  About.swift
//  About
//
//  Created by Adam on 9/4/21.
//

import Foundation

struct About: Decodable, Identifiable {
    var id = UUID()
    let policy: String

    static let allPolicy = Bundle.main.decode([About].self, from: "About.json")
    private enum CodingKeys: String, CodingKey {
        case policy
    }
}

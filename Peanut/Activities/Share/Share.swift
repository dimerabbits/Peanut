//
//  Feature.swift
//  Feature
//
//  Created by Adam on 9/4/21.
//

import Foundation

struct Share: Decodable, Identifiable {
    var id = UUID()
    let title: String
    let description: String
    let image: String

    static let allShare = Bundle.main.decode([Share].self, from: "Share.json")

    private enum CodingKeys: String, CodingKey {
        case title, description, image
    }
}

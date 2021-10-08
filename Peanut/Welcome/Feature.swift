//
//  Feature.swift
//  Peanut
//
//  Created by Adam on 9/4/21.
//

import Foundation

struct Feature: Decodable, Identifiable {
    var id = UUID()
    let title: String
    let description: String
    let image: String

    static let allFeatures = Bundle.main.decode([Feature].self, from: "Feature.json")

    private enum CodingKeys: String, CodingKey {
        case title, description, image
    }
}

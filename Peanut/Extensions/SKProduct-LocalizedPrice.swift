//
//  SKProduct-LocalizedPrice.swift
//  SKProduct-LocalizedPrice
//
//  Created by Adam on 9/2/21.
//

import StoreKit

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}

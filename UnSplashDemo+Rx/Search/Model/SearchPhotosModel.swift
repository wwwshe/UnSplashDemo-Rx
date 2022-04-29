//
//  SearchPhotosModel.swift
//  UnSplashDemo+Rx
//
//  Created by jun wook on 2022/03/26.
//

import Foundation

// MARK: - SearchPhotos
struct SearchPhotos: Codable {
    let total, totalPages: Int?
    let results: Photos?
    
    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case results
    }
}

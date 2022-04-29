//
//  PhotosModel.swift
//  UnSplashDemo+Rx
//
//  Created by jun wook on 2022/03/25.
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let photos = try? newJSONDecoder().decode(Photos.self, from: jsonData)

import Foundation

typealias Photos = [Photo]

// MARK: - Photo
struct Photo: Codable {
    let id: String?
    let width, height: Int?
    let blurHash: String?
    let urls: Urls?
    let sponsorship: Sponsorship?
    let user: User?

    enum CodingKeys: String, CodingKey {
        case id
        case width, height
        case blurHash = "blur_hash"
        case urls
        case sponsorship
        case user
    }
}

// MARK: - Sponsorship
struct Sponsorship: Codable {
    let impressionUrls: [String]?
    let tagline: String?
    let taglineURL: String?
    let sponsor: User?

    enum CodingKeys: String, CodingKey {
        case impressionUrls = "impression_urls"
        case tagline
        case taglineURL = "tagline_url"
        case sponsor
    }
}

// MARK: - User
struct User: Codable {
    let id: String?
    let username, name, firstName: String?
    let lastName: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username, name
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

// MARK: - Urls
struct Urls: Codable {
    let raw, full, regular, small: String?
    let thumb, smallS3: String?

    enum CodingKeys: String, CodingKey {
        case raw, full, regular, small, thumb
        case smallS3 = "small_s3"
    }
}

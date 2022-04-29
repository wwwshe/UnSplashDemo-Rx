//
//  ImageCacheManager.swift
//  UnSplashDemo+Rx
//
//  Created by jun wook on 2022/03/25.
//

import Foundation
import UIKit

/// 이미지 캐싱 싱글톤
final class ImageCacheManager {
    static let shared = NSCache<NSString, UIImage>()
    private init() {}
}

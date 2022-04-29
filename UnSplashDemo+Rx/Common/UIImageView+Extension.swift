//
//  UIImageView+Extension.swift
//  UnSplashDemo+Rx
//
//  Created by jun wook on 2022/03/25.
//

import Foundation
import UIKit

extension UIImageView {
    func loadBlurImage(url: String, blurHash: String, size: CGSize) {
        let imageCacheKey = NSString(string: url)
        guard ImageCacheManager.shared.object(forKey: imageCacheKey) == nil else { return }
        
        let blurCacheKey = NSString(string: blurHash)
        if let cachedImage = ImageCacheManager.shared.object(forKey: blurCacheKey) {
            self.image = cachedImage
            return
        }
        DispatchQueue.global(qos: .background).async {
            guard let image = UIImage(blurHash: blurHash,
                                      size: size) else { return }
            
            ImageCacheManager.shared.setObject(image, forKey: blurCacheKey)
            DispatchQueue.main.async { [weak self] in
                guard ImageCacheManager.shared.object(forKey: imageCacheKey) == nil else { return }
                self?.image = image
            }
        }
    }
    
    func loadImage(url: String) {
        let cacheKey = NSString(string: url)
        if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey) {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: url) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async { [weak self] in
                guard let self = self,
                      let data = data,
                      let image = UIImage(data: data) else {
                          return
                      }
                ImageCacheManager.shared.setObject(image, forKey: cacheKey)
                self.image = image
            }
        }.resume()
    }
}

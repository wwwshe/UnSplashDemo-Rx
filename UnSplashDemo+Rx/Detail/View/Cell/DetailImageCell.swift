//
//  DetailImageCell.swift
//  UnSplashDemo+Rx
//
//  Created by jun wook on 2022/03/26.
//

import UIKit

/// 상세 이미지 셀
final class DetailImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = UIImage()
    }
    
    /// 데이터 configure
    func configure(photo: Photo) {
        guard let width = photo.width,
              let height = photo.height else { return }
        
        let imageH = getImageHeight(width: width, height: height)
        
        guard let raw = getImageUrl(photo: photo, imageH: Int(imageH)) else { return }
        
        imageView.loadImage(url: raw)
    }
    
    /// 이미지 url 가져오기
    func getImageUrl(photo: Photo, imageH: Int) -> String? {
        guard let raw = photo.urls?.raw else { return nil}
        
        let screenWidth = Int(UIScreen.main.bounds.width)
        return raw + "&w=\(screenWidth)&h=\(imageH)&auto=format"
    }
    
    /// 이미지 높이 계산하기
    func getImageHeight(width: Int, height: Int) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        if screenWidth < CGFloat(width) {
            let imgHeight = screenWidth * (CGFloat(height) / CGFloat(width))
            return imgHeight
        } else {
            return CGFloat(height)
        }
    }
}

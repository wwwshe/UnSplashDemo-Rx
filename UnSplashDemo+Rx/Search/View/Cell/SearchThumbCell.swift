//
//  SearchThumbCell.swift
//  UnSplashDemo+Rx
//
//  Created by jun wook on 2022/03/26.
//

import UIKit

/// 검색 섬네일 모양 셀
final class SearchThumbCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = UIImage()
    }
    
    /// 이미지 사이즈 만들기
    func getImageSize(photo: Photo) -> CGSize {
        guard let width = photo.width,
              let height = photo.height else { return .zero }
        let imageW = (UIScreen.main.bounds.width / 2) - 5
        let imageH = getImageHeight(width: width, height: height, toWidth: imageW)
        return CGSize(width: imageW, height: imageH)
    }
    
    /// 데이터 configure
    func configure(photo: Photo) {
        let imageSize = getImageSize(photo: photo)
        guard let raw = getImageUrl(photo: photo, imageW: Int(imageSize.width),
                                    imageH: Int(imageSize.height)),
              let blurHash = photo.blurHash else { return }
        
        imageView.loadBlurImage(url: raw, blurHash: blurHash, size: imageSize)
        imageView.loadImage(url: raw)
        
        setUser(photo: photo)
    }
    
    /// 유저 셋팅
    func setUser(photo: Photo) {
        guard let userName = photo.user?.username else {
            return
        }
        authorLabel.text = userName
    }
    
    /// 이미지 url 가져오기
    func getImageUrl(photo: Photo, imageW: Int, imageH: Int) -> String? {
        guard let raw = photo.urls?.raw else { return nil}
        return raw + "&w=\(imageW)&h=\(imageH)&auto=format"
    }
    
    /// 이미지 높이 계산하기
    func getImageHeight(width: Int, height: Int, toWidth: CGFloat) -> CGFloat {
        let imgHeight = toWidth * (CGFloat(height) / CGFloat(width))
        return imgHeight
    }
}

//
//  PhotoListItemCell.swift
//  UnSplashDemo+Rx
//
//  Created by jun wook on 2022/03/25.
//

import UIKit

/// 메인 사진 리스트 셀
final class PhotoListItemCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var sponsorLabel: UILabel!
    @IBOutlet weak var imgHeight: NSLayoutConstraint!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgView.image = UIImage()
    }
    
    /// 데이터 configure
    func configure(photo: Photo) {
        guard let width = photo.width,
              let height = photo.height else { return }
        
        let imageW = UIScreen.main.bounds.width
        let imageH = getImageHeight(width: width, height: height)
        
        guard let raw = getImageUrl(photo: photo, imageH: Int(imageH)),
        let blurHash = photo.blurHash else { return }
        
        let size = CGSize(width: imageW, height: imageH)
        imgView.loadBlurImage(url: raw, blurHash: blurHash, size: size)
        imgHeight.constant = imageH
        imgView.loadImage(url: raw)
        
        setUser(photo: photo)
    }
    
    /// 유저, 스폰서 정보
    func setUser(photo: Photo) {
        guard let userName = photo.user?.username else {
            self.authorLabel.isHidden = true
            self.sponsorLabel.isHidden = true
            return
        }
        authorLabel.text = userName
       
        if let sponsorUserName = photo.sponsorship?.sponsor?.username {
            self.sponsorLabel.isHidden = false
            sponsorLabel.text = sponsorUserName
        } else {
            self.sponsorLabel.isHidden = true
        }
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

//
//  PhotoListViewModel.swift
//  UnSplashDemo+Rx
//
//  Created by jun wook on 2022/03/25.
//

import Foundation
import RxSwift
import RxRelay
import UIKit

/// 사진리스트 뷰모델
final class PhotoListViewModel {
    /// 한번에 가져오는 수
    let perPage = 30
    /// 사진 데이터
    let photos = BehaviorRelay<Photos>(value: [])
    /// 현재 페이지
    var page = 0
    let disposeBag = DisposeBag()
    /// 더보기 가능 여부
    var isMoreAble = true
    /// 첫 요청 여부
    var isFirst = true
    
    init() {
        requestPhotos()
    }
    
    /// photos url 생성
    func createURL() -> URL? {
        var components = URLComponents(string: unsplashAPIURL + unsplashPhotoPath)
        let clientID = URLQueryItem(name: "client_id", value: unsplashAPIKey)
        let page = URLQueryItem(name: "page", value: "\(page)")
        let perPage = URLQueryItem(name: "per_page", value: "\(perPage)")
        components?.queryItems = [clientID, page, perPage]
        return components?.url
    }
    
    /// 사진 가져오기
    func requestPhotos() {
        getPhotos()
            .map { [weak self] photos in
                guard let self = self else { return [] }
                let beforePhotos = self.photos.value
                
                /// 더보기 여부 확인
                if photos.count < self.perPage {
                    self.isMoreAble = false
                }
                
                /// 이전에 가져온 사진  여부 체크
                var resultPhotos = Photos()
                if beforePhotos.count > 0 {
                    resultPhotos += beforePhotos
                } else {
                    self.isFirst = false
                }
                
                resultPhotos += photos
                return resultPhotos
            }
            .bind(to: photos)
            .disposed(by: disposeBag)
    }
    
    /// 사진  더가져오기
    func requestMorePhotos() {
        guard isMoreAble, isFirst == false else { return }
        self.page += 1
        self.requestPhotos()
    }
    
    /// 사진 가져오기
    func getPhotos() -> Observable<Photos> {
        return Observable.create { [weak self] observer in
            /// url 가져오기
            guard let url = self?.createURL() else {
                observer.onNext([])
                return Disposables.create {}
            }
            debugPrint("request url : \(url.absoluteURL)")
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                if error != nil {
                    observer.onNext([])
                    return
                }
                
                do {
                    let photos = try JSONDecoder().decode(Photos.self,
                                                          from: data!)
                    observer.onNext(photos)
                } catch {
                    debugPrint("parese error : \(error)")
                    if let data = data {
                        debugPrint("parese data : \(String(data: data, encoding: .utf8))")
                    }
                    observer.onNext([])
                }
            }
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
}

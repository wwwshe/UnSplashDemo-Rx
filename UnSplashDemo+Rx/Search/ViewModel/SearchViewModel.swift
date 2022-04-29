//
//  SearchViewModel.swift
//  UnSplashDemo+Rx
//
//  Created by jun wook on 2022/03/26.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchViewModel {
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
    /// 검색 키워드
    var keyword = BehaviorRelay<String>(value: "")
    
    init() {
        bind()
    }
    
    func bind() {
        keyword
            .filter { $0.isEmpty == false }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                self?.requestReset()
                self?.requestPhotos()
            })
            .disposed(by: disposeBag)
    }
    
    /// 페이지 초기화
    func requestReset() {
        page = 0
        photos.accept([])
    }
    
    /// search photos url 생성
    func createURL(keyword: String) -> URL? {
        var components = URLComponents(string: unsplashAPIURL + unsplashPhotoSearchPath)
        let clientID = URLQueryItem(name: "client_id", value: unsplashAPIKey)
        let page = URLQueryItem(name: "page", value: "\(page)")
        let perPage = URLQueryItem(name: "per_page", value: "\(perPage)")
        let keyword = URLQueryItem(name: "query", value: keyword)
        components?.queryItems = [clientID, page, perPage, keyword]
        return components?.url
    }
    
    /// 검색 사진 가져오기
    func requestPhotos() {
        getPhotos()
            .map { [weak self] photos -> Photos in
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
            .subscribe(onNext: { [weak self] photos in
                self?.photos.accept(photos)
            })
            .disposed(by: disposeBag)
    }
    
    /// 검색 사진  더가져오기
    func requestMorePhotos() {
        guard isMoreAble, isFirst == false else { return }
        self.page += 1
        self.requestPhotos()
    }
    
    /// 검색 사진 가져오기
    func getPhotos() -> Observable<Photos> {
        let keyword = keyword.value
        return Observable.create { [weak self] observer in
            /// url 가져오기
            guard let url = self?.createURL(keyword: keyword) else {
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
                    let searchPhotos = try JSONDecoder().decode(SearchPhotos.self,
                                                                from: data!)
                    let photos = searchPhotos.results ?? []
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

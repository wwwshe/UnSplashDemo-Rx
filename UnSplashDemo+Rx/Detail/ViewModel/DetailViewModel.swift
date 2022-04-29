//
//  DetailViewModel.swift
//  UnSplashDemo+Rx
//
//  Created by jun wook on 2022/03/26.
//

import Foundation
import RxSwift
import RxCocoa

/// 상세화면 뷰모델
final class DetailViewModel {
    /// 사진 데이터
    let photos = BehaviorRelay<Photos>(value: [])
    /// 현재 보고있는 index
    var selectIndex = BehaviorRelay<Int>(value: 0)
}

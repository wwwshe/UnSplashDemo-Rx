//
//  SearchViewController.swift
//  UnSplashDemo+Rx
//
//  Created by jun wook on 2022/03/26.
//

import UIKit
import RxSwift
import RxCocoa

/// 검색 화면
final class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let layout = FlexibleFlowLayout(columns: 2)
            layout.delegate = self
            collectionView.collectionViewLayout = layout
            collectionView.register(UINib(nibName: "SearchThumbCell", bundle: nil), forCellWithReuseIdentifier: "SearchThumbCell")
        }
    }
    
    let viewModel = SearchViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    func bind() {
        searchBar.rx.text
            .orEmpty
            .bind(to: viewModel.keyword)
            .disposed(by: disposeBag)
        
        viewModel.photos
            .bind(to: collectionView.rx.items(cellIdentifier: "SearchThumbCell")) { (_, item, cell) in
                guard let cell = cell as? SearchThumbCell else { return }
                cell.configure(photo: item)
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.willDisplayCell
            .asDriver()
            .drive(onNext: { (cell, indexPath) in
                if indexPath.row >= (self.viewModel.photos.value.count - 10) {
                    self.viewModel.requestMorePhotos()
                }
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [weak self] indexPath in
                let row = indexPath.row
                self?.moveDetail(row: row)
            })
            .disposed(by: disposeBag)
    }
    
    /// 상세화면 으로
    func moveDetail(row: Int) {
        if let vc = getViewController(target: DetailViewController.self) {
            let photos = viewModel.photos.value
            vc.viewModel.photos.accept(photos)
            vc.viewModel.selectIndex.accept(row)
            vc.viewModel.selectIndex
                .asDriver()
                .drive(onNext: { [weak self] selectIndex in
                    DispatchQueue.main.async {
                        self?.collectionView.scrollToItem(at: IndexPath(row: selectIndex, section: 0), at: .centeredVertically, animated: false)
                    }
                })
                .disposed(by: disposeBag)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension SearchViewController: FlexibleLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchThumbCell", for: indexPath) as? SearchThumbCell else {
            return .zero
        }
        
        let photo = viewModel.photos.value[indexPath.row]
        return cell.getImageSize(photo: photo).height
    }
}

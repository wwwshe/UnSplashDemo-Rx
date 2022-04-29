//
//  PhotoListViewController.swift
//  UnSplashDemo+Rx
//
//  Created by jun wook on 2022/03/25.
//

import UIKit
import RxSwift
import RxCocoa

/// 사진 리스트 화면
final class PhotoListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.contentInsetAdjustmentBehavior = .never
            tableView.register(UINib(nibName: "PhotoListItemCell", bundle: nil), forCellReuseIdentifier: "PhotoListItemCell")
        }
    }
    
    let viewModel = PhotoListViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    func bind() {
        viewModel.photos
            .bind(to: tableView.rx.items(cellIdentifier: "PhotoListItemCell")) { (_, item, cell) in
                guard let cell = cell as? PhotoListItemCell else { return }
                cell.configure(photo: item)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.willDisplayCell
            .asDriver()
            .drive(onNext: { [weak self] (_, indexPath) in
                guard let self = self else { return }
                
                if indexPath.row >= (self.viewModel.photos.value.count - 10) {
                    self.viewModel.requestMorePhotos()
                }
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [weak self] indexPath in
                let row = indexPath.row
                self?.moveDetail(row: row)
            })
            .disposed(by: disposeBag)
    }
    
    /// 상세화면 이동
    func moveDetail(row: Int) {
        if let vc = getViewController(target: DetailViewController.self) {
            let photos = viewModel.photos.value
            vc.viewModel.photos.accept(photos)
            vc.viewModel.selectIndex.accept(row)
            vc.viewModel.selectIndex
                .asDriver()
                .drive(onNext: { [weak self] selectIndex in
                    DispatchQueue.main.async {
                        self?.tableView.scrollToRow(at: IndexPath(row: selectIndex, section: 0), at: .middle, animated: false)
                    }
                })
                .disposed(by: disposeBag)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

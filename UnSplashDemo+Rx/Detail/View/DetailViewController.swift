//
//  DetailViewController.swift
//  UnSplashDemo+Rx
//
//  Created by jun wook on 2022/03/26.
//

import UIKit
import RxSwift
import RxCocoa

/// 상세 화면 뷰
final class DetailViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var sponsorLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            let cellWidth = UIScreen.main.bounds.width
            let cellHeight = UIScreen.main.bounds.height
            layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
            collectionView.contentInsetAdjustmentBehavior = .never
            collectionView.collectionViewLayout = layout
            collectionView.register(UINib(nibName: "DetailImageCell", bundle: nil), forCellWithReuseIdentifier: "DetailImageCell")
            collectionView.decelerationRate = .fast
            _ = collectionView.rx.setDelegate(self)
        }
    }
    
    let viewModel = DetailViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func bind() {
        closeButton.rx.tap
            .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.photos
            .bind(to: collectionView.rx.items(cellIdentifier: "DetailImageCell")) { (_, item, cell) in
                guard let cell = cell as? DetailImageCell else { return }
                cell.configure(photo: item)
            }
            .disposed(by: disposeBag)
        
        viewModel.selectIndex
            .asDriver()
            .drive(onNext: { [weak self] selectIndex in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.collectionView.scrollToItem(at: IndexPath(row: selectIndex, section: 0), at: .left, animated: false)
                }
                let photo = self.viewModel.photos.value[selectIndex]
                self.setUser(photo: photo)
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.willDisplayCell
            .asDriver()
            .drive(onNext: { (cell, indexPath) in
                
            })
            .disposed(by: disposeBag)
    }
    
    /// 유저 셋팅
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
    
    deinit {
        debugPrint("Detail deinit")
    }
}

extension DetailViewController: UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        let estimatedIndex = scrollView.contentOffset.x / cellWidthIncludingSpacing
        let index: Int
        if velocity.x > 0 {
            index = Int(ceil(estimatedIndex))
        } else if velocity.x < 0 {
            index = Int(floor(estimatedIndex))
        } else {
            index = Int(round(estimatedIndex))
        }
        
        self.viewModel.selectIndex.accept(index)
        
        targetContentOffset.pointee = CGPoint(x: CGFloat(index) * cellWidthIncludingSpacing, y: 0)
    }
}

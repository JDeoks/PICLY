//
//  MyAlbumsViewController.swift
//  PiCo
//
//  Created by 서정덕 on 11/18/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxKeyboard
import SnapKit
import PhotosUI
import SwiftDate
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class MyAlbumsViewController: UIViewController {
    
    private var filteredAlbums: [AlbumModel] = []
    private var keyboardHeight: CGFloat = 0
    
    let disposeBag = DisposeBag()
    
    private let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    let refreshControl = UIRefreshControl()
    
    @IBOutlet var titleStackView: UIStackView!
    @IBOutlet var searchTagStackView: UIStackView!
    @IBOutlet var searchTagTextField: UITextField!
    @IBOutlet var searchCancelButton: UIButton!
    @IBOutlet var myAlbumsCollectionView: UICollectionView!
    @IBOutlet var plusButton: UIButton!
    @IBOutlet var keyboardToolContainerView: UIView!
    @IBOutlet var hideKeyboardButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initData()
        action()
        bind()
    }
    
    func initUI() {
        // 검색 바
        searchTagStackView.layer.cornerRadius = 4
        searchTagTextField.delegate = self
        searchCancelButton.isHidden = true
        
        // 내비게이션
        self.navigationController?.navigationBar.isHidden = true
        
        // refreshControl
        refreshControl.tintColor = ColorManager.shared.secondText
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        
        // myAlbumsCollectionView
        myAlbumsCollectionView.dataSource = self
        myAlbumsCollectionView.delegate = self
        let myAlbumsCollectionViewCell = UINib(nibName: "MyAlbumsCollectionViewCell", bundle: nil)
        myAlbumsCollectionView.register(myAlbumsCollectionViewCell, forCellWithReuseIdentifier: "MyAlbumsCollectionViewCell")
        let myAlbumsDefaultCollectionViewCell = UINib(nibName: "MyAlbumsDefaultCollectionViewCell", bundle: nil)
        myAlbumsCollectionView.register(myAlbumsDefaultCollectionViewCell, forCellWithReuseIdentifier: "MyAlbumsDefaultCollectionViewCell")
        myAlbumsCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        myAlbumsCollectionView.refreshControl = refreshControl
        // 드래그시 키보드 내림
        myAlbumsCollectionView.keyboardDismissMode = .onDrag
        
        // plusButton
        plusButton.layer.cornerRadius = plusButton.frame.height / 2
        plusButton.layer.shadowColor = UIColor.black.cgColor
        plusButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        plusButton.layer.shadowRadius = 4
        plusButton.layer.shadowOpacity = 0.25
    }
    
    @objc func pullToRefresh(_ sender: Any) {
        stopSearching()
        DataManager.shared.fetchMyAlbums()
        refreshControl.endRefreshing()
    }
    
    func initData() {
        //TODO: 내 데이터 fetch
        DataManager.shared.fetchMyAlbums()
    }
    
    func action() {
        searchCancelButton.rx.tap
            .subscribe { _ in
                self.stopSearching()
            }
            .disposed(by: disposeBag)
        
        plusButton.rx.tap
            .subscribe { _ in
                HapticManager.shared.triggerImpact()
                self.stopSearching()
                SceneManager.shared.presentUploadVC(vc: self)
            }
            .disposed(by: disposeBag)
        
        // 키보드 툴바
        RxKeyboard.instance.visibleHeight
            .skip(1)
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.keyboardHeight = keyboardVisibleHeight
                UIView.animate(withDuration: 0.0, delay: 0, options: .curveEaseInOut, animations: {
                    strongSelf.keyboardToolContainerView.snp.updateConstraints { make in
                        if keyboardVisibleHeight == 0 {
                            let containerViewHeight = strongSelf.keyboardToolContainerView.frame.height
                            make.bottom.equalToSuperview().inset(-containerViewHeight).priority(1000)
                        } else {
                            make.bottom.equalToSuperview().inset(keyboardVisibleHeight).priority(1000)
                        }
                    }
                    strongSelf.view.layoutIfNeeded()
                })
            })
            .disposed(by: disposeBag)
        
        // searchTagTextField
        searchTagTextField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { changedText in
                self.updateFilteredAlbums(keyword: changedText)
            })
            .disposed(by: disposeBag)
        
        hideKeyboardButton.rx.tap
            .subscribe { _ in
                self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    }

    func bind() {
        DataManager.shared.updateMyAlbumsDone
            .subscribe { _ in
                self.filteredAlbums = DataManager.shared.myAlbums
                self.myAlbumsCollectionView.reloadData()
            }
            .disposed(by: disposeBag)
    }

}

// MARK: - UICollectionView
extension MyAlbumsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(filteredAlbums.count, 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 내 앨범이 없음
        if DataManager.shared.myAlbums.isEmpty {
            let cell = myAlbumsCollectionView.dequeueReusableCell(withReuseIdentifier: "MyAlbumsDefaultCollectionViewCell", for: indexPath) as! MyAlbumsDefaultCollectionViewCell
            cell.setData(state: .empty)
            return cell
        } else if filteredAlbums.isEmpty { // 검색 결과 없음
            let cell = myAlbumsCollectionView.dequeueReusableCell(withReuseIdentifier: "MyAlbumsDefaultCollectionViewCell", for: indexPath) as! MyAlbumsDefaultCollectionViewCell
            cell.setData(state: .noSearchResults)
            return cell
        } else { // 표시할 앨범 있음
            let cell = myAlbumsCollectionView.dequeueReusableCell(withReuseIdentifier: "MyAlbumsCollectionViewCell", for: indexPath) as! MyAlbumsCollectionViewCell
            if filteredAlbums.indices.contains(indexPath.row) {
                cell.setData(album: filteredAlbums[indexPath.row])
                
                cell.copyLinkButton.rx.tap
                    .subscribe { _ in
                        HapticManager.shared.triggerImpact()
                        UIPasteboard.general.url = cell.albumURL
                        self.showToast(message: "링크가 복사되었습니다.", keyboardHeight: self.keyboardHeight)
                        print(cell.albumURL)
                    }
                    .disposed(by: cell.disposeBag)
                
            } else {
                print("인덱스 오류")
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        stopSearching()
        SceneManager.shared.pushDetailVC(vc: self, album: filteredAlbums[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 내 앨범이 없거나, 검색 결과가 없을 때
        if filteredAlbums.count == 0 {
            let cellWidth = collectionView.frame.width
            let cellHeight = collectionView.frame.height / 2
            return CGSize(width: cellWidth, height: cellHeight)
        }
        
        let width = collectionView.frame.width
        let itemsPerRow: CGFloat = 2
        let widthPadding = sectionInsets.left * (itemsPerRow + 1)
        let cellWidth = (width - widthPadding) / itemsPerRow
        
        return CGSize(width: cellWidth, height: cellWidth + 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

}

// MARK: - UITextField
extension MyAlbumsViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        startSearching()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
    
    /// 검색 시작 애니메이션
    func startSearching() {
        self.searchCancelButton.isHidden = false
        UIView.animate(withDuration: 0.1, animations: {
            self.titleStackView.isHidden = true
            self.view.layoutIfNeeded()
        })
    }
    
    func stopSearching() {
        print("\(type(of: self)) - \(#function)")
        
        searchTagTextField.text = ""
        // 검색 정보 초기화
        if !(filteredAlbums.count == DataManager.shared.myAlbums.count) {
            filteredAlbums = DataManager.shared.myAlbums
            myAlbumsCollectionView.reloadData()
        }
        // 검색 취소 애니메이션
        searchCancelButton.isHidden = true
        view.endEditing(true)
        UIView.animate(withDuration: 0.1 ,animations: {
            self.titleStackView.isHidden = false
            self.view.layoutIfNeeded()
        })
    }
    
    // TODO: 질문 언더바 입력 하고
    func updateFilteredAlbums(keyword: String) {
        print("\(type(of: self)) - \(#function)", keyword)
        
        if keyword.isEmpty {
            filteredAlbums = DataManager.shared.myAlbums
            myAlbumsCollectionView.reloadData()
            return
        }
        filteredAlbums = DataManager.shared.myAlbums.filter { album in
            return album.tags.contains { tag in
                return tag.contains(keyword)
            }
        }
        myAlbumsCollectionView.reloadData()
    }
        
}

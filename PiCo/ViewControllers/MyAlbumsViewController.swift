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
    
    let disposeBag = DisposeBag()
    
    let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
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
        refreshControl.tintColor = UIColor(named: "SecondText")
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        
        // myAlbumsCollectionView
        myAlbumsCollectionView.dataSource = self
        myAlbumsCollectionView.delegate = self
        let myAlbumsCollectionViewCell = UINib(nibName: "MyAlbumsCollectionViewCell", bundle: nil)
        myAlbumsCollectionView.register(myAlbumsCollectionViewCell, forCellWithReuseIdentifier: "MyAlbumsCollectionViewCell")
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
        DataManager.shared.fetchAlbums()
        refreshControl.endRefreshing()
    }
    
    func initData() {
        //TODO: 내 데이터 fetch
        DataManager.shared.fetchAlbums()
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
                UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
                    strongSelf.keyboardToolContainerView.snp.updateConstraints { make in
                        if keyboardVisibleHeight == 0 {
                            let containerViewHeight = strongSelf.keyboardToolContainerView.frame.height
                            make.bottom.equalToSuperview().inset(-containerViewHeight).priority(1000)
                        } else {
                            make.bottom.equalToSuperview().inset(keyboardVisibleHeight).priority(1000)
                        }
                    }
                    strongSelf.view.layoutIfNeeded() // 중요: 레이아웃 즉시 업데이트
                })
            })
            .disposed(by: disposeBag)
        
        hideKeyboardButton.rx.tap
            .subscribe { _ in
                self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    }
    
    func bind() {
        DataManager.shared.fetchAlbumsDone
            .subscribe { _ in
                self.myAlbumsCollectionView.reloadData()
            }
            .disposed(by: disposeBag)
    }

}

// MARK: - UICollectionView
extension MyAlbumsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataManager.shared.albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = myAlbumsCollectionView.dequeueReusableCell(withReuseIdentifier: "MyAlbumsCollectionViewCell", for: indexPath) as! MyAlbumsCollectionViewCell
        if DataManager.shared.albums.indices.contains(indexPath.row) {
            cell.setData(album: DataManager.shared.albums[indexPath.row])
            
            cell.copyLinkButton.rx.tap
                .subscribe { _ in
                    HapticManager.shared.triggerImpact()
                    UIPasteboard.general.url = cell.albumURL
                    self.showToast(message: "링크가 복사되었습니다.")
                    print(cell.albumURL)
                }
                .disposed(by: cell.disposeBag)
            
        } else {
            print("인덱스 오류")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        stopSearching()
        SceneManager.shared.pushDetailVC(vc: self, album: DataManager.shared.albums[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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
    
    /// 검색 시작 시 애니메이션
    func textFieldDidBeginEditing(_ textField: UITextField) {
        startSearching()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 입력된 스트링이 공백일때 언더바를 대신 추가
        if string == " " {
            textField.text?.append("_")
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
    
    func startSearching() {
        self.searchCancelButton.isHidden = false
        UIView.animate(withDuration: 0.1, animations: {
            self.titleStackView.isHidden = true
            self.view.layoutIfNeeded()
        })
    }
    
    // 검색 취소 시
    func stopSearching() {
        searchCancelButton.isHidden = true
        searchTagTextField.text = ""
        view.endEditing(true)
        UIView.animate(withDuration: 0.1 ,animations: {
            self.titleStackView.isHidden = false
            self.view.layoutIfNeeded()
        })
    }
        
}

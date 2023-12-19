//
//  MyPhotosViewController.swift
//  PiCo
//
//  Created by 서정덕 on 11/18/23.
//

import UIKit
import RxSwift
import RxCocoa

class MyAlbumsViewController: UIViewController {
    
    var albums: [AlbumModel] = []
    
    let disposeBag = DisposeBag()
    
    let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    let refreshControl = UIRefreshControl()
    
    @IBOutlet var titleStackView: UIStackView!
    @IBOutlet var searchTagStackView: UIStackView!
    @IBOutlet var searchTagTextField: UITextField!
    @IBOutlet var searchCancelButton: UIButton!
    @IBOutlet var myPhotosCollectionView: UICollectionView!
    @IBOutlet var plusButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initData()
        action()
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
        
        // myPhotosCollectionView
        myPhotosCollectionView.dataSource = self
        myPhotosCollectionView.delegate = self
        let myPhotosCollectionViewCell = UINib(nibName: "MyPhotosCollectionViewCell", bundle: nil)
        myPhotosCollectionView.register(myPhotosCollectionViewCell, forCellWithReuseIdentifier: "MyPhotosCollectionViewCell")
        myPhotosCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        myPhotosCollectionView.refreshControl = refreshControl
        
        // 드래그시 키보드 내림
        myPhotosCollectionView.keyboardDismissMode = .onDrag
        
        // plusButton
        plusButton.layer.cornerRadius = plusButton.frame.height / 2
    }
    
    @objc func pullToRefresh(_ sender: Any) {
        refreshControl.endRefreshing()
    }
    
    func initData() {
        //TODO: 내 데이터 fetch
    }
    
    func action() {
        searchCancelButton.rx.tap
            .subscribe { _ in
                self.stopSearching()
            }
            .disposed(by: disposeBag)
        
        plusButton.rx.tap
            .subscribe { _ in
                print("plusButton")

                self.stopSearching()
                let uploadVC = self.storyboard?.instantiateViewController(identifier: "UploadViewController") as! UploadViewController
                uploadVC.modalPresentationStyle = .overFullScreen
                self.present(uploadVC, animated: true)
            }
            .disposed(by: disposeBag)
    }

}

// MARK: - 컬렉션 뷰
extension MyAlbumsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = myPhotosCollectionView.dequeueReusableCell(withReuseIdentifier: "MyPhotosCollectionViewCell", for: indexPath) as! MyPhotosCollectionViewCell
        cell.setData(album: albums[indexPath.row])
        cell.copyLinkButton.rx.tap
            .subscribe { _ in
                // TODO: url 복사
                UIPasteboard.general.url = cell.postURL
//                self.showToast(message: "링크가 복사되었습니다.")
                self.showToast(message: "\(cell.postURL)")
            }
            .disposed(by: cell.disposeBag)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        stopSearching()
        SceneManager.shared.pushDetailVC(vc: self)
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

// MARK: - 텍스트 필드
extension MyAlbumsViewController: UITextFieldDelegate {
    
    /// 검색 시작 시 애니메이션
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.searchCancelButton.isHidden = false
        UIView.animate(withDuration: 0.1, animations: {
            self.titleStackView.isHidden = true
        })
    }
    
    // 검색 취소 시
    func stopSearching() {
        searchCancelButton.isHidden = true
        searchTagTextField.text = ""
        searchTagTextField.resignFirstResponder()
        UIView.animate(withDuration: 0.1 ,animations: {
            self.titleStackView.isHidden = false
        })
    }
    
}

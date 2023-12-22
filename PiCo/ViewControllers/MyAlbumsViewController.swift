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
    
    let albumsRef = Firestore.firestore().collection("Albums")
    let userRef = Firestore.firestore().collection("Users")
    var albums: [AlbumModel] = []
    
    /// fetchAlbums() -> MyAlbumsViewController
    let fetchAlbumsDone = PublishSubject<Void>()
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
    }
    
    @objc func pullToRefresh(_ sender: Any) {
        stopSearching()
        fetchAlbums()
        refreshControl.endRefreshing()
    }
    
    func initData() {
        //TODO: 내 데이터 fetch
        fetchAlbums()
    }
    
    func action() {
        searchCancelButton.rx.tap
            .subscribe { _ in
                self.stopSearching()
            }
            .disposed(by: disposeBag)
        
        plusButton.rx.tap
            .subscribe { _ in
                self.stopSearching()
                SceneManager.shared.presentUploadVC(vc: self)
            }
            .disposed(by: disposeBag)
        
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
        fetchAlbumsDone
            .subscribe { _ in
                self.myAlbumsCollectionView.reloadData()
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
        let cell = myAlbumsCollectionView.dequeueReusableCell(withReuseIdentifier: "MyAlbumsCollectionViewCell", for: indexPath) as! MyAlbumsCollectionViewCell
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

// MARK: - data
extension MyAlbumsViewController {
    
    func fetchAlbums() {
        print("\(type(of: self)) - \(#function)")
        
        albums.removeAll()
        guard let userID = Auth.auth().currentUser?.uid else {
            print("currentUser 없음 ")
            return
        }
        fetchAlbumIDsForUser(userID: userID) { albumIDs in
            self.fetchAlbumsWithIDs(docIDs: albumIDs) {
                self.fetchAlbumsDone.onNext(())
            }
        }
    }
    
    
    func fetchAlbumIDsForUser(userID: String, completion: @escaping ([String]) -> Void) {
        print("\(type(of: self)) - \(#function)")

        let userDocRef = userRef.document(userID)
        userDocRef.getDocument { (document, error) in
            guard let document = document, document.exists, error == nil else {
                print("\(type(of: self)) - \(#function) AlbumIDs fetch 실패 \(error?.localizedDescription ?? "")")
                return
            }
            guard let albumIDs = document.data()?[UserField.albumIDs.rawValue] as? [String] else {
                print("\(type(of: self)) - \(#function) albumIDs 변환 실패")
                return
            }
            completion(albumIDs)
        }
    }
    
    func fetchAlbumsWithIDs(docIDs: [String], completion: @escaping () -> Void) {
        print("\(type(of: self)) - \(#function)")

        let db = Firestore.firestore()
        let albumsRef = db.collection("Albums")
        albumsRef.whereField(FieldPath.documentID(), in: docIDs).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("\(type(of: self)) - \(#function) querySnapshot fetch 실패")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let albumDoc = document as DocumentSnapshot
                    self.albums.append(AlbumModel(document: albumDoc))
                }
                completion()
            }
        }
    }
        
}

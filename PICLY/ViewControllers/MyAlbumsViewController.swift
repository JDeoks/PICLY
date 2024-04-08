//
//  MyAlbumsViewController.swift
//  PICLY
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
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import RxGesture

class MyAlbumsViewController: UIViewController {
    
    let loginManager = LoginManager()
    let myAlbumsViewModel = MyAlbumsViewModel()
    
    private var filteredAlbums: [AlbumModel] = []
    private var keyboardHeight: CGFloat = 0
    
    let disposeBag = DisposeBag()
    
    private let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    lazy var loadingView = LoadingIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
    let refreshControl = UIRefreshControl()
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var titleStackView: UIStackView!
    @IBOutlet var searchTagStackView: UIStackView!
    @IBOutlet var searchTagTextField: UITextField!
    @IBOutlet var searchCancelButton: UIButton!
    @IBOutlet var myAlbumsCollectionView: UICollectionView!
    @IBOutlet var plusButton: UIButton!
    @IBOutlet var keyboardToolContainerView: UIView!
    @IBOutlet var hideKeyboardButton: UIButton!
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(type(of: self)) - \(#function)")
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "id-\(title!)",
            AnalyticsParameterItemName: title!,
            AnalyticsParameterContentType: "cont",
        ])
        
        initUI()
        initData()
        action()
        bind()
    }
    
    // MARK: - initUI
    private func initUI() {
        // titleLabel
        titleLabel.text = "PICLY"
        
        // 검색 바
        searchTagStackView.layer.cornerRadius = 4
        searchTagTextField.delegate = self
        searchTagTextField.attributedPlaceholder = NSAttributedString(string: "태그 검색", attributes: [NSAttributedString.Key.foregroundColor : ColorManager.shared.secondText])
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
        myAlbumsViewModel.fetchMyAlbums()
        refreshControl.endRefreshing()
    }
    
    // MARK: - initData
    func initData() {
        // fetch 하기 전 스켈레톤으로 초기화
        ConfigManager.shared.fetchRemoteConfig()
        UserManager.shared.fetchUserAuth()
        myAlbumsViewModel.fetchMyAlbums()
    }
    
    // MARK: - action
    func action() {
        // 검색 취소 버튼
        searchCancelButton.rx.tap
            .subscribe { _ in
                self.stopSearching()
            }
            .disposed(by: disposeBag)
        
        // 글 작성 버튼
        plusButton.rx.tap
            .subscribe { _ in
                HapticManager.shared.triggerImpact()
                self.stopSearching()
                SceneManager.shared.presentUploadVC(vc: self)
            }
            .disposed(by: disposeBag)
        
        // 키보드 툴바 위치
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
        
        // 키보드 내리기 버튼
        hideKeyboardButton.rx.tap
            .subscribe { _ in
                self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        
        // 검색 창 텍스트
        searchTagTextField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { changedText in
                print("changedText")
                self.updateFilteredAlbums(keyword: changedText)
                print(self.filteredAlbums.count)
            })
            .disposed(by: disposeBag)
        
        // myAlbumsCollectionView
        // longPress -> 색 변화
        myAlbumsCollectionView.rx.longPressGesture(configuration: { recognizer, delegate in
            recognizer.minimumPressDuration = 0.2
            recognizer.allowableMovement = 30
        })
            .asObservable()
            .when(.began, .cancelled, .changed, .ended)
            .subscribe { gestureEvent in
                guard let recognizer = gestureEvent.element else {
                    return
                }
                let location: CGPoint = recognizer.location(in: self.myAlbumsCollectionView)
                guard let indexPath = self.myAlbumsCollectionView.indexPathForItem(at: location) else {
                    return
                }
                guard let cell = self.myAlbumsCollectionView.cellForItem(at: indexPath) as? MyAlbumsCollectionViewCell else {
                    return
                }
                switch recognizer.state {
                case .began:
                    print("myAlbumsCollectionView - longPressGesture(.began) -> 홀드시 색 변화")
                    UIView.animate(withDuration: 0.5) {
                        cell.alpha = 0.5
                    }
                case .cancelled, .changed, .ended:
                    UIView.animate(withDuration: 0.2) {
                        cell.alpha = 1
                    }
                default:
                    return
                }
            }
            .disposed(by: disposeBag)
        // longPress -> 진동, 삭제 alert
        myAlbumsCollectionView.rx.longPressGesture(configuration: { recognizer, delegate in
            recognizer.minimumPressDuration = 0.7
//            recognizer.allowableMovement = 30
        })
            .asObservable()
            .when(.began)
            .subscribe { gestureEvent in
                print("myAlbumsCollectionView - longPressGesture(.began) -> 진동, 삭제 alert")
                
                guard let recognizer = gestureEvent.element else {
                    return
                }
                let location: CGPoint = recognizer.location(in: self.myAlbumsCollectionView)
                let indexPath = self.myAlbumsCollectionView.indexPathForItem(at: location)
                guard let index = indexPath?.row else {
                    print("error: myAlbumsCollectionView - longPressGesture(.began) -> 진동, 삭제 alert -> indexPath 없음")
                    return
                }
                if self.myAlbumsViewModel.myAlbums.indices.contains(index) {
                    HapticManager.shared.triggerImpact()
                    self.showDeleteConfirmationAlert(album: self.myAlbumsViewModel.myAlbums[index])
                }
            }
            .disposed(by: disposeBag)

    }

    // MARK: - bind
    func bind() {
        print("\(type(of: self)) - \(#function)")

        myAlbumsViewModel.fetchMyAlbumsDone
            .subscribe { _ in
                self.filteredAlbums = self.myAlbumsViewModel.myAlbums
                self.myAlbumsCollectionView.reloadData()
            }
            .disposed(by: disposeBag)
        
        myAlbumsViewModel.deleteAlbumDone
            .subscribe { albumID in
                DataManager.shared.albumDeleted.onNext(albumID)
            }
            .disposed(by: disposeBag)
        
        myAlbumsViewModel.deleteAlbumFailed
            .subscribe { errorMSG in
                print("삭제 실패:\(errorMSG)")
                self.loadingView.removeFromSuperview()
                self.showToast(message: "앨범 삭제에 실패했습니다.")
            }
            .disposed(by: disposeBag)
        
        ConfigManager.shared.fetchRemoteConfigDone
            .subscribe { _ in
                print("fetchRemoteConfigDone")
                //
                if !ConfigManager.shared.getIsCheckingFromLocal().isEmpty {
                    DispatchQueue.main.async {
                        self.showNoticeAlert(message: ConfigManager.shared.getIsCheckingFromLocal())
                    }
                    return
                }
                if ConfigManager.shared.isMinimumVersionSatisfied() == false {
                    DispatchQueue.main.async {
                        self.showNoticeAlert(message: "업데이트가 필요합니다.\n앱스토어에서 앱을 업데이트 해주세요.")
                    }
                    return
                }
            }
            .disposed(by: disposeBag)
        
        UserManager.shared.fetchUserAuthFailed
            .subscribe { _ in
                print("fetchUserAuthFailed")
                self.loginManager.signOut(completion: { result in })
                SceneManager.shared.setSignInNavVCAsRoot(animated: false)
            }
            .disposed(by: disposeBag)
                
        DataManager.shared.albumUploaded
            .subscribe { albumID in
                self.myAlbumsViewModel.fetchMyAlbums()
            }
            .disposed(by: disposeBag)
        
        DataManager.shared.albumDeleted
            .subscribe { albumID in
                self.loadingView.removeFromSuperview()
                self.myAlbumsViewModel.fetchMyAlbums()
                self.showToast(message: "앨범 삭제에 성공했습니다.", keyboardHeight: self.keyboardHeight)
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
        if myAlbumsViewModel.myAlbums.isEmpty {
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
        print("\(type(of: self)) - \(#function)")

        print(filteredAlbums[indexPath.row].imageURLs)
        SceneManager.shared.pushDetailVC(vc: self, album: filteredAlbums[indexPath.row])
        stopSearching()
        
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
        print("\(type(of: self)) - \(#function)")

        UIView.animate(withDuration: 0.1) {
            self.titleStackView.isHidden = true
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.searchCancelButton.isHidden = false
            self.view.layoutIfNeeded()
        }
    }
    
    func stopSearching() {
        print("\(type(of: self)) - \(#function)")
        
        searchTagTextField.text = ""
        // 검색 정보 초기화
        if !(filteredAlbums.count == myAlbumsViewModel.myAlbums.count) {
            filteredAlbums = myAlbumsViewModel.myAlbums
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
            filteredAlbums = myAlbumsViewModel.myAlbums
            myAlbumsCollectionView.reloadData()
            return
        }
        filteredAlbums = myAlbumsViewModel.myAlbums.filter { album in
            return album.tags.contains { tag in
                return tag.contains(keyword)
            }
        }
        myAlbumsCollectionView.reloadData()
    }
    
    // MARK: - 앨범 삭제
    /// 앨범 삭제 확인 alert
    private func showDeleteConfirmationAlert(album: AlbumModel) {
        print("\(type(of: self)) - \(#function)")
        
        let deleteAlert = UIAlertController(title: "앨범 삭제", message: "앨범을 삭제하시겠습니까?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            self.loadingView.loadingLabel.text = ""
            self.view.addSubview(self.loadingView)
            self.myAlbumsViewModel.deleteAlbum(album: album)
        })
        deleteAlert.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        deleteAlert.addAction(cancelAction)
        self.present(deleteAlert, animated: true, completion: nil)
    }
        
}



//
//  UploadViewController.swift
//  PiCo
//
//  Created by 서정덕 on 11/19/23.
//

import UIKit
import RxSwift
import RxKeyboard
import SnapKit
import PhotosUI
import SwiftDate
import FirebaseFirestore
import FirebaseStorage

class UploadViewController: UIViewController {
    
    let albumCollection = Firestore.firestore().collection("Albums")
    /// 서버에 저장된 사진 URL
    var albumURL: URL?
    /// 선택한 사진 배열
    var images: [UIImage] = []
    var expireTime = Date()
    
    let didFinishPickingDone = PublishSubject<Void>()
    let removeImagesAtDone = PublishSubject<Void>()
    let uploadAlbumDone = PublishSubject<Void>()
    let disposeBag = DisposeBag()
    
    lazy var loadingView = LoadingIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
    let sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

    @IBOutlet var closeButton: UIButton!
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var inputTagStackView: UIStackView!
    @IBOutlet var tagTextField: UITextField!
    @IBOutlet var collectionViewStackView: UIStackView!
    @IBOutlet var selectedImageCollectionView: UICollectionView!
    @IBOutlet var expireDatePicker: UIDatePicker!
    @IBOutlet var leftTimeLabel: UILabel!

    @IBOutlet var keyboardToolContainerView: UIView!
    @IBOutlet var hideKeyboardButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initData()
        action()
        bind()
        print(scrollView.frame)
    }
    
    func initUI() {
        // 태그 스택뷰
        inputTagStackView.layer.cornerRadius = 4
        
        // datePicker
        expireDatePicker.date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        expireDatePicker.tintColor = UIColor(named: "HighlightBlue")
        
        // scrollView
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        
        // selectedImageCollectionView
        selectedImageCollectionView.dataSource = self
        selectedImageCollectionView.delegate = self
        let selectedImageCollectionViewCell = UINib(nibName: "SelectedImageCollectionViewCell", bundle: nil)
        selectedImageCollectionView.register(selectedImageCollectionViewCell, forCellWithReuseIdentifier: "SelectedImageCollectionViewCell")
        let addImageCollectionViewCell = UINib(nibName: "AddImageCollectionViewCell", bundle: nil)
        selectedImageCollectionView.register(addImageCollectionViewCell, forCellWithReuseIdentifier: "AddImageCollectionViewCell")
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        selectedImageCollectionView.collectionViewLayout = flowLayout
        selectedImageCollectionView.alwaysBounceHorizontal = true

        // collectionViewStackView
        collectionViewStackView.layer.cornerRadius = 4
    }
    
    func initData() {
        // datePicker
        var dateComponents = DateComponents()
        dateComponents.month = 1 // 1달 후까지의 범위 설정
        let maxDate = Calendar.current.date(byAdding: dateComponents, to: Date())
        // 현재부터 한달 뒤 까지 선택 가능하게 설정
        expireDatePicker.minimumDate = Date()
        expireDatePicker.maximumDate = maxDate
    }

    func action() {
        // 창닫기 버튼
        closeButton.rx.tap
            .subscribe { _ in
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        // 완료 버튼
        uploadButton.rx.tap
            .subscribe { _ in
                self.view.addSubview(self.loadingView)
                self.uploadAlbum()
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
        
        // 데이트 피커
        expireDatePicker.addTarget(self, action: #selector(expireDateChanged(_:)), for: .valueChanged)
    }
    
    func bind() {
        uploadAlbumDone
            .subscribe { _ in
                self.loadingView.removeFromSuperview()
                self.showUploadFinishedAlert()
            }
            .disposed(by: disposeBag)
    }
    
    @objc func expireDateChanged(_ datePicker: UIDatePicker) {
        expireTime = datePicker.date
        let region = Region(calendar: Calendars.gregorian, zone: Zones.asiaSeoul, locale: Locales.korean)
        let now = DateInRegion(region: region)
        let expirationDate = DateInRegion(expireTime, region: region)
        /// 만료 날짜까지 남은 전체 시간을 시간 단위로 계산
        let totalHoursLeft: Int64 = now.getInterval(toDate: expirationDate, component: .hour)
        let daysLeft = totalHoursLeft / 24 // 일수
        let hoursLeft = totalHoursLeft % 24 // 남은 시간
        leftTimeLabel.text = "\(daysLeft)일 \(hoursLeft)시간 후"
    }
    
}

// MARK: - 파이어베이스 업로드
extension UploadViewController {
    
    func uploadAlbum() {
        print("\(type(of: self)) - \(#function)")
        
        uploadAlbumDocToFireStore { albumDocID in
            self.uploadImagesToStorage(albumDocID: albumDocID) {
                print("\(#function) 성공")
                self.uploadAlbumDone.onNext(())
            }
        }
    }
    
    /// AlbumModel을 FireStore에 추가
    func uploadAlbumDocToFireStore(completion: @escaping (String) -> Void) {
        print("\(type(of: self)) - \(#function)")
        
        let expireTime = expireDatePicker.date
        let tags = [tagTextField.text ?? ""]
        let documentData = AlbumModel.createDictToUpload(expireTime: expireTime, imageCount: images.count, tags: tags)
        var ref: DocumentReference? = nil
        ref = albumCollection.addDocument(data: documentData) { err in
            if let err = err {
                print("\(#function) 실패: \(err)")
            } else {
                print("\(#function) 성공: \(ref!.documentID)")
                completion(ref!.documentID)
            }
        }
    }
    
    /// 이미지를 Storage에 업로드
    func uploadImagesToStorage(albumDocID: String, completion: @escaping () -> Void) {
        print("\(type(of: self)) - \(#function)")
        
        // asdfsaf/0
        let albumImagesRef = Storage.storage().reference().child(albumDocID)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let uploadGroup = DispatchGroup()
        print("images.count:", images.count)
        for imageIdx in 0..<images.count {
            let uploadRef = albumImagesRef.child("\(imageIdx).jpeg")
            if let imageData = images[imageIdx].jpegData(compressionQuality: 0.8) {
                uploadGroup.enter()
                uploadRef.putData(imageData, metadata: metadata) { metadata, error in
                    uploadGroup.leave()
                }
            }
        }
        
        uploadGroup.notify(queue: .main) {
            completion()
        }
    }
    
}

// MARK: - CollectionView
extension UploadViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if images.indices.contains(indexPath.row) {
            let cell = selectedImageCollectionView.dequeueReusableCell(withReuseIdentifier: "SelectedImageCollectionViewCell", for: indexPath) as! SelectedImageCollectionViewCell
            cell.imageView.image = images[indexPath.row]
            
            cell.deleteButton.rx.tap
                .subscribe { _ in
                    self.images.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self.selectedImageCollectionView.reloadData()
                    }
                }
                .disposed(by: cell.disposeBag)
            
            return cell
        } else {
            let cell = selectedImageCollectionView.dequeueReusableCell(withReuseIdentifier: "AddImageCollectionViewCell", for: indexPath) as! AddImageCollectionViewCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? AddImageCollectionViewCell {
            presentPicker()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
         return section == 0 ? UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8) : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = selectedImageCollectionView.frame.height
        let itemsPerColumn: CGFloat = 1
        let heightPadding = sectionInsets.top * (itemsPerColumn + 1)
        let cellHeight = (height - heightPadding) / itemsPerColumn
        
        return CGSize(width: cellHeight, height: cellHeight)
    }

}

// MARK: - ScrollView
extension UploadViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
        self.view.endEditing(true)
    }
    
}

// MARK: - Alert
extension UploadViewController {

    func showUploadFinishedAlert() {
        let sheet = UIAlertController(title: "업로드 완료", message: "링크를 복사하시겠습니까?", preferredStyle: .alert)
        
        let loginAction = UIAlertAction(title: "링크 복사하고 창 닫기", style: .default, handler: { _ in
            UIPasteboard.general.url = self.albumURL
            self.dismiss(animated: true)
        })
        let cancelAction = UIAlertAction(title: "창 닫기", style: .cancel) { _ in
            self.dismiss(animated: true)
        }
        
        sheet.addAction(loginAction)
        sheet.addAction(cancelAction)
        
        present(sheet, animated: true)
    }
}

// MARK: - PHPickerViewController
extension UploadViewController: PHPickerViewControllerDelegate {
    
    func presentPicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let imagePicker = PHPickerViewController(configuration: config)
        imagePicker.delegate = self
        
        self.present(imagePicker, animated: true)
    }
    
    // TODO: for안의 코드가 다 돌았을 때 didFinishPickingDone하고 싶은데 loadObject도 비동기라 안됨
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let itemProviders = results.map(\.itemProvider)
        print(1)
        DispatchQueue.global().async {
            print(2)
            for itemProvider in itemProviders {
                print(3)
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    print(4)
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                        guard let self = self, let image = image as? UIImage else { return }
                        print(5)
                        // TODO: 이미지 일정크기 이하로 줄이는 함수
                        self.images.append(image)
                        DispatchQueue.main.async {
                            self.selectedImageCollectionView.reloadData()
                        }
                    }
                }
            }
            // 여기에 추가하고 싶음
            // self.didFinishPickingDone.onNext(())
        }
        picker.dismiss(animated: true)
    }
}

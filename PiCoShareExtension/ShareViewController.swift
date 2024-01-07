//
//  ShareViewController.swift
//  PiCoShareExtension
//
//  Created by 서정덕 on 11/19/23.
//

import UIKit
import RxSwift
import RxCocoa
import UniformTypeIdentifiers
import MobileCoreServices

class ShareViewController: UIViewController {
    
    /// 올린 포토의 URL
    var photoURL: URL?
    /// 공유된 이미지
    var images: [UIImage] = []
    
    let handleSharedFileDone = PublishSubject<Void>()
    let disposeBag = DisposeBag()
    
    let sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var inputTagStackView: UIStackView!
    @IBOutlet var inputTagTextField: UITextField!
    @IBOutlet var collectionViewStackView: UIStackView!
    @IBOutlet var selectedImageCollectionView: UICollectionView!
    @IBOutlet var expireDatePicker: UIDatePicker!
    @IBOutlet var expireAfterLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        handleSharedFile()
        action()
        bind()
    }
    
    func initUI() {
        // scrollView
        scrollView.delegate = self
        
        // inputTagStackView
        inputTagStackView.layer.cornerRadius = 4
        
        // collectionViewStackView
        collectionViewStackView.layer.cornerRadius = 4
        
        // selectedImageCollectionView
        selectedImageCollectionView.dataSource = self
        selectedImageCollectionView.delegate = self
        let selectedImageCollectionViewCell = UINib(nibName: "SelectedImageCollectionViewCell", bundle: nil)
        selectedImageCollectionView.register(selectedImageCollectionViewCell, forCellWithReuseIdentifier: "SelectedImageCollectionViewCell")
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        selectedImageCollectionView.collectionViewLayout = flowLayout
        
        // datePicker
        expireDatePicker.tintColor = highlightBlue
    }
    
    func action() {
        closeButton.rx.tap.subscribe { _ in
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
        .disposed(by: disposeBag)
        
        uploadButton.rx.tap
            .subscribe { _ in
                self.saveImageToDirectory(identifier: "image", image: self.images[0])
                let loadingView = LoadingIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                loadingView.guideMessage = "업로드 중..."
                self.view.addSubview(loadingView)
                // 비동기적으로 작업을 수행
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    // 3초 후에 로딩뷰를 제거하고 UI를 초기화하고 작업을 수행
                    loadingView.removeFromSuperview()
                    self.showUploadFinishedAlert()
                }
                //file:///var/mobile/Containers/Data/PluginKitPlugin/C67FC341-4491-4C6C-B2D0-337C22697AAE/Documents/image.jpeg
                //file:///var/mobile/Containers/Data/Application/7AEFDA80-B2B0-4F97-BC52-B77641F52B4F/Documents/image.jpeg
            }
            .disposed(by: disposeBag)
    }
    
    func bind() {
        handleSharedFileDone.subscribe { _ in
            DispatchQueue.main.async {
                self.selectedImageCollectionView.reloadData()
            }
        }
        .disposed(by: disposeBag)
    }
    
    /// 공유 받은 사진 이미지 sharedImage에 저장
    func handleSharedFile() {
        // 첫 번째 확장 항목에서 item providers 추출
        guard let itemProviders = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments as? [NSItemProvider] else {
            return
        }
        
        // 첫 번째 item provider 가져오기
        guard let itemProvider = itemProviders.first else {
            return
        }
        
        // item provider가 UIImage를 로드할 수 있는지 확인
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            // item provider를 사용하여 UIImage 로드
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                guard let image = image as? UIImage else {
                    return
                }
                print(image)
                self.images.append(image)
                self.handleSharedFileDone.onNext(())
                print(self.images.count)
            }
        }
    }
    
    // TODO: 이미지 저장 안됨
    func saveImageToDirectory(identifier: String, image: UIImage) {
        // 저장할 디렉토리 경로 설정 (picturesDirectory, cachesDirectory도 존재하지만 Realm과 같은 경로에 저장하기 위해서 documentDirectory 사용함.)
        // userDomainMask: 사용자 홈 디렉토리는 사용자 관련 파일이 저장되는 곳입니다.
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory,in: .userDomainMask).first!
        // Realm에서 이미지에 사용될 이름인 identifier를 저장 후, 사용하면 됩니다
        let imageName = "\(identifier)"
        // 이미지의 경로 및 확장자 형식 (conformingTo: 확장자)
        let fileURL = documentsDirectory.appendingPathComponent(imageName, conformingTo: .jpeg)
        
        // Directory 경로라고 했죠? 파일이 저장된 위치를 확인하고 싶을 때, 단순히 경로를 프린트해서 확인이 가능합니다.
        print(fileURL)
        
        do {
            // 파일로 저장하기 위해선 data 타입으로 변환이 필요합니다. (JPEG은 압축을 해주므로 크기가 줄어듭니다. PNG는 비손실)
            if let imageData = image.jpegData(compressionQuality: 1) {
                // 이미지 데이터를 fileURL의 경로에 저장시킵니다.
                try imageData.write(to: fileURL)
                print("Image saved at: \(fileURL)")
            }
        } catch {
            print("Failed to save images: \(error)")
        }
    }

}

extension ShareViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
// MARK: CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("numberOfItemsInSection: \(images.count)")
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cellForItemAt: \(images.count)")
        let cell = selectedImageCollectionView.dequeueReusableCell(withReuseIdentifier: "SelectedImageCollectionViewCell", for: indexPath) as! SelectedImageCollectionViewCell
        cell.imageView.image = images[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
         return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = selectedImageCollectionView.frame.height
        let itemsPerColumn: CGFloat = 1
        let heightPadding = sectionInsets.top * (itemsPerColumn + 1)
        let cellHeight = (height - heightPadding) / itemsPerColumn
        
        return CGSize(width: cellHeight, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}

extension ShareViewController: UIScrollViewDelegate {
// MARK: ScrollView
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
        self.view.endEditing(true)
    }
    
}

extension ShareViewController {
// MARK: Alert
    
    func showUploadFinishedAlert() {
        let sheet = UIAlertController(title: "업로드 완료", message: "링크를 복사하시겠습니까?", preferredStyle: .alert)
        let loginAction = UIAlertAction(title: "링크 복사하고 창 닫기", style: .default, handler: { _ in
            UIPasteboard.general.url = self.photoURL
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        })
        let cancelAction = UIAlertAction(title: "창 닫기", style: .cancel) { _ in
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
        
        sheet.addAction(loginAction)
        sheet.addAction(cancelAction)
        
        present(sheet, animated: true)
    }

}

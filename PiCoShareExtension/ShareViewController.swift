//
//  ShareViewController.swift
//  PiCoShareExtension
//
//  Created by 서정덕 on 11/19/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxKeyboard
import UniformTypeIdentifiers
import MobileCoreServices
import SnapKit
import SwiftDate
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ShareViewController: UIViewController {
    
    let uploadVM = UploadViewModel()
    private var keyboardHeight: CGFloat = 0

    /// 올린 포토의 URL
    var photoURL: URL?
    /// 공유된 이미지
    var images: [UIImage] = []
    
    let disposeBag = DisposeBag()
    
    let sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var tagStackView: UIStackView!
    @IBOutlet var tagTextField: UITextField!
    @IBOutlet var tagsCollectionView: UICollectionView!
    @IBOutlet var collectionViewStackView: UIStackView!
    @IBOutlet var selectedImageCollectionView: UICollectionView!
    @IBOutlet var expireDatePicker: UIDatePicker!
    @IBOutlet var expireAfterLabel: UILabel!
    @IBOutlet var keyboardToolContainerView: UIView!
    @IBOutlet var hideKeyboardButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Hello")
        
        initFirebase()
        showToast(message: "ㅇ", keyboardHeight: 0)
        initUI()
        handleSharedFile()
        action()
        bind()
    }
    
    func initUI() {
        // scrollView
        scrollView.delegate = self
        
        // inputTagStackView
        tagStackView.layer.cornerRadius = 4
        
        // tagTextField
        tagTextField.delegate = self
        
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
        expireDatePicker.tintColor = ColorManager.shared.highlightBlue
    }
    
    func action() {
        closeButton.rx.tap
            .subscribe { _ in
                self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            }
            .disposed(by: disposeBag)
        
        uploadButton.rx.tap
            .subscribe { _ in
                let loadingView = LoadingIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                self.view.addSubview(loadingView)
                // TODO: 사진 업로드 로직
            }
            .disposed(by: disposeBag)
        
        // 키보드 툴바
        RxKeyboard.instance.visibleHeight
            .skip(1)
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let strongSelf = self else {
                    return
                }
                print("keyboardVisibleHeight", keyboardVisibleHeight)
                strongSelf.keyboardHeight = keyboardVisibleHeight
                UIView.animate(withDuration: 0, delay: 0, options: .curveEaseInOut, animations: {
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
    }
    
    func bind() {

    }
    
    func initFirebase() {
        var googleServiceFileName = Bundle.main.bundleIdentifier == PiCoConstants.shareExDevBundleID ? PiCoConstants.devPList : PiCoConstants.productionPList
        
        if let filePath = Bundle.main.path(forResource: googleServiceFileName, ofType: "plist") {
            if let options = FirebaseOptions(contentsOfFile: filePath) {
                FirebaseApp.configure(options: options)
            }
        }
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
                self.selectedImageCollectionView.reloadData()
                print(self.images.count)
            }
        }
    }

}

// MARK: - CollectionView
extension ShareViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = selectedImageCollectionView.frame.height
        let itemsPerColumn: CGFloat = 1
        let heightPadding = sectionInsets.top * (itemsPerColumn + 1)
        let cellHeight = (height - heightPadding) / itemsPerColumn
        
        return CGSize(width: cellHeight, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
         return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch collectionView {
        case tagsCollectionView:
            return 8
            
        case selectedImageCollectionView:
            return 8
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch collectionView {
        case tagsCollectionView:
            return 8
            
        case selectedImageCollectionView:
            return 8
            
        default:
            return 0
        }
    }
}

// MARK: - ScrollView
extension ShareViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
        self.view.endEditing(true)
    }
    
}

// MARK: - TextField
extension ShareViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("\(type(of: self)) - \(#function)")
        
        // 리턴버튼 눌렀을때 작동
        guard let newTag = tagTextField.text, newTag != "" else {
            return true
        }
        var currentTags = uploadVM.tags.value
        currentTags.append(newTag)
        uploadVM.tags.accept(currentTags)
        tagTextField.text = ""
        view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("\(type(of: self)) - \(#function)")
        
        // 공백 입력시 태그 추가
        if string == " " && !textField.text!.isEmpty {
            var currentTags = uploadVM.tags.value
            currentTags.append(textField.text!)
            uploadVM.tags.accept(currentTags)
            tagTextField.text = ""
            return false
        }
        return true
    }
    
}

// MARK: - Alert
extension ShareViewController {
    
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

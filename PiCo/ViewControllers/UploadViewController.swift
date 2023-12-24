//
//  UploadViewController.swift
//  PiCo
//
//  Created by 서정덕 on 11/19/23.
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

class UploadViewController: UIViewController {
    
    let uploadVM = UploadViewModel()
    
    
    let disposeBag = DisposeBag()
    
    lazy var loadingView = LoadingIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
    let sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

    @IBOutlet var closeButton: UIButton!
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var inputTagStackView: UIStackView!
    @IBOutlet var tagTextField: UITextField!
    @IBOutlet var tagsCollectionView: UICollectionView!
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
    }
    
    func initUI() {
        // 태그 스택뷰
        inputTagStackView.layer.cornerRadius = 4
        
        // tagTextField
        tagTextField.delegate = self
        
        // datePicker
        expireDatePicker.tintColor = UIColor(named: "HighlightBlue")
        
        // scrollView
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        
        // tagsCollectionView
        tagsCollectionView.dataSource = self
        tagsCollectionView.delegate = self
        let tagsCollectionViewCell = UINib(nibName: "TagsCollectionViewCell", bundle: nil)
        tagsCollectionView.register(tagsCollectionViewCell, forCellWithReuseIdentifier: "TagsCollectionViewCell")
        let tagsFlowLayout = UICollectionViewFlowLayout()
        tagsFlowLayout.scrollDirection = .horizontal
        tagsCollectionView.collectionViewLayout = tagsFlowLayout
        tagsCollectionView.alwaysBounceHorizontal = true
        tagsCollectionView.isHidden = true

        // selectedImageCollectionView
        selectedImageCollectionView.dataSource = self
        selectedImageCollectionView.delegate = self
        let selectedImageCollectionViewCell = UINib(nibName: "SelectedImageCollectionViewCell", bundle: nil)
        selectedImageCollectionView.register(selectedImageCollectionViewCell, forCellWithReuseIdentifier: "SelectedImageCollectionViewCell")
        let addImageCollectionViewCell = UINib(nibName: "AddImageCollectionViewCell", bundle: nil)
        selectedImageCollectionView.register(addImageCollectionViewCell, forCellWithReuseIdentifier: "AddImageCollectionViewCell")
        let selectedImageFlowLayout = UICollectionViewFlowLayout()
        selectedImageFlowLayout.scrollDirection = .horizontal
        selectedImageCollectionView.collectionViewLayout = selectedImageFlowLayout
        selectedImageCollectionView.alwaysBounceHorizontal = true

        // collectionViewStackView
        collectionViewStackView.layer.cornerRadius = 4
    }
    
    func initData() {
        // datePicker
        expireDatePicker.date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
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
                self.uploadVM.uploadAlbum()
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
        
        // 데이트 피커
        expireDatePicker.addTarget(self, action: #selector(expireDateChanged(_:)), for: .valueChanged)
    }
    
    /// uploadVM.expireTime, leftTimeLabel 업데이트
    @objc func expireDateChanged(_ datePicker: UIDatePicker) {
        uploadVM.expireTime = datePicker.date
        let region = Region(calendar: Calendars.gregorian, zone: Zones.asiaSeoul, locale: Locales.korean)
        let now = DateInRegion(region: region)
        let expirationDate = DateInRegion(uploadVM.expireTime, region: region)
        /// 만료 날짜까지 남은 전체 시간을 시간 단위로 계산
        let totalHoursLeft: Int64 = now.getInterval(toDate: expirationDate, component: .hour)
        let daysLeft = totalHoursLeft / 24 // 일수
        let hoursLeft = totalHoursLeft % 24 // 남은 시간
        leftTimeLabel.text = "\(daysLeft)일 \(hoursLeft)시간 후"
    }
    
    func bind() {
        uploadVM.uploadAlbumDone
            .subscribe { _ in
                self.loadingView.removeFromSuperview()
                self.showUploadFinishedAlert()
            }
            .disposed(by: disposeBag)
        
        uploadVM.tags.asObservable()
            .subscribe { updatedTags in
                guard let tagsArray = updatedTags.element else {
                    return
                }
                self.tagsCollectionView.reloadData()
                if tagsArray.count == 0 {
                    UIView.animate(withDuration: 0.1, animations: {
                        self.tagsCollectionView.isHidden = true
                    })
                } else {
                    UIView.animate(withDuration: 0.1, animations: {
                        self.tagsCollectionView.isHidden = false
                    })
                }
            }
            .disposed(by: disposeBag)
    }
    
}

// MARK: - CollectionView
extension UploadViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case tagsCollectionView:
            return uploadVM.tags.value.count
        case selectedImageCollectionView:
            return 1
        default:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case tagsCollectionView:
            let cell = tagsCollectionView.dequeueReusableCell(withReuseIdentifier: "TagsCollectionViewCell", for: indexPath) as! TagsCollectionViewCell
            cell.tagTextField.text = uploadVM.tags.value[indexPath.row]
            
            cell.deleteTagButton.rx.tap
                .subscribe { _ in
                    var newTags = self.uploadVM.tags.value
                    newTags.remove(at: indexPath.row)
                    self.uploadVM.tags.accept(newTags)
                }
                .disposed(by: cell.disposeBag)
            
            return cell
            
        case selectedImageCollectionView:
            if uploadVM.images.indices.contains(indexPath.row) {
                let cell = selectedImageCollectionView.dequeueReusableCell(withReuseIdentifier: "SelectedImageCollectionViewCell", for: indexPath) as! SelectedImageCollectionViewCell
                cell.imageView.image = uploadVM.images[indexPath.row]
                
                cell.deleteButton.rx.tap
                    .subscribe { _ in
                        self.uploadVM.images.remove(at: indexPath.row)
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
            
        default:
            return AddImageCollectionViewCell()
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case tagsCollectionView:
            return
        case selectedImageCollectionView:
            // + 버튼일때 이미지 선택
            if collectionView.cellForItem(at: indexPath) is AddImageCollectionViewCell {
                presentPicker()
            }
        default:
            return
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch collectionView {
        case tagsCollectionView:
            return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            
        case selectedImageCollectionView:
            return section == 0 ? UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8) : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
            
        default:
            return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        }
         
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case tagsCollectionView:
            let label = UILabel()
            label.text = uploadVM.tags.value[indexPath.row]
            label.font = .systemFont(ofSize: 14)
            label.sizeToFit()
            let cellHeight = tagsCollectionView.frame.height // 셀의 높이 설정
            let cellWidth = label.frame.width + 52

            return CGSize(width: cellWidth, height: cellHeight)
        case selectedImageCollectionView:
            let height = selectedImageCollectionView.frame.height
            let itemsPerColumn: CGFloat = 1
            let heightPadding = sectionInsets.top * (itemsPerColumn + 1)
            let cellHeight = (height - heightPadding) / itemsPerColumn
            
            return CGSize(width: cellHeight, height: cellHeight)
        default:
            return .zero
        }

    }

}

// MARK: - ScrollView
extension UploadViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
        self.view.endEditing(true)
    }
    
}

// MARK: - TextField
extension UploadViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let newTag = tagTextField.text, newTag != "" else {
            return true
        }
        var currentTags = uploadVM.tags.value
        currentTags.append(newTag)
        uploadVM.tags.accept(currentTags)
        tagTextField.text = ""
        return true
    }
    
}

// MARK: - Alert
extension UploadViewController {

    func showUploadFinishedAlert() {
        let sheet = UIAlertController(title: "업로드 완료", message: "링크를 복사하시겠습니까?", preferredStyle: .alert)
        
        let loginAction = UIAlertAction(title: "링크 복사하고 창 닫기", style: .default, handler: { _ in
            UIPasteboard.general.url = self.uploadVM.albumURL
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
                        self.uploadVM.images.append(image)
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

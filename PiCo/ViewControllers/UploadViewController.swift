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

class UploadViewController: UIViewController {
    
    /// 서버에 저장된 사진 URL
    var albumURL: URL?
    /// 선택한 사진 배열
    var images: [UIImage] = []
    var expireTime = Date()
    
    let didFinishPickingDone = PublishSubject<Void>()
    let removeImagesAtDone = PublishSubject<Void>()
    let disposeBag = DisposeBag()
    
    let sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

    @IBOutlet var closeButton: UIButton!
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var inputTagStackView: UIStackView!
    @IBOutlet var collectionViewStackView: UIStackView!
    @IBOutlet var selectedImageCollectionView: UICollectionView!
    @IBOutlet var expireDatePicker: UIDatePicker!
    @IBOutlet var leftTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
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
        var dateComponents = DateComponents()
        dateComponents.month = 1 // 1달 후까지의 범위 설정
        let maxDate = Calendar.current.date(byAdding: dateComponents, to: Date())
        // 현재부터 한달 뒤 까지 선택 가능하게 설정
        expireDatePicker.minimumDate = Date()
        expireDatePicker.maximumDate = maxDate
        
        // scrollView
        scrollView.delegate = self
        
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
        
        // collectionViewStackView
        collectionViewStackView.layer.cornerRadius = 4
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
                let loadingView = LoadingIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                self.view.addSubview(loadingView)
                // TODO: 서버 업로드 성공 subscibe 하도록 변경
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    loadingView.removeFromSuperview()
                    self.showUploadFinishedAlert()
                }
            }
            .disposed(by: disposeBag)
        
        // TODO: 질문 RxKeyboard 적용 안됨
        RxKeyboard.instance.visibleHeight
            .skip(1)
            .drive(onNext: { keyboardVisibleHeight in
                print("rx키보드")
                print(keyboardVisibleHeight)  // 346.0
                self.scrollView.snp.updateConstraints { make in
                    UIView.animate(withDuration: 1) {
                        make.bottom.equalToSuperview().inset(keyboardVisibleHeight)
                        print(self.scrollView.frame)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // 데이트 피커
        expireDatePicker.addTarget(self, action: #selector(expireDateChanged(_:)), for: .valueChanged)

    }
    
    func bind() {
        didFinishPickingDone.subscribe { _ in
            print("didFinishPickingDone")
            print(self.images.count)
            DispatchQueue.main.async {
                self.selectedImageCollectionView.reloadData()
            }
        }
        .disposed(by: disposeBag)
        
        removeImagesAtDone.subscribe { _ in
            DispatchQueue.main.async {
                self.selectedImageCollectionView.reloadData()
            }
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
                    self.removeImagesAtDone.onNext(())
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
                        self.images.append(image)
                        self.didFinishPickingDone.onNext(())
                    }
                }
            }
            // 여기에 추가하고 싶음
            // self.didFinishPickingDone.onNext(())
        }
        picker.dismiss(animated: true)
    }
}

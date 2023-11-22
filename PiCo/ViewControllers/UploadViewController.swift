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

class UploadViewController: UIViewController {
    
    /// 서버에 저장된 사진 URL
    var postURL: URL?
    /// 선택한 사진 배열
    var images: [UIImage] = []
    
    let disposeBag = DisposeBag()
    
    let sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

    @IBOutlet var closeButton: UIButton!
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var inputTagStackView: UIStackView!
    @IBOutlet var collectionViewStackView: UIStackView!
    @IBOutlet var selectedImageCollectionView: UICollectionView!
    @IBOutlet var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        action()
        print(scrollView.frame)
    }
    
    func initUI() {
        // 태그 스택뷰
        inputTagStackView.layer.cornerRadius = 4
        
        // datePicker
        datePicker.tintColor = UIColor(named: "HighlightBlue")
        
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
        closeButton.rx.tap
            .subscribe { _ in
            self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
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
    }
    
    func showUploadFinishedAlert() {
        let sheet = UIAlertController(title: "업로드 완료", message: "링크를 복사하시겠습니까?", preferredStyle: .alert)
        
        let loginAction = UIAlertAction(title: "링크 복사하고 창 닫기", style: .default, handler: { _ in
            UIPasteboard.general.url = self.postURL
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

extension UploadViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < images.count {
            let cell = selectedImageCollectionView.dequeueReusableCell(withReuseIdentifier: "SelectedImageCollectionViewCell", for: indexPath) as! SelectedImageCollectionViewCell
            return cell
        } else {
            let cell = selectedImageCollectionView.dequeueReusableCell(withReuseIdentifier: "AddImageCollectionViewCell", for: indexPath) as! AddImageCollectionViewCell
            return cell
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row <= images.count {
            // 사진 선택
            print("사진 선택")
        } else {
            
        }
    }
}

extension UploadViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){ 
        self.view.endEditing(true)
    }
    
}

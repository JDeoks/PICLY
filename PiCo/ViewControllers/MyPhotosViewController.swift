//
//  MyPhotosViewController.swift
//  PiCo
//
//  Created by 서정덕 on 11/18/23.
//

import UIKit
import RxSwift
import RxCocoa

class MyPhotosViewController: UIViewController {
    
    let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    @IBOutlet var titleStackView: UIStackView!
    @IBOutlet var searchTagStackView: UIStackView!
    @IBOutlet var searchTagTextField: UITextField!
    @IBOutlet var searchCancelButton: UIButton!
    @IBOutlet var myPhotosCollectionView: UICollectionView!
    
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        action()
    }
    
    func initUI() {
        // 검색 바
        searchTagStackView.layer.cornerRadius = 4
        searchTagTextField.delegate = self
        searchCancelButton.isHidden = true
        
        // 내비게이션
        self.navigationController?.isNavigationBarHidden = true
        
        // myPhotosCollectionView
        myPhotosCollectionView.dataSource = self
        myPhotosCollectionView.delegate = self
        let myPhotosCollectionViewCell = UINib(nibName: "MyPhotosCollectionViewCell", bundle: nil)
        myPhotosCollectionView.register(myPhotosCollectionViewCell, forCellWithReuseIdentifier: "MyPhotosCollectionViewCell")
        myPhotosCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
    }
    
    func action() {
        searchCancelButton.rx.tap
            .subscribe { _ in
                self.searchCancelButton.isHidden = true
                self.searchTagTextField.text = ""
                self.searchTagTextField.resignFirstResponder()
                UIView.animate(withDuration: 0.1 ,animations: {
                    self.titleStackView.isHidden = false
                })
            }
            .disposed(by: disposeBag)
    }

}

extension MyPhotosViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.searchCancelButton.isHidden = false
        UIView.animate(withDuration: 0.1, animations: {
            self.titleStackView.isHidden = true
        })
    }
    
}

extension MyPhotosViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 48
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = myPhotosCollectionView.dequeueReusableCell(withReuseIdentifier: "MyPhotosCollectionViewCell", for: indexPath) as! MyPhotosCollectionViewCell
        print("d")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        let itemsPerRow: CGFloat = 2
        let widthPadding = sectionInsets.left * (itemsPerRow + 1)
        let itemsPerColumn: CGFloat = 2.5
        let heightPadding = sectionInsets.top * (itemsPerColumn + 1)
        let cellWidth = (width - widthPadding) / itemsPerRow
        let cellHeight = (height - heightPadding) / itemsPerColumn
        
        return CGSize(width: cellWidth, height: cellWidth * 1.4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return sectionInsets
        }
        
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return sectionInsets.left
//    }
    
}

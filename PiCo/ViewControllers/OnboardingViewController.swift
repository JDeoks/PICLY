//
//  OnboardingViewController.swift
//  PiCo
//
//  Created by JDeoks on 1/8/24.
//

import UIKit
import RxSwift
import RxSwift
import RxRelay

class OnboardingViewController: UIViewController {
    
    // TODO: OnboardingDataModel 추가
    let onboardingDatas =  [3, 3, 4, 52, 2]
    
    let currentPageIndex = BehaviorRelay<Int>(value: 0)
    let disposeBag = DisposeBag()

    @IBOutlet var skipButton: UIButton!
    @IBOutlet var onboardingCollectionView: UICollectionView!
    @IBOutlet var onboardingPageControl: UIPageControl!
    @IBOutlet var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initData()
        action()
        bind()
    }
    
    func initUI() {
        // skipButton
        let attributedString = NSMutableAttributedString(string: skipButton.titleLabel?.text ?? "")
        attributedString.addAttribute(
            NSAttributedString.Key.underlineStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: NSRange(location: 0, length: attributedString.length)
        )
        let font = UIFont.systemFont(ofSize: 14)
        attributedString.addAttribute(
            NSAttributedString.Key.font,
            value: font,
            range: NSRange(location: 0, length: attributedString.length)
        )
        skipButton.setAttributedTitle(attributedString, for: .normal)
        
        // onboardingCollectionView
        onboardingCollectionView.dataSource = self
        onboardingCollectionView.delegate = self
        let onboardingCollectionViewCell = UINib(nibName: "OnboardingCollectionViewCell", bundle: nil)
        onboardingCollectionView.register(onboardingCollectionViewCell, forCellWithReuseIdentifier: "OnboardingCollectionViewCell")
        let onboardingFlowLayout = UICollectionViewFlowLayout()
        onboardingFlowLayout.scrollDirection = .horizontal
        onboardingCollectionView.isPagingEnabled = true
        
        // onboardingPageControl
        onboardingPageControl.currentPageIndicatorTintColor = mainText
        onboardingPageControl.pageIndicatorTintColor = secondText

        // nextButton
        nextButton.layer.cornerRadius = 4
    }
    
    func initData() {
        // onboardingPageControl
        onboardingPageControl.numberOfPages = onboardingDatas.count
    }
    
    func action() {
        skipButton.rx.tap
            .subscribe { _ in
                HapticManager.shared.triggerImpact()
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)

        nextButton.rx.tap
            .subscribe { _ in
                HapticManager.shared.triggerImpact()
                // 시작 버튼 클릭
                let endIdx = self.onboardingDatas.count - 1
                if self.currentPageIndex.value < endIdx {
                    self.currentPageIndex.accept(self.currentPageIndex.value + 1)
                } else {
                    self.dismiss(animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        onboardingPageControl.addTarget(self, action: #selector(pageControlChanged(_:)), for: .valueChanged)
    }
    
    @objc func pageControlChanged(_ sender: UIPageControl) {
        currentPageIndex.accept(sender.currentPage)
    }
    
    func bind() {
        currentPageIndex
            .subscribe { newPageIndex in
                self.pageIndexChanged(newPageIndex: newPageIndex)
            }
            .disposed(by: disposeBag)
    }
    
    func pageIndexChanged(newPageIndex idx: Int) {
        print("\(type(of: self)) - \(#function)", idx)

        // onboardingPageControl
        onboardingPageControl.currentPage = idx
        // onboardingCollectionView
        let indexPath = IndexPath(item: idx, section: 0)
        onboardingCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        // nextButton
        let endIdx = self.onboardingDatas.count - 1
        if idx == endIdx {
            nextButton.setTitle("시작", for: .normal)
        } else {
            nextButton.setTitle("다음", for: .normal)
        }
    }

}

// MARK: - UICollectionView, UIScrollView
extension OnboardingViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onboardingDatas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = onboardingCollectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCollectionViewCell", for: indexPath) as! OnboardingCollectionViewCell
        if indexPath.row  == 1{
            cell.backgroundColor = .blue
        }
        if indexPath.row  == 2{
            cell.backgroundColor = .gray
        }        
        if indexPath.row  == 3{
            cell.backgroundColor = .brown
        }
        if indexPath.row  == 4{
            cell.backgroundColor = .gray
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        
        return CGSize(width: width, height: height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        let newIndex = Int(scrollView.contentOffset.x / width)
        if currentPageIndex.value != newIndex {
            currentPageIndex.accept(newIndex)
        }
    }
    
}

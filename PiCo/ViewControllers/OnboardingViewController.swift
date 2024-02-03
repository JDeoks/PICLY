//
//  OnboardingViewController.swift
//  PiCo
//
//  Created by JDeoks on 1/8/24.
//

import UIKit
import RxSwift
import RxRelay

class OnboardingViewController: UIViewController {
    
    let onboardingDatas =  [
        ["손쉬운 익명 사진 공유",
         "onboarding1",
         "PiCo는 사진을 빠르고 안전하게 공유하는\n새로운 방법입니다.\n\n앨범 단위로 사진을 업로드하고,\n링크를 통해 익명으로 손쉽게 공유하세요."
        ],
        ["익명성 보장",
         "onboarding2",
         "공유된 링크를 통해 앨범에 접속한 사용자는\n작성자의 정보를 확인할 수 없습니다.\n\n나를 밝히지 않고 사진을 전달하고 싶다면,\nPiCo가 최적의 선택지입니다."
        ],
        ["자동으로 만료되는 앨범", 
         "onboarding3",
         "앨범을 게시할 때 앨범의 만료시간을 설정할 수 있습니다.\n만료시간 이후에는 본인만 앨범을 확인할 수 있습니다.\n\n이제는 더욱 편하게 앨범을 관리하세요."]
    ]
    
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
        print("onboardingCollectionView", onboardingCollectionView.frame.size)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let flowLayout = onboardingCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        // 현재 뷰의 크기에 맞게 셀 크기 조정
        flowLayout.itemSize = onboardingCollectionView.bounds.size
        // 레이아웃을 무효화하고 갱신
        flowLayout.invalidateLayout()
        // 레이아웃 변경사항즉시 업데이트
        onboardingCollectionView.layoutIfNeeded()
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
        onboardingCollectionView.collectionViewLayout = onboardingFlowLayout
        onboardingCollectionView.isPagingEnabled = true
        
        // onboardingPageControl
        onboardingPageControl.currentPageIndicatorTintColor = ColorManager.shared.mainText
        onboardingPageControl.pageIndicatorTintColor = ColorManager.shared.secondText

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
            nextButton.setTitle("시작하기", for: .normal)
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
        cell.onboardingtitleLabel.text = onboardingDatas[indexPath.row][0]
        cell.onboardingImageView.image = UIImage(named: onboardingDatas[indexPath.row][1])
        cell.onboardingDescLabel.text = onboardingDatas[indexPath.row][2]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        let newIndex = Int(scrollView.contentOffset.x / width)
        if currentPageIndex.value != newIndex {
            currentPageIndex.accept(newIndex)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // 섹션 간의 수직 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // 섹션 내 아이템 간의 수평 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

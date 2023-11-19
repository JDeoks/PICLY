//
//  ShareViewController.swift
//  PiCoShareExtension
//
//  Created by 서정덕 on 11/19/23.
//

import UIKit
import UniformTypeIdentifiers
import MobileCoreServices

class ShareViewController: UIViewController {
    
    // 공유된 이미지
    var sharedImage: UIImage?
    
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var inputTagStackView: UIStackView!
    @IBOutlet var inputTagTextField: UITextField!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var expireDatePicker: UIDatePicker!
    @IBOutlet var expireAfterLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        handleSharedFile()
    }
    
    func initUI() {
        inputTagStackView.layer.cornerRadius = 4
        imageView.layer.cornerRadius = 4
    }
    
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
                
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
    }

}



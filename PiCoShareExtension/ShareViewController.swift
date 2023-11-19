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
        setData()
    }
    
    func initUI() {
        inputTagStackView.layer.cornerRadius = 4
        imageView.layer.cornerRadius = 4
    }
    
    func setData() {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
                return
            }

        for extensionItem in extensionItems {
            guard let itemProviders = extensionItem.attachments else {
                continue
            }

            for itemProvider in itemProviders {
                itemProvider.loadItem(forTypeIdentifier: UTType.propertyList.identifier as String) { result, error in
                    guard let resultImage = result as? UIImage else {
                        return
                    }

                    DispatchQueue.main.async {
                        print("hello")
                        self.imageView.image = resultImage
                    }
                }
            }
        }
    }

}

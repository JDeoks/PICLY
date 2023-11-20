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

class ShareViewController: ImageShareViewController {
    
    // 공유된 이미지
    var sharedImage: UIImage?
    
    let disposeBag = DisposeBag()
    
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
        action()
    }
    
    func initUI() {
        inputTagStackView.layer.cornerRadius = 4
        imageView.layer.cornerRadius = 4
    }
    
    func action() {
        uploadButton.rx.tap
            .subscribe { _ in
                self.saveImageToDirectory(identifier: "image", image: self.imageView.image!)
                self.showUploadFinishedAlert()
                //file:///var/mobile/Containers/Data/PluginKitPlugin/C67FC341-4491-4C6C-B2D0-337C22697AAE/Documents/image.jpeg
                //file:///var/mobile/Containers/Data/Application/7AEFDA80-B2B0-4F97-BC52-B77641F52B4F/Documents/image.jpeg
            }
            .disposed(by: disposeBag)
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



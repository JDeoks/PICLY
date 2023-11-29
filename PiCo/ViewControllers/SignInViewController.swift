//
//  SignInViewController.swift
//  PiCo
//
//  Created by 서정덕 on 11/30/23.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet var signInWithGoogleButtonView: UIView!
    @IBOutlet var signInWithAppleButtonView: UIView!
    @IBOutlet var googleLogoImageView: UIImageView!
    @IBOutlet var termsOfUseTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    func initUI() {
        // signInWithGoogleButtonView
        signInWithGoogleButtonView.layer.cornerRadius = 4
        
        // signInWithAppleButtonView
        signInWithAppleButtonView.layer.cornerRadius = 4
        
        // googleLogoImageView
        googleLogoImageView.layer.cornerRadius = 2
        
        // termsOfUseTextView
        let linkedText = NSMutableAttributedString(attributedString: termsOfUseTextView.attributedText)
        let termOfUseLink = linkedText.setAsLink(textToFind: "이용약관", linkURL: "https://jdeoks.notion.site/5cc8688a9432444eaad7a8fdc4e4e38a?pvs=4")
        let privacyPolicyLink = linkedText.setAsLink(textToFind: "개인정보처리방침", linkURL: "https://jdeoks.notion.site/bace573d0a294bdeae4a92464448bcac?pvs=4")
        if termOfUseLink || privacyPolicyLink {
            termsOfUseTextView.attributedText = NSAttributedString(attributedString: linkedText)
        }
    }

}

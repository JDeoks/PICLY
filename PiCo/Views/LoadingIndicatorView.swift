//
//  LoadingIndicatorView.swift
//  PiCo
//
//  Created by 서정덕 on 11/22/23.
//

import UIKit

class LoadingIndicatorView: UIView {
    
    var guideMessage = ""
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 0
        stackView.backgroundColor = UIColor(named: "TextFieldBackground")
        stackView.layer.opacity = 0.7
        stackView.layer.cornerRadius = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true  // 추가된 부분
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        return stackView
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = UIColor(named: "SecondText")
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    lazy var loadingLabel: UILabel = {
        let label = UILabel()
        label.text = guideMessage
        label.textColor = UIColor(named: "SecondText")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        stackView.addArrangedSubview(activityIndicator)
        stackView.addArrangedSubview(loadingLabel)
        addSubview(stackView)
        // 스택뷰의 제약조건을 설정합니다.
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
}

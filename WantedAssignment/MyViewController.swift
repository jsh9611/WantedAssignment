//
//  ViewController.swift
//  WantedAssignment
//
//  Created by SeongHoon Jang on 2023/02/23.
//

/*
 <설명>
 5개의 rowStackView와 1개의 loadAndClearAllImagesButton으로 구성된 View 입니다.
    1. Load를 누르면 해당하는 이미지를 불러올 수 있도록 했으며 한번 더 누르면 clear 하도록 했습니다.
    2. Load All Images를 누르면 모든 이미지를 불러오거나 초기화 합니다.
        - 만약 Load가 안된 이미지가 있다면 해당하는 이미지를 모두 Load 합니다.
        - 모든 이미지가 Load가 되었다면 모든 이미지를 Clear합니다.
    3. 이미지 URL은 picsum.photos 라는 sample image API를 사용했습니다.
 
 <질문>
 1. stackView(VStack)와 rowStackView(HStack)의 형태가 적절한가요?
    저는 viewDidLoad() 안에서 row를 만들었습니다.
    밖에서 row를 만들려고 했지만 값이 수정이 안되는 문제가 있어 viewDidLoad 안에 선언해서 만들었습니다.
    다른 좋은 방법이 있는지 궁금합니다.
 
 2. UIStackView vs UITableView
    저는 5개의 이미지만 불러오면 된다고 생각해서 UIStackView를 활용하려 했으나 어려움이 있었던 것 같습니다.
    비록 스크롤이나 cell 재사용을 하진 않지만 UITableView를 사용하는게 더 적절했을까요?
 
 <리뷰>
    저는 SwiftUI만 주로 써봐서 UIKit이 서툰 편입니다.
    특히 storyboard 없이 코드로만 작업 해본건 이번이 처음입니다.
    간단한 화면이지만 고민을 많이 하면서 코드를 짰던 것 같습니다.
 */

import UIKit

class MyViewController: UIViewController {
    
    //MARK: UI 관련 로직
    /// 어떤 이미지를 불러왔는지 체크할 때 사용
    private var loadedImages: [Int] = []
    
    /// rowStackView와 loadAllImagesButton을 담게 될 Vertical Stack View
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    /// 모든 이미지를 불러오거나 초기화하는 버튼
    private lazy var loadAndClearAllImagesButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Load All Images", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 9
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(loadAllImages), for: .touchUpInside)
        return button
    }()
    
    //MARK: View 생성
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View를 라이트 모드로 고정
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .systemBackground
        
        // stackView는 .vertical 형태로 view의 구성은 다음과 같습니다.
        // - 5개의 rowStackView(Image, progress, button)
        // - 1개의 loadAndClearAllImagesButton
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -32),
        ])
        
        // Image URL에서 path에 들어갈 부분
        // PATH:"\(tag)/120/80"
        let imageTags = [237, 230, 222, 257, 240]
        
        // 5개의 rowStackView를 생성
        for tag in imageTags {
            let imageView = UIImageView(image: UIImage(systemName: "photo"))
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
            
            let progressView = UIProgressView(progressViewStyle: .default)
            progressView.progress = 0.5
            
            let button = UIButton()
            button.backgroundColor = .systemBlue
            button.setTitle("Load", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 9
            button.layer.masksToBounds = true
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalToConstant: 80).isActive = true
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            button.tag = tag
            button.addTarget(self, action: #selector(loadAndClearImage(_:)), for: .touchUpInside)
            
            let rowStackView = UIStackView(arrangedSubviews: [imageView, progressView, button])
            rowStackView.axis = .horizontal
            rowStackView.spacing = 10
            rowStackView.alignment = .center

            // stackView에 image, progress, button으로 구성된 rowStackView를 추가
            stackView.addArrangedSubview(rowStackView)
        }
        
        // stackView에 loadAndClearAllImagesButton를 추가
        stackView.addArrangedSubview(loadAndClearAllImagesButton)
    }
    
    //MARK: 기능 관련 로직
    /// 이미지 한개를 불러오거나 지우는 action
    @objc func loadAndClearImage(_ sender: UIButton) {
        
        let imageTag = sender.tag
        
        // 불러온 이미지가 존재하는 경우 clear
        if let index = loadedImages.firstIndex(of: imageTag) {
            
            DispatchQueue.main.async {
                
                let image = UIImage(systemName: "photo")
                if let imageView = sender.superview?.subviews.first as? UIImageView {
                    imageView.image = image
                    self.loadedImages.remove(at: index)
                }
            }
            return
        }
        
        // 불러온 이미지가 존재하지 않는 경우 load
        if let url = URL(string: "https://picsum.photos/id/\(imageTag)/120/80") {
            
            // Data가 올바른 경우에만 이미지를 적용한다.
            // 데이터가 존재하는 경우에만 업데이트 한다.
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data,
                   let image = UIImage(data: data) {
                    
                    // UI Update를 위해 DispatchQueue.main.async 사용
                    DispatchQueue.main.async {
                        
                        // subviews의 첫 번째(imageView)에 불러온 데이터를 적용
                        if let imageView = sender.superview?.subviews.first as? UIImageView {
                            imageView.image = image
                            self.loadedImages.append(imageTag)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    /// 이미지를 모두 load 하거나, 모두 clear 하는 action
    ///
    /// 이미지를 덜 불러온 경우 모든 이미지를 불러오며 모든 이미지가 불러와졌다면 system Image로 초기화 한다.
    @objc func loadAllImages() {
        
        // 로드된 이미지가 0개 ~ 4개인 경우
        if loadedImages.count < 5 {
            loadImagesFromURLs()
            loadedImages = [237, 230, 222, 257, 240]
        } else {
            loadEmptyImages()
            loadedImages = []
        }
    }
    
    /// stackView 안에 있는 모든 rowStackView에 이미지를 Load
    ///
    /// 불러온 이미지가 0~4개 인 경우에 사용한다.
    private func loadImagesFromURLs() {
        
        // stackView 안을 순회하며 rowStackView를 찾는다
        for rowStackView in stackView.arrangedSubviews {
            
            // rowStackView에 UIImageView 가 존재하는 경우 Load 한 적이 없는 이미지만 Load 한다
            if let imageView = rowStackView.subviews.first as? UIImageView,
               let imageTag = imageView.superview?.subviews.last?.tag,
               !loadedImages.contains(imageTag) {
                
                guard let url = URL(string: "https://picsum.photos/id/\(imageTag)/120/80") else {
                    return
                }
                
                // Data를 정상적으로 불러왔다면 해당하는 superview(rowStackView)의 imageView를 업데이트 한다
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data,
                       let image = UIImage(data: data) {
                        
                        DispatchQueue.main.async {
                            imageView.image = image
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    /// stackView 안에 있는 모든 rowStackView에 이미지를 photo로 초기화
    ///
    /// 모든 이미지를 불러온 경우 사용한다.
    private func loadEmptyImages() {
        
        // stackView 안을 순회하며 rowStackView를 찾는다
        for rowStackView in stackView.arrangedSubviews {
            
            // 각각의 rowStackView의 imageView를 "photo"로 초기화한다
            if let imageView = rowStackView.subviews.first as? UIImageView {
                imageView.image = UIImage(systemName: "photo")
            }
        }
    }
}

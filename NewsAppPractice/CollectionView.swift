//
//  CollectionView.swift
//  NewsAppPractice
//
//  Created by Samuel Asamoah on 7/1/18.
//  Copyright © 2018 Samuel Asamoah. All rights reserved.
//

import UIKit

let currentDate = Date()
let headerTextStructure = [headerSetup(date: currentDate , day: "Today")]

class collectionView: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "CellId"
    let headerId = "HeaderId"
    var articles: [APIData]? = []
    let randomArray = ["a","b","c","d","e","f","g","h","i","j"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1)
        collectionView?.register(collectionViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(collectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
         newsView()
    }
    
    var data: String = {
        var text = ""
        return text
    }()
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.articles?.count)!
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! collectionViewCell
        data = (self.articles?[indexPath.item].articleWebsite)!
        let cellLiveImage = self.articles?[indexPath.item].articleImage
        let cellTextTitle = self.articles?[indexPath.item].articleTitle
        let cellTextDiscription = self.articles?[indexPath.item].articleDescription
        let attributedString = NSMutableAttributedString.init(string: cellTextTitle!)
        print(data)
        if (cellTextTitle?.characters.count)! > 60 {
            let index = cellTextDiscription?.index((cellTextDiscription?.startIndex)!, offsetBy: 60)
            let cellCutDiscription = String((cellTextDiscription?[...index!])!)
            attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 20), range: NSRange.init(location: 0, length: (cellTextTitle?.characters.count)!))
            attributedString.append(NSAttributedString(string: "\n\n\(cellCutDiscription)...", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.gray]))
            cell.textTitleContainer.attributedText = attributedString
            cell.Image.image = cellLiveImage
            
        } else {
            
        let index = cellTextDiscription?.index((cellTextDiscription?.startIndex)!, offsetBy: 70)
        let cellCutDiscription = String((cellTextDiscription?[...index!])!)
        attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 20), range: NSRange.init(location: 0, length: (cellTextTitle?.characters.count)!))
        attributedString.append(NSAttributedString(string: "\n\n\(cellCutDiscription)...", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        cell.textTitleContainer.attributedText = attributedString
        cell.Image.image = cellLiveImage
        }
        return cell

    }
    
    @objc func editButtonTapped() {
        
        let url = URL(string: self.data)
        UIApplication.shared.open(url!)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height * 0.66)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! collectionViewHeader
        headerView.backgroundColor = .clear
        let headerDate = headerTextStructure[indexPath.item].date
        let headerDay = headerTextStructure[indexPath.item].day
        let attributedString = NSMutableAttributedString.init(string: "\(headerDate)")
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 18), range: NSRange(location: 0, length: "\(headerDate)".count))
        attributedString.append(NSAttributedString(string: "\n\(headerDay)", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 45)]))
        headerView.textTitleContainer.attributedText = attributedString
        return headerView
    }
    
    func newsView() {
        guard let url = URL(string: "https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=9cae7ffdc5a14997b1400021e5d71b04") else {return}
        
        let urlSession = URLSession.shared
        urlSession.dataTask(with: url) { (Data, Response, Error) in
                     if let Data = Data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: Data, options: []) as? [String: Any] {
                        if let article = json["articles"] as? [[String: AnyObject]] {
                            for data in article {
                                let article = APIData()
                                if let author = data["author"] as? String, let title = data["title"] as? String, let description = data["description"] as? String, let urlToImage = data["urlToImage"] as? String, let articleWebsite = data["url"] as? String {
                                    article.articleWebsite = articleWebsite
                                    article.articleTitle = title
                                    article.articleDescription = description
                                    guard let url2 = URL(string: urlToImage) else {return}
                                    self.articles?.append(article)
                                    let sessionTwo = URLSession.shared
                                    sessionTwo.dataTask(with: url2 , completionHandler: { (Data, Responce, Error) in
                                        DispatchQueue.main.async { if let Data = Data {
                                            let dataImage = UIImage(data: Data)
                                            article.articleImage = dataImage
                                            }
                                        }
                                    }).resume()
                                    
                                    
                                }
                                
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                } catch {
                    print(Error!)
                }
                
            }
        
            }.resume()
        
    }
    
    }

class collectionViewHeader: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textTitleContainer)
        constraintsForCellHeaderText()
        backgroundColor = .clear
        textTitleContainer.textContainerInset = UIEdgeInsets.init(top: 21, left: 20, bottom: 0, right: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let textTitleContainer: UITextView = {
        let text = UITextView()
        text.textAlignment = .left
        text.backgroundColor = .clear
        text.isScrollEnabled = false
        text.isEditable = false
        text.isSelectable = false
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    func constraintsForCellHeaderText() {
        
        textTitleContainer.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textTitleContainer.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        textTitleContainer.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        textTitleContainer.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
}

class collectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(backgroundRect)
        backgroundRect.addSubview(Image)
        backgroundRect.addSubview(textTitleContainer)
        constraintsForCellTitleText()
        constraintsForCellImage()
        constraintsForCell()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 15)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 25
        backgroundRect.addSubview(Button)
        constraintsForCellButton()
    }
    
    
    let Button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(collectionView.self.editButtonTapped), for: UIControl.Event.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let textTitleContainer: UITextView = {
        let text = UITextView()
        text.textAlignment = .left
        text.backgroundColor = .white
        text.textContainerInset = UIEdgeInsets(top: 15, left: 10, bottom: 0, right: 0)
        text.isScrollEnabled = false
        text.isEditable = false
        text.isSelectable = false
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    let backgroundRect: UIView = {
        let rect = UIView()
        rect.clipsToBounds = true
        rect.translatesAutoresizingMaskIntoConstraints = false
        rect.backgroundColor = .white
        rect.layer.cornerRadius = 20
        return rect
    }()
    
    let Image: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func constraintsForCell() {
        
        backgroundRect.topAnchor.constraint(equalTo: topAnchor, constant : 20).isActive = true
        backgroundRect.bottomAnchor.constraint(equalTo: bottomAnchor, constant : -20).isActive = true
        backgroundRect.leftAnchor.constraint(equalTo: leftAnchor, constant : 30).isActive = true
        backgroundRect.rightAnchor.constraint(equalTo: rightAnchor, constant : -30).isActive = true
    }
    
    func constraintsForCellTitleText() {
        
        textTitleContainer.heightAnchor.constraint(equalToConstant: 170).isActive = true
        textTitleContainer.bottomAnchor.constraint(equalTo: backgroundRect.bottomAnchor).isActive = true
        textTitleContainer.leftAnchor.constraint(equalTo: backgroundRect.leftAnchor).isActive = true
        textTitleContainer.rightAnchor.constraint(equalTo: backgroundRect.rightAnchor).isActive = true
    }
    
    func constraintsForCellImage() {
        
        Image.heightAnchor.constraint(equalTo: backgroundRect.heightAnchor).isActive = true
        Image.bottomAnchor.constraint(equalTo: backgroundRect.bottomAnchor).isActive = true
        Image.leftAnchor.constraint(equalTo: backgroundRect.leftAnchor).isActive = true
        Image.rightAnchor.constraint(equalTo: backgroundRect.rightAnchor).isActive = true
    }
    
    func constraintsForCellButton() {
        
        Button.heightAnchor.constraint(equalTo: backgroundRect.heightAnchor).isActive = true
        Button.bottomAnchor.constraint(equalTo: backgroundRect.bottomAnchor).isActive = true
        Button.leftAnchor.constraint(equalTo: backgroundRect.leftAnchor).isActive = true
        Button.rightAnchor.constraint(equalTo: backgroundRect.rightAnchor).isActive = true
    }

}

//
//  ArticleViewController.swift
//  TinkoffNews
//
//  Created by Roman on 08/12/2019.
//  Copyright © 2019 Roman. All rights reserved.
//
import UIKit
class ArticleViewController: UIViewController {
    
    var articleText: String!
    var articleTitle: String!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = articleTitle
        if let attributedString = articleText.getNSAttributedString() {
            textView.attributedText = attributedString
        } else {
            textView.text = "Content error"
        }
        // Do any additional setup after loading the view.
    }
}

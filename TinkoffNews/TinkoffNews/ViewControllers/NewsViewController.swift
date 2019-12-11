//
//  NewsViewController.swift
//  TinkoffNews
//
//  Created by Roman on 08/12/2019.
//  Copyright © 2019 Roman. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class NewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var urlArticles = "https://cfg.tinkoff.ru/news/public/api/platform/v1/getArticles?pageSize=%d&pageOffset=%d"
    var urlArticleBySlug = "https://cfg.tinkoff.ru/news/public/api/platform/v1/getArticle?urlSlug=%@"
    
    let defaultPageSize = 20
    var currentPageOffset = 0
    var articles = [Article]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("oaded!!!")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        articles = DatabaseController.getAllArticles()
        if (articles.count == 0) {
            getDataToReloadTableView()
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("acticles count=\(articles.count)")
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = articles.count - 1
        if indexPath.row >= lastItem {
            print("!!!not enough cells!!! Row current=\(indexPath.row),last=\(lastItem)")
            getDataToReloadTableView()
            print("LoadCompleted. Articles=\(articles.count),offset=\(currentPageOffset)")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        
        let article = articles[indexPath.row]
        cell.textLabel?.text = article.title
        cell.detailTextLabel?.text = String(article.countOfRedirects)
        
        print("Now in \(indexPath.row) row, count=\(cell.detailTextLabel?.text ?? "nil")")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Clicking handlg...")
        tableView.deselectRow(at: indexPath, animated: true)
        print("Row \(indexPath.row) ws deselected")
        
        getDataToOpenArticle(article: articles[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("perform segue...")
        guard segue.identifier == "goToArticle" else {
             print("Segue data was not completed")
            return
        }
        if let  vc = segue.destination as? ArticleViewController, let article = sender as? Article {
            vc.articleText = article.text
            vc.articleTitle = article.title
        } else {
            print("Segue data was not inialized")
        }
    }
    
    func getDataToReloadTableView() {
        
        let url = String(format: urlArticles, defaultPageSize, currentPageOffset)
        getDataFromServer(url) { [weak self] (response) in
            if let mySelf = self {
                print("get articles from server")
                if let news = response.news {
                    let cachedArticles = DatabaseController.addArticlesIfNotExist(news)
                    mySelf.articles += cachedArticles
                    mySelf.reloadTableView()
                    mySelf.currentPageOffset = mySelf.articles.count + mySelf.defaultPageSize
                    return
                } else { print("News were not found. Incorrect response")}
            }
        }
    }
    
    func getDataToOpenArticle(article: Article) {
        guard let slug = article.slug else {
            print("Article has not  slug")
            return
        }
        let url = String(format: urlArticleBySlug, slug)

        getDataFromServer(url) { [weak self] (repsonse) in
            if let mySelf = self {
                print("trying to update  article...")
                article.countOfRedirects += 1
                article.text = repsonse.text
                print("Article was loaded with text:\(article.text)")
                DatabaseController.saveContext()
                mySelf.performArticleSegue(sender: article)
                
            }
        }
    }
    
    func performArticleSegue(sender: Article) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goToArticle", sender: sender)
        }
    }
    
    func getDataFromServer(_ url:String, completionHadler: @escaping (ResponseCodable) -> Void) {
        
        guard let myURL = URL(string: url) else {return}
        let urlRequest = URLRequest(url: myURL)
        print("Call dataTask")
        let task = URLSession.shared.dataTask(with: urlRequest) {
            (data, response, error) in
            guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            
            do {
                let json = try JSONDecoder().decode(RootCodable.self, from: dataResponse)
                completionHadler(json.response)
                print("Data task was completed")
            } catch {
                print("Response error: \(error)")
            }
        }
        
        task.resume()
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            print("table was reload. Page offset=\(self.currentPageOffset)")
        }
    }
}




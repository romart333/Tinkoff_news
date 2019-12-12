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
    var articles = [Article]()
    let articleSegueIndentifier = "goToArticle"
    
    let refreshControl: UIRefreshControl = {
        let myRefreshControl = UIRefreshControl()
        myRefreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return myRefreshControl
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = refreshControl

        articles = DatabaseController.getAllArticles()
        if (articles.count == 0) {
            getDataWithReloadingTableView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        DatabaseController.deleteAllArticles()
        articles.removeAll()
        self.reloadTableView()
        getDataToRequestRefreshing(sender: sender)
    }
        
    func getDataToRequestRefreshing(sender: UIRefreshControl) {
        
        let callback = { [unowned self] (mySender: UIRefreshControl) -> Void in
            self.endRefreshing(sender: mySender)
        }
        getDataWithReloadingTableView(completionHandler: (callback, sender))
    }
        
    func endRefreshing(sender: UIRefreshControl) {
        DispatchQueue.main.async {
            sender.endRefreshing()
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = articles.count - 1
        if indexPath.row >= lastItem {
            getDataWithReloadingTableView()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
      
        if cell == nil {
            cell =  UITableViewCell()
        }
        
        if (indexPath.row >= articles.count) {
            return cell!
        }
        let article = articles[indexPath.row]
        cell!.textLabel?.text = article.title
        cell!.detailTextLabel?.text = String(article.countOfRedirects)
        cell!.textLabel?.numberOfLines = 0
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        getDataWithOpeningArticle(index: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == articleSegueIndentifier else {
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
    
    func getDataWithReloadingTableView(completionHandler: (((UIRefreshControl) -> Void), sender: UIRefreshControl)? = nil) {
        
        let url = String(format: urlArticles, defaultPageSize, articles.count)
        
        getDataFromServer(url) { [unowned self] (response) in
        
            if let total = response.total {
                if self.articles.count >= total {
                    // Reach the end of data
                    return
                }
            }
            
            if let news = response.news {
                let cachedArticles = DatabaseController.addArticlesIfNotExist(news)
                self.articles += cachedArticles
                self.reloadTableView()
                if let callback = completionHandler {
                    callback.0(callback.sender)
                }
            } else {
                print("Error: News were not found. Incorrect response")
                
            }
        }
    }
    
    func getDataWithOpeningArticle(index: Int) {
        guard let slug = articles[index].slug else {
            print("Article has not slug")
            return
        }
        
        let url = String(format: urlArticleBySlug, slug)
        if let text = articles[index].text {
            performArticleSegueWithUpdatingDB(articleIndex: index, text: text)
            return
        }
        
        getDataFromServer(url) { [unowned self] (response) in
            self.performArticleSegueWithUpdatingDB(articleIndex: index, text: response.text ?? "Content was not loaded")
        }
    }
    
    func performArticleSegueWithUpdatingDB(articleIndex: Int, text: String) {
        
        articles[articleIndex].countOfRedirects += 1
        articles[articleIndex].text = text
        DatabaseController.saveContext()
        
        performArticleSegue(sender: articles[articleIndex])
    }
    
    func performArticleSegue(sender: Article) {
        DispatchQueue.main.async { [unowned self] in
            self.performSegue(withIdentifier: self.articleSegueIndentifier, sender: sender)
        }
    }
    
    func getDataFromServer(_ url:String, completionHadler: @escaping (ResponseCodable) -> Void) {
        
        guard let myURL = URL(string: url) else {return}
        let urlRequest = URLRequest(url: myURL)
        
        let task = URLSession.shared.dataTask(with: urlRequest) {
            (data, response, error) in
            guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            
            do {
                let json = try JSONDecoder().decode(RootCodable.self, from: dataResponse)
                completionHadler(json.response)
            } catch {
                print("Response error: \(error)")
            }
        }
        
        task.resume()
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}




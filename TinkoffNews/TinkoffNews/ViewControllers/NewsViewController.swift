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
    var url = "https://cfg.tinkoff.ru/news/public/api/platform/v1/getArticles?pageSize=%d&pageOffset=%d"
    let defaultPageSize = 20
    var currentPageOffset = 0
    var articles = [Article]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("oaded!!!")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

       // DatabaseController.deleteAllArticles()
        articles = DatabaseController.getAllArticles()
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      // print("acticles count=\(pageOffset)")
        print("acticles count=\(articles.count)")
        return articles.count
       // return pageOffset
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = articles.count - 1
        print("last item is \(lastItem)")
        if indexPath.row >= lastItem {
            print("!!!not enough cells!!! Row current=\(indexPath.row),last=\(lastItem)")
            getDataToReloadTableView()
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
    
    
    
    func getDataToReloadTableView() {
        getDataFromServer(defaultPageSize, currentPageOffset) { [weak self] (news) in
            if let mySelf = self {
               let cachedArticles = DatabaseController.addArticlesIfNotExist(news)
                DatabaseController.saveContext()
                mySelf.articles += cachedArticles
                mySelf.reloadTableView()
                mySelf.currentPageOffset = mySelf.articles.count + mySelf.defaultPageSize
            }
        }
    }
    
    func getDataFromServer(_ pageSize: Int, _ pageOffset: Int, completionHadler: @escaping ([ArticleCodable]) -> Void) {
        
        guard let myURL = URL(string: String(format: url, pageSize, pageOffset)) else {return}
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
                let news = json.response.news
                completionHadler(news)
                print("data task was completed")
            } catch {
                print(error)
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}




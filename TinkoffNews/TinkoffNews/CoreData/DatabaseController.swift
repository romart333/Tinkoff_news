//
//  DatabaseController.swift
//  TinkoffNews
//
//  Created by Roman on 08/12/2019.
//  Copyright © 2019 Roman. All rights reserved.
//

import Foundation
import CoreData

class DatabaseController {
    
    private init() {}
    // MARK: - Core Data stack
    
    class func getContext () -> NSManagedObjectContext {
        return DatabaseController.persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "TinkoffNews")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    class func addArticlesIfNotExist(_ news: [ArticleCodable]) -> [Article] {
        var addedArticles = [Article]()
        for article in news {
            if DatabaseController.isArticleExistWith(slug: article.slug) { continue }
            guard let entity = NSEntityDescription.insertNewObject(forEntityName: "Article", into: DatabaseController.getContext()) as? Article else {
                print("Error: Article entity description was not found")
                continue
            }
            
            // Set the data to the entity
            entity.slug = article.slug
            entity.title = article.title
            entity.countOfRedirects = 0
            addedArticles.append(entity)
        }
        
        DatabaseController.saveContext()
        return addedArticles
    }
    
    class func getAllArticles() -> Array<Article> {
        let all = Article.getArticleFetchRequest()
        var allArticles = [Article]()
        
        do {
            let fetched = try DatabaseController.getContext().fetch(all)
            allArticles = fetched
        } catch {
            let nserror = error as NSError
            print(nserror.description)
        }
        
        return allArticles
    }
    
    // MARK: - Core Data Saving support
    
    class func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    class func isArticleExistWith(slug : String) -> Bool {
        do {
            let fetchRequest = Article.getArticleFetchRequest()
            fetchRequest.predicate = NSPredicate(format: "slug == %@", slug)
            
            let fetchResults = try DatabaseController.getContext().fetch(fetchRequest)
            return fetchResults.count > 0
        } catch {
            let nserror = error as NSError
            //TODO: Handle error
            print(nserror.description)
        }
        
        return false
    }
    
    class func deleteAllArticles() {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
            let deleteAll = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            try DatabaseController.getContext().execute(deleteAll)
            DatabaseController.saveContext()
        } catch {
            let nserror = error as NSError
            //TODO: Handle error
            print(nserror.description)
        }
    }
}

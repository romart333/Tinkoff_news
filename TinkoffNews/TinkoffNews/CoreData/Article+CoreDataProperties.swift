//
//  Article+CoreDataProperties.swift
//  TinkoffNews
//
//  Created by Roman on 08/12/2019.
//  Copyright © 2019 Roman. All rights reserved.
//
//

import Foundation
import CoreData


extension Article {

    @nonobjc public class func getArticleFetchRequest() -> NSFetchRequest<Article> {
        return NSFetchRequest<Article>(entityName: "Article")
    }

    @NSManaged public var countOfRedirects: Int32
    @NSManaged public var title: String?
    @NSManaged public var text: String?
    @NSManaged public var slug: String?
}

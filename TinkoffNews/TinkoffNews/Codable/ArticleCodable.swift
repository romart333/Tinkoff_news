//
//  ArticleCodable.swift
//  TinkoffNews
//
//  Created by Roman on 08/12/2019.
//  Copyright © 2019 Roman. All rights reserved.
//

import Foundation
struct RootCodable: Decodable {
    let response: ResponseCodable
}

struct ResponseCodable: Decodable {
    let news: [ArticleCodable]?
    var text: String?
}

struct ArticleCodable: Decodable {
    var slug: String
    var title: String
    var text: String
}

//
//  StringExtension.swift
//  TinkoffNews
//
//  Created by Roman on 11/12/2019.
//  Copyright © 2019 Roman. All rights reserved.
//

import Foundation

extension String {
    func getNSAttributedString() -> NSAttributedString? {
        let data = Data(self.utf8)
        return try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
    }
}



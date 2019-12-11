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
        print("Text to convert: \(self)")
        print("Text to convert in utf8: \(self.utf8)")
        let data = Data(self.utf8)
       // let options = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue]// zapasnoi varik
        return try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
    }
}



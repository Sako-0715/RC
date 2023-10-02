//
//  RealmSwift.swift
//  RC
//
//  Created by 酒匂竜也 on 2023/09/30.
//

import Foundation
import RealmSwift

class RealmModel: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var janl = ""
    @objc dynamic var price = 0
    @objc dynamic var product = ""
    @objc dynamic var date = ""
    // 画像データを保存するプロパティを追加することもできます
    @objc dynamic var imageData: Data? = nil
    
    override static func primaryKey() -> String? {
            return "date" // この例では日時をプライマリーキーとして使用
        }
    }

//
//  Prodact.swift
//  RC
//
//  Created by 酒匂竜也 on 2023/10/01.
//

import Foundation
import RealmSwift

class Prodact: Object {
    @Persisted var productName = ""
    @Persisted var price = 0
    @Persisted var imageData: Data? = nil
    @Persisted var date = Date() // date プロパティを追加
    @Persisted var Janl = ""
}

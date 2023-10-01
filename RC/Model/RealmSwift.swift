//
//  RealmSwift.swift
//  RC
//
//  Created by 酒匂竜也 on 2023/09/30.
//

import Foundation
import RealmSwift

class Post: Object {
    @objc dynamic var id = UUID().uuidString // 一意のID
    @objc dynamic var text = ""
    @objc dynamic var imageData: Data? = nil // 画像データをバイナリで保存
}

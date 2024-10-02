//
//  ResultModel.swift
//  RC
//
//  Created by HFFM-012 on 2024/09/10.
//

import Foundation
struct ResultModel: Codable, Hashable {
    let ID: String
    let JANL: String
    let COUNT: Int
    let PRODACTNAME: String
    let DATE: String
    let FAVFLAG: String?
    
    // `Identifiable`プロトコルに準拠するための`id`プロパティ
    var id: String { ID }
    
    enum CodingKeys: String, CodingKey {
        case ID
        case JANL
        case COUNT
        case PRODACTNAME
        case DATE
        case FAVFLAG
    }
}

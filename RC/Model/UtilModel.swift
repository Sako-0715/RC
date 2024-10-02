//
//  UtilModel.swift
//  RC
//
//  Created by HFFM-012 on 2024/09/06.
//

import Foundation

class Util {
    static func Janl()->[String]{
        return ["調味料","飲み物","野菜","果物","豚肉","牛肉","鶏肉","肉","インスタント品","お惣菜","漬物","アイス","お菓子","その他"]
    }
    
    static func NumberPrice() ->[Int] {
        return[1,2,3,4,5,6,7,8,9]
    }
    
    static func SearchJanl() ->[String]{
        return ["","調味料","飲み物","野菜","果物","豚肉","牛肉","鶏肉","肉","インスタント品","お惣菜","漬物","アイス","お菓子","その他"]
    }
    
    static func SearchNuber() ->[String] {
        return["","1","2","3","4","5","6","7","8","9"]
    }
}

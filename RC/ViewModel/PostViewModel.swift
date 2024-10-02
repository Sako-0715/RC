//
//  PostViewModel.swift
//  RC
//
//  Created by HFFM-012 on 2024/09/04.
//

import Foundation
import UIKit

class PostViewModel: ObservableObject {
    
    // BaseApiModelをインスタンス化
    private let baseApiModel = BaseApiModel()
    
    /*
     * 送信内容を受け取るメソッド
     */
    func getData(janl: String, prodactName: String, numberPrice: String, postImage: UIImage?) {
        
        // 送信するデータを準備
        let parameters: [String: String] = [
            "janl": janl,
            "prodactName": prodactName,
            "numberPrice": numberPrice
        ]
        
        // 画像データを準備
        let imageData = postImage?.jpegData(compressionQuality: 0.8)
        
        // データを送信する
        sendData(parameters: parameters, imageData: imageData)
        
        
    }
    
    private func sendData(parameters: [String: String], imageData: Data?) {
        // デバイス端末情報を送る(ID生成の為)
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        let id = uuid.prefix(7)
        let postId = String(id)
        baseApiModel.postShoppingData(id: postId, janl: parameters["janl"] ?? "", count: parameters["numberPrice"] ?? "", prodact: parameters["prodactName"] ?? "") { result in
            switch result {
            case .success(let response):
                // JSONデコード
                if let data = response.data(using: .utf8) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        let resultValue = json?["result"] as? Bool
                        let newID = json?["ID"] as? String
                        let date = json?["date"] as? Date
                        
                        // ID生成の成功有無
                        if resultValue == true {
                            // ID生成に成功したので画像も同じIDを使ってRealmSwiftに保存する
                            let imageRealmModel = ImageRealm()
                            imageRealmModel.saveImage(id: newID, imageData: imageData, date: Date())
                        } else {
                            // ID生成失敗
                            print("Failed to get ID")
                        }
                    } catch {
                        // JSONエラーの場合
                        print("JSONデコードエラー: \(error)")
                    }
                }
            case .failure(let error):
                // 通信エラーの場合
                print("送信エラー: \(error)")
                
            }
        }
        
    }
    
}

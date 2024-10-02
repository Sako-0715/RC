//
//  ImageRealmModel.swift
//  RC
//
//  Created by HFFM-012 on 2024/08/28.
//

import Foundation
import RealmSwift

class ImageRealm: Object {
    @Persisted var ID: String? = nil
    @Persisted var imageData:Data? = nil
    @Persisted var date: Date? = nil
    
    override static func primaryKey() -> String? {
        return "ID"
    }
    
    /*
     * Realmに画像を保存する
     */
    public func saveImage(id: String?, imageData: Data?, date: Date?) {
        
        // 画像登録がなければ保存しない
        if imageData == nil {
            return
        }
        
        do {
            // Realm インスタンスの作成
            let realm = try Realm()
            
            // 新しい ImageRealm インスタンスを作成
            let imageRealm = ImageRealm()
            imageRealm.ID = id
            imageRealm.imageData = imageData
            imageRealm.date = date
            
            // 書き込み処理
            try realm.write {
                realm.add(imageRealm, update: .modified) // 更新がある場合は .modified を使用
            }
        } catch {
            // エラーハンドリング
            
            print("Realm エラー: \(error.localizedDescription)")
            // エラー処理をここに追加することもできます（例: ユーザーへの通知）
            // トーストで画像が保存できなかったトーストを表示する
        }
    }
    
    /*
     * ID で ImageRealm を取得する
     */
    public static func getImage(for id: String) -> ImageRealm? {
        do {
            let realm = try Realm()
            return realm.object(ofType: ImageRealm.self, forPrimaryKey: id)
        } catch {
            print("Realm エラー: \(error.localizedDescription)")
            return nil
        }
    }
}

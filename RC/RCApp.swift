//
//  RCApp.swift
//  RC
//
//  Created by HFFM-012 on 2024/08/28.
//

import SwiftUI
import RealmSwift

@main
struct RCApp: SwiftUI.App {
    init() {
        setupRealmMigration()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func setupRealmMigration() {
        let config = Realm.Configuration(
            schemaVersion: 2, // 現在のスキーマバージョン
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    // 'ID' を必須に変更した場合や、プロパティの変更に対応
                    migration.enumerateObjects(ofType: ImageRealm.className()) { oldObject, newObject in
                        // ID のオプショナルから必須への変更
                        if oldSchemaVersion < 1 {
                            newObject?["ID"] = oldObject?["ID"] ?? ""
                        }
                        // date プロパティの追加
                        if oldSchemaVersion < 2 {
                            let date = oldObject?["Date"] as? Date
                            newObject?["date"] = date
                        }
                    }
                }
            }
        )
        Realm.Configuration.defaultConfiguration = config
        // 初期化時にエラーが発生しないように確認
        do {
            _ = try Realm()
        } catch {
            print("Realm エラー: \(error)")
        }
    }
}

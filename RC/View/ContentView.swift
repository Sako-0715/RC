//  ContentView.swift
//  RC
//
//  Created by HFFM-012 on 2024/08/28.
//

import SwiftUI

struct ContentView: View {
    init() {
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "Georgia", size: 26)!]
    }
    
    @State private var isStash = false
    // 選択ボタンが押されたらHistoryViewにflagを送る
    @State private var selectFlag = false
    // 削除(trash)ボタンが押されたらHistoryViewにflagを送る
    @State private var deleteFlag = false
    
    @State private var isBackHistory = false
    @State private var isFavViewActive = false
    
    
    var body: some View {
        TabView {
            NavigationView {
                //　投稿履歴を表示する
                HistoryView(selectFlag: $selectFlag, deleteFlag: $deleteFlag, isStash: $isStash, isBackHistory: $isBackHistory)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("RC")
                                .font(.custom("Georgia", size: 26))
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(
                        leading: Button(action: {
                            // 右のボタンが押されたときのアクション
                            isStash.toggle()
                            if isStash {
                                // 選択可
                                selectFlag = true
                            } else {
                                // 選択キャンセル
                                selectFlag = false
                                deleteFlag = false
                            }
                        }) {
                            if isStash {
                                Text("戻る")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            } else {
                                Text("選択")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                            
                        },
                        trailing: HStack {
                            // 削除
                            Button(action: {
                                // ボタンが押されたらアイコンを表示
                                if isStash {
                                    // 削除ボタンが押されたflagを送る
                                    deleteFlag = true
                                    
                                }
                                
                            }) {
                                HStack {
                                    // 選択が押されたらアイコンを表示
                                    if isStash {
                                        IconView(systemName: "trash")
                                    }
                                }
                            }
                            // お気に入り
                            // プッシュ遷移
                            NavigationLink(destination: FavView().onDisappear {
                                isBackHistory = true
                            },isActive: $isFavViewActive) {
                                // 選択ボタンが押されたら非表示
                                if !isStash {
                                    VStack {
                                        Text("お気に入り一覧")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 15).weight(.bold))
                                    }
                                }
                                
                            }
                        }
                    )
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                IconView(systemName: "list.dash",label: "全履歴")
            }
            // PostView画面
            NavigationView {
                PostView()
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("RC")
                                .font(.custom("Georgia", size: 26))
                        }
                    }
                // 他View画面が呼ばれたら一旦リセット
                    .onAppear {
                        isStash = false
                        selectFlag = false
                        deleteFlag = false
                        isFavViewActive = false
                    }
            }
            .tabItem {
                IconView(systemName: "photo.on.rectangle.angled", label: "保存")
            }
            NavigationView {
                SearchView()
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("RC")
                                .font(.custom("Georgia", size: 26))
                        }
                    }
                // 他View画面が呼ばれたら一旦リセット
                    .onAppear {
                        isStash = false
                        selectFlag = false
                        deleteFlag = false
                        isFavViewActive = false
                    }
            }
            .tabItem {
                IconView(systemName: "magnifyingglass", label: "投稿検索")
            }
        }
        .accentColor(.black)
    }
}

// Iconの形式をそろえる
struct IconView: View {
    var systemName: String
    var label: String?
    
    var body: some View {
        Image(systemName: systemName)
            .foregroundColor(.blue)
            .font(.title)
        Text(label ?? "")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

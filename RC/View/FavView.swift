//
//  FavView.swift
//  RC
//
//  Created by HFFM-012 on 2024/10/01.
//

import SwiftUI

struct FavView: View {
    // お気に入り登録された内容を格納する配列
    @StateObject private var favViewModel = FavViewModel()
    @StateObject private var historyViewModel = HistoryViewModel()
    // ハートが選択されているかどうかを管理するための変数
    @State private var favItem: Set<String> = []
    
    // ローカルな選択されたアイテムのIDを管理
    @State private var selectItem: Set<String> = []
    
    @State private var selectFlag = false
    
    var body: some View {
        ScrollView {
            VStack {
                if favViewModel.favDataArray.isEmpty {
                    // お気に入りがない場合の表示
                    Text("お気に入りを登録していません")
                        .font(.title2)
                } else {
                    ForEach(favViewModel.favDataArray, id: \.id) { favData in
                        VStack {
                            VStack {
                                if let image = favViewModel.favImage[favData.id] {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width, alignment: .center)
                                        .clipShape(Rectangle())
                                } else {
                                    // 投稿画像無の場合
                                    Image(systemName: "photo.stack")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width, alignment: .center)
                                        .clipShape(Rectangle())
                                }
                                Group {
                                    Button(action: {
                                        // サーバーから消す
                                        favViewModel.deleteFav(favId: [favData.id]) { result in
                                            if result {
                                                // 既にいいねしていた場合は解除
                                                favItem.remove(favData.id)
                                                favViewModel.fetchFav { result in
                                                }
                                            } else {
                                                print("失敗")
                                            }
                                        }
                                    }) {
                                        Image(systemName: favItem.contains(favData.id) ? "heart.fill" : "heart")
                                            .foregroundColor(.red)
                                            .font(.system(size: 23))
                                    }
                                    Text( "ジャンル:  ")
                                        .font(.system(size: 16, weight: .bold))
                                    +
                                    Text(favData.JANL)
                                        .font(.system(size: 20, weight: .bold))
                                    Text( "商品名:  ")
                                        .font(.system(size: 16, weight: .bold))
                                    +
                                    Text(favData.PRODACTNAME)
                                        .font(.system(size: favViewModel.FontSize(productName: favData.PRODACTNAME), weight: .bold))
                                    Text( "個数:  ")
                                        .font(.system(size: 16, weight: .bold))
                                    +
                                    Text("\(favData.COUNT)")
                                        .font(.system(size: 20, weight: .bold))
                                    Text( "投稿日時:  ")
                                        .font(.system(size: 16, weight: .bold))
                                    +
                                    Text(favViewModel.FormatDate(favData.DATE))
                                        .font(.system(size: 16, weight: .bold))
                                    
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(3)
                            }
                            // 背景色を変更
                            .padding()
                            .background(selectItem.contains(favData.id) ? Color.gray.opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                            .contentShape(Rectangle())
                            Divider()
                        }
                        .onTapGesture {
                            // 選択ボタンが押されていたら
                            if selectFlag {
                                // 選択していて解除したら選択していたIDを削除
                                if selectItem.contains(favData.id) {
                                    // すでに選択されている場合は選択解除
                                    selectItem.remove(favData.id)
                                } else {
                                    // 選択されたIDを保存
                                    selectItem.insert(favData.id)
                                }
                            }
                        }
                        .onAppear {
                            // 各アイテムの画像をロードする
                            favViewModel.loadImage(for: favData)
                        }
                    }
                }
            }
            .onAppear {
                // ビューが表示されたときに履歴を取得
                favViewModel.fetchFav { result in
                    favItem.removeAll()
                    for data in result {
                        if data.FAVFLAG == "1" {
                            favItem.insert(data.id)
                        }
                    }
                }
            }
        }
        // お気に入り登録していない場合はNavigationを非表示
        .navigationBarItems(trailing:
                                favViewModel.favDataArray.isEmpty ? nil : HStack {
            if selectFlag {
                Button(action: {
                    // 選択されたアイテムをお気に入りから削除
                    for id in selectItem {
                        favViewModel.deleteFav(favId: [id]) { result in
                            if result {
                                favItem.remove(id)
                                selectItem.remove(id)
                                // 削除後のデータを再取得
                                favViewModel.fetchFav { _ in }
                            } else {
                                print("削除失敗")
                            }
                        }
                    }
                }) {
                    VStack {
                        Image(systemName: "bolt.heart")
                            .font(.headline)
                            .foregroundColor(.blue)
                        Text("お気に入り複数解除")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            Button(action: {
                selectFlag.toggle()
            }) {
                Text(selectFlag ? "キャンセル" : "複数選択")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
        }
        )
    }
}

#Preview {
    FavView()
}

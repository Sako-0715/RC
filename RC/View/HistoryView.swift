//
//  HistoryView.swift
//  RC
//
//  Created by HFFM-012 on 2024/08/28.
//

import SwiftUI

enum AlertType: Identifiable {
    case selection
    case noSelection
    
    var id: Int {
        switch self {
        case .selection: return 0
        case .noSelection: return 1
        }
    }
}

struct HistoryView: View {
    // 投稿された内容を格納する配列
    @StateObject private var historyViewModel = HistoryViewModel()
    
    // ローカルな選択されたアイテムのIDを管理
    @State private var selectedItemIds: Set<String> = []
    
    // アラートの表示出しわけフラグ
    @State private var isAlert: AlertType?
    
    // ハートが選択されているかどうかを管理するための変数
    @State private var likedItems: Set<String> = []
    
    // ContenViewよりボタンが押された時のflagを受け取る
    @Binding public var selectFlag: Bool
    @Binding public var deleteFlag: Bool
    @Binding public var isStash: Bool
    @Binding public var isBackHistory: Bool
    
    
    var body: some View {
        ScrollView {
            VStack {
                if historyViewModel.historyDataArray.isEmpty {
                    // 履歴がない場合の表示
                    Text("投稿履歴がありません")
                        .font(.title2)
                } else {
                    ForEach(historyViewModel.historyDataArray, id: \.id) { historyData in
                        VStack {
                            VStack {
                                if let image = historyViewModel.historyImage[historyData.id] {
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
                                        
                                        if likedItems.contains(historyData.id) {
                                            // サーバーから消す
                                            historyViewModel.deleteFavFlag(favId: [historyData.id]) { result in
                                                if result {
                                                    // 既にいいねしていた場合は解除
                                                    likedItems.remove(historyData.id)
                                                } else {
                                                    print("失敗")
                                                }
                                            }
                                        } else {
                                            // ハートが押されたら
                                            likedItems.insert(historyData.id)
                                            // サーバーへ保存
                                            historyViewModel.updateFavFlag(favId: [historyData.id]) { result in
                                                if result {
                                                    print("保存")
                                                } else {
                                                    print("失敗")
                                                }
                                            }
                                        }
                                        
                                    }) {
                                        Image(systemName: likedItems.contains(historyData.id) ? "heart.fill" : "heart")
                                            .foregroundColor(.red)
                                            .font(.system(size: 23))
                                    }
                                    Text( "ジャンル:  ")
                                        .font(.system(size: 16, weight: .bold))
                                    +
                                    Text(historyData.JANL)
                                        .font(.system(size: 20, weight: .bold))
                                    Text( "商品名:  ")
                                        .font(.system(size: 16, weight: .bold))
                                    +
                                    Text(historyData.PRODACTNAME)
                                        .font(.system(size: historyViewModel.FontSize(productName: historyData.PRODACTNAME), weight: .bold))
                                    Text( "個数:  ")
                                        .font(.system(size: 16, weight: .bold))
                                    +
                                    Text("\(historyData.COUNT)")
                                        .font(.system(size: 20, weight: .bold))
                                    Text( "投稿日時:  ")
                                        .font(.system(size: 16, weight: .bold))
                                    +
                                    Text(historyViewModel.FormatDate(historyData.DATE))
                                        .font(.system(size: 16, weight: .bold))
                                    
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(3)
                            }
                            // 背景色を変更
                            .padding()
                            .background(selectedItemIds.contains(historyData.id) ? Color.gray.opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                            .contentShape(Rectangle())
                            Divider()
                        }
                        .onTapGesture {
                            // 選択ボタンが押されていたら
                            if selectFlag {
                                // 選択していて解除したら選択していたIDを削除
                                if selectedItemIds.contains(historyData.id) {
                                    // すでに選択されている場合は選択解除
                                    selectedItemIds.remove(historyData.id)
                                } else {
                                    // 選択されたIDを保存
                                    selectedItemIds.insert(historyData.id)
                                }
                            }
                        }
                        .onAppear {
                            // 各アイテムの画像をロードする
                            historyViewModel.loadImage(for: historyData)
                        }
                    }
                }
            }
        }
        .onAppear {
            // ビューが表示されたときに履歴を取得
            historyViewModel.fetchHistory { result in
                // 初期化
                likedItems.removeAll()
                for data in result {
                    if data.FAVFLAG == "1" {
                        likedItems.insert(data.id)
                    }
                }
            }
        }
        // 選択ボタンが押され選択中にキャンセルが押されたら選択中のListを元に戻す
        .onChange(of: selectFlag) { cancel in
            if !cancel && !deleteFlag {
                selectedItemIds.removeAll()
            }
        }
        // 選択中に削除ボタンが押されたら
        .onChange(of: deleteFlag) { delete in
            if delete {
                if !selectedItemIds.isEmpty {
                    isAlert = .selection
                } else {
                    isAlert = .noSelection
                    deleteFlag = false
                }
            }
        }
        
        .onChange(of: isBackHistory) { back in
            if back {
                // 履歴を再取得して、likedItemsを更新
                historyViewModel.fetchHistory { result in
                    // likedItemsをクリアして再度更新
                    likedItems.removeAll()
                    for data in result {
                        if data.FAVFLAG == "1" {
                            likedItems.insert(data.id)
                        }
                    }
                    isBackHistory = false
                }
            }
            
        }
        // アラートの表示出しわけ
        .alert(item: $isAlert) { alertType in
            switch alertType {
            case .selection:
                return Alert(
                    title: Text(""),
                    message: Text("本当に削除しますか？"),
                    primaryButton: .destructive(Text("削除")) {
                        historyViewModel.deleteHistory(historyId: selectedItemIds) { success in
                            if success {
                                // 成功したらローカルのデータを更新して即時反映
                                historyViewModel.historyDataArray.removeAll { history in
                                    selectedItemIds.contains(history.id)
                                }
                            }
                            selectedItemIds.removeAll()
                            historyViewModel.updateHistory()
                            isStash = false
                        }
                        deleteFlag = false
                        selectFlag = true
                    },
                    secondaryButton: .cancel(Text("キャンセル")) {
                        deleteFlag = false
                        selectFlag = true
                    }
                )
            case .noSelection:
                return Alert(
                    title: Text(""),
                    message: Text("削除する履歴がありません。\n選択してください。"),
                    dismissButton: .default(Text("OK")) {
                        selectFlag = true
                    }
                )
            }
        }
    }
}

#Preview {
    HistoryView(selectFlag: .constant(false), deleteFlag: .constant(false), isStash: .constant(false), isBackHistory: .constant(false))
}

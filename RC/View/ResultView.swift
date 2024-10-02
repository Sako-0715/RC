//
//  ResultView.swift
//  RC
//
//  Created by HFFM-012 on 2024/09/10.
//

import SwiftUI

enum resultAlertType: Identifiable {
    case ALLTRASH
    case INFAV
    case OUTFAV
    
    var id: Int {
        switch self {
        case .ALLTRASH: return 0
        case .INFAV: return 1
        case .OUTFAV: return 2
        }
    }
}

struct ResultView: View {
    // SearchView から渡されるデータ
    let janl: String?
    let prodactName: String?
    let nuberPrice: String
    
    // 投稿された内容を格納する配列
    @StateObject private var resultViewModel = ResultViewModel()
    @StateObject private var historyViewModel = HistoryViewModel()
    
    // ハートが選択されているかどうかを管理するための変数
    @State private var resultFav: Set<String> = []
    // ローカルな選択されたアイテムのIDを管理
    @State private var resultSelect: Set<String> = []
    
    @State private var selectFlag: Bool = false
    
    // アラートの表示出しわけフラグ
    @State private var resultAlert: resultAlertType?
    
    @State private var resultFavId: String? = nil
    
    var body: some View {
        ScrollView {
            VStack {
                if resultViewModel.resultDataArray.isEmpty {
                    // 履歴がない場合の表示
                    Text("投稿履歴がありません")
                        .font(.title2)
                } else {
                    ForEach(resultViewModel.resultDataArray, id: \.id) { resultData in
                        VStack() {
                            // 投稿画像がある場合
                            if let image = resultViewModel.resultImage[resultData.id] {
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
                                    
                                    if resultFav.contains(resultData.id) {
                                        // サーバーから消す
                                        historyViewModel.deleteFavFlag(favId: [resultData.id]) { result in
                                            if result {
                                                // 既にいいねしていた場合は解除
                                                resultFav.remove(resultData.id)
                                            } else {
                                                print("失敗")
                                            }
                                        }
                                    } else {
                                        // ハートが押されたら
                                        resultFav.insert(resultData.id)
                                        // サーバーへ保存
                                        historyViewModel.updateFavFlag(favId: [resultData.id]) { result in
                                            if result {
                                                print("保存")
                                            } else {
                                                print("失敗")
                                            }
                                        }
                                    }
                                    
                                }) {
                                    Image(systemName: resultFav.contains(resultData.id) ? "heart.fill" : "heart")
                                        .foregroundColor(.red)
                                        .font(.system(size: 23))
                                }
                                Text( "ジャンル:  ")
                                    .font(.system(size: 16, weight: .bold))
                                +
                                Text(resultData.JANL)
                                    .font(.system(size: 20, weight: .bold))
                                Text( "商品名:  ")
                                    .font(.system(size: 16, weight: .bold))
                                +
                                Text(resultData.PRODACTNAME)
                                    .font(.system(size: resultViewModel.FontSize(productName: resultData.PRODACTNAME), weight: .bold))
                                Text( "個数:  ")
                                    .font(.system(size: 16, weight: .bold))
                                +
                                Text("\(resultData.COUNT)")
                                    .font(.system(size: 20, weight: .bold))
                                Text( "投稿日時:  ")
                                    .font(.system(size: 16, weight: .bold))
                                +
                                Text(resultViewModel.FormatDate(resultData.DATE))
                                    .font(.system(size: 16, weight: .bold))
                                
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(3)
                        }
                        // 背景色を変更
                        .padding()
                        .background(resultSelect.contains(resultData.id) ? Color.gray.opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // 選択ボタンが押されていたら
                            if selectFlag {
                                // 選択していて解除したら選択していたIDを削除
                                if resultSelect.contains(resultData.id) {
                                    // すでに選択されている場合は選択解除
                                    resultSelect.remove(resultData.id)
                                } else {
                                    // 選択されたIDを保存
                                    resultSelect.insert(resultData.id)
                                }
                            }
                        }
                        .onAppear {
                            // 各アイテムの画像をロードする
                            resultViewModel.resultloadImage(for: resultData)
                        }
                        Divider()
                    }
                }
            }
            .onAppear {
                // ビューが表示されたときに履歴を取得
                resultViewModel.fetchResult(janl: janl, count: nuberPrice, prodact: prodactName)
                historyViewModel.fetchHistory { result in
                    resultFav.removeAll()
                    for data in result {
                        if data.FAVFLAG == "1" {
                            resultFav.insert(data.id)
                        }
                    }
                }
            }
            .onChange(of: selectFlag) { cancel in
                // 選択中にキャンセルが押されたら
                if !cancel {
                    resultSelect.removeAll()
                }
            }
            
            .navigationBarItems(trailing:
                                    resultViewModel.resultDataArray.isEmpty ? nil : HStack {
                
                if selectFlag && !resultSelect.isEmpty {
                    Button(action: {
                        // 削除処理
                        resultAlert = .ALLTRASH
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.blue)
                    }
                    Button(action: {
                        // お気に入り処理
                        resultAlert = .INFAV
                    }) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        // お気に入り処理
                        resultAlert = .OUTFAV
                    }) {
                        Image(systemName: "bolt.heart")
                            .foregroundColor(.blue)
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
        
        .alert(item: $resultAlert) { alertType in
            switch alertType {
            case .ALLTRASH:
                return Alert(
                    title: Text(""),
                    message: Text("本当に削除しますか？"),
                    primaryButton: .destructive(Text("削除")) {
                        historyViewModel.deleteHistory(historyId: resultSelect) { success in
                            if success {
                                // 成功したらローカルのデータを更新して即時反映
                                resultViewModel.resultDataArray.removeAll { result in
                                    resultSelect.contains(result.id)
                                }
                            }
                            resultSelect.removeAll()
                            resultViewModel.fetchResult(janl: janl, count: nuberPrice, prodact: prodactName)
                            selectFlag = false
                        }
                    },
                    secondaryButton: .cancel(Text("キャンセル")) {
                        selectFlag = true
                    }
                )
            case .INFAV:
                return Alert(
                    title: Text(""),
                    message: Text("一括登録しますか？"),
                    primaryButton: .destructive(Text("登録")) {
                        print("保存処理前のID: \(resultSelect)") // 追加
                        // サーバーへ保存
                        historyViewModel.updateFavFlag(favId: resultSelect) { result in
                            if result {
                                // 更新
                                historyViewModel.fetchHistory { result in
                                    resultFav.removeAll()
                                    for data in result {
                                        if data.FAVFLAG == "1" {
                                            resultFav.insert(data.id)
                                        }
                                    }
                                }
                                selectFlag = false
                            } else {
                                print("失敗")
                                selectFlag = true
                            }
                        }
                    },
                    secondaryButton: .cancel(Text("キャンセル")) {
                        selectFlag = true
                    }
                )
            case .OUTFAV:
                return Alert(
                    title: Text(""),
                    message: Text("一括解除しますか？"),
                    primaryButton: .destructive(Text("解除")) {
                        // サーバーへ保存
                        // サーバーから消す
                        historyViewModel.deleteFavFlag(favId: resultSelect) { result in
                            if result {
                                historyViewModel.fetchHistory { result in
                                    resultFav.removeAll()
                                    for data in result {
                                        if data.FAVFLAG == "1" {
                                            resultFav.insert(data.id)
                                        }
                                    }
                                }
                                selectFlag = false
                            } else {
                                print("失敗")
                                selectFlag = true
                            }
                        }
                    },
                    secondaryButton: .cancel(Text("キャンセル")) {
                        selectFlag = true
                    }
                )
            }
        }
    }
}

#Preview {
    ResultView(janl: "", prodactName: nil, nuberPrice: "")
}

//
//  SearchView.swift
//  RC
//
//  Created by HFFM-012 on 2024/09/03.
//

import SwiftUI

struct SearchView: View {
    // ジャンル
    @State private var janl: String = ""
    // 商品名
    @State private var prodactName: String = ""
    // 個数
    @State private var nuberPrice: String = ""
    // ドラムロールのトリガー
    @State private var isPickerProdact = false
    // ジャンルのドラムロール内容
    @State private var selectedJanl: String = Util.SearchJanl().first ?? ""
    // 個数のドラムロールのトリガー
    @State private var isNumberPrice = false
    // 個数のドラムロール内容
    @State private var selectedNumberPrice: String = Util.SearchNuber().first ?? ""
    // 商品名フィールドのフォーカス状態を管理する
    @FocusState private var isProductName
    
    // トースト表示有無
    @State private var showToast: Bool = false
    // トースト表示時のメッセージ
    @State private var toastMessage: String = ""
    
    @State private var isResultView = false
    
    var body: some View {
        VStack {
            TextField("ジャンル", text: $janl)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            // 横方向の余白を調整
                .padding(.horizontal)
            // 下部の余白を調整
                .padding(.bottom, 20)
                .onTapGesture {
                    isPickerProdact = true
                }
            
            TextField("商品名", text: $prodactName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            // 横方向の余白を調整
                .padding(.horizontal)
            // 下部の余白を調整
                .padding(.bottom, 20)
            // FocusStateでフォーカスを管理
                .focused($isProductName)
                .onTapGesture {
                    // タップ時にフォーカスを設定してキーボードを表示
                    isProductName = true
                }
            
            TextField("個数", text: $nuberPrice)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            // 横方向の余白を調整
                .padding(.horizontal)
            // 下部の余白を調整
                .padding(.bottom, 20)
                .onTapGesture {
                    isNumberPrice = true
                }
            
            Button(action: {
                //　ここで検索する
                isResultView = true
                
            }) {
                Text("検索")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(Color.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // NavigationLink を使って遷移
            NavigationLink(
                destination: ResultView(janl: janl, prodactName: prodactName, nuberPrice: nuberPrice)
                    .onDisappear {
                        isResultView = false
                        janl = ""
                        prodactName = ""
                        nuberPrice = ""
                    },
                isActive: $isResultView
            ) {
                EmptyView()
            }
        }
        
        // Pickerを表示するモーダル
        .sheet(isPresented: $isPickerProdact) {
            VStack {
                Picker("ジャンルを選択", selection: $selectedJanl) {
                    ForEach(Util.SearchJanl(), id: \.self) { janl in
                        Text(janl).tag(janl)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                
                // 決定ボタンでPickerを閉じてTextFieldに反映
                Button("決定") {
                    janl = selectedJanl
                    isPickerProdact = false
                }
                .padding()
            }
        }
        
        // 個数選択用Pickerモーダル
        .sheet(isPresented: $isNumberPrice) {
            VStack {
                Picker("個数を選択", selection: $selectedNumberPrice) {
                    ForEach(Util.SearchNuber(), id: \.self) { number in
                        Text("\(number)").tag(number)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                
                // 決定ボタンでPickerを閉じてTextFieldに反映
                Button("決定") {
                    nuberPrice = "\(selectedNumberPrice)"
                    isNumberPrice = false
                }
                .padding()
            }
        }
        // 背景をタップしたらキーボードを閉じる処理
        .onTapGesture {
            isProductName = false
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    SearchView()
}

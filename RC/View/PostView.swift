//
//  PostView.swift
//  RC
//
//  Created by HFFM-012 on 2024/09/03.
//

import SwiftUI
import UIKit
import RealmSwift
import Alamofire

struct PostView: View {
    // 投稿内容の処理
    @StateObject private var postViewModel = PostViewModel()
    // 選択前の画像(アイコン)
    @State private var defaltImage = Image(systemName: "photo.badge.plus")
    // 画像がタップされた時のトリガー
    @State private var isImagePicker = false
    // 投稿画像(選択する画像)
    @State private var postImage: UIImage?
    // ジャンル
    @State private var janlText: String = ""
    // 商品名
    @State private var prodactName: String = ""
    // 個数
    @State private var nuberPrice: String = ""
    // ドラムロールのトリガー
    @State private var isPickerProdact = false
    // ジャンルのドラムロール内容
    @State private var selectedJanl: String = Util.Janl().first ?? ""
    // 個数のドラムロールのトリガー
    @State private var isNumberPrice = false
    // 個数のドラムロール内容
    @State private var selectedNumberPrice: Int = Util.NumberPrice().first ?? 1
    // 商品名フィールドのフォーカス状態を管理する
    @FocusState private var isProductName
    
    // トースト表示有無
    @State private var showToast: Bool = false
    // トースト表示時のメッセージ
    @State private var toastMessage: String = ""
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                VStack {
                    //　投稿画像(選択画像)が選択されれば
                    if let postImage = postImage {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: postImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: geometry.size.height * 0.4) // 高さを画面の40%に設定
                                .clipped()
                            // 右上に配置されたバツボタン
                            Button(action: {
                                // 画像をクリアする
                                self.postImage = nil
                            }) {
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(.white)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                            // 右上のバツボタンの余白
                            .padding(10)
                        }
                        // 画像が表示されている場合に余白を追加
                        // 画像の下に余白を追加
                        Spacer().frame(height: 30)
                    } else {
                        //　選択されていない場合
                        defaltImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .padding(.top, 80)
                            .padding(.leading, 40)
                            .alignmentGuide(.top) { _ in 0 }
                            .onTapGesture {
                                isImagePicker = true
                            }
                        Divider()
                            .padding(.vertical,15)
                    }
                    
                    TextField("ジャンル", text: $janlText)
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
                        if janlText.isEmpty || prodactName.isEmpty || nuberPrice.isEmpty {
                            toastMessage = "未入力箇所があります。入力してください。"
                            showToast = true
                        } else {
                            // ここに送信処理を追加
                            postViewModel.getData(janl: janlText, prodactName: prodactName, numberPrice: nuberPrice, postImage: postImage)
                            
                            postImage = nil
                            janlText = ""
                            prodactName = ""
                            nuberPrice = ""
                            
                        }
                    }) {
                        Text("送信")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(Color.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // トースト表示
                    if showToast {
                        Text(toastMessage)
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.bottom, 10) // 送信ボタンとの間に余白を追加
                            .transition(.opacity)
                            .animation(.easeInOut, value: showToast)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showToast = false
                                    }
                                }
                            }
                    }
                }
            }
        }
        
        .sheet(isPresented: $isImagePicker) {
            ImagePicker(selectedImage: $postImage, sourceType: .photoLibrary)
        }
        
        // Pickerを表示するモーダル
        .sheet(isPresented: $isPickerProdact) {
            VStack {
                Picker("ジャンルを選択", selection: $selectedJanl) {
                    ForEach(Util.Janl(), id: \.self) { janl in
                        Text(janl).tag(janl)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                
                // 決定ボタンでPickerを閉じてTextFieldに反映
                Button("決定") {
                    janlText = selectedJanl
                    isPickerProdact = false
                }
                .padding()
            }
        }
        // 個数選択用Pickerモーダル
        .sheet(isPresented: $isNumberPrice) {
            VStack {
                Picker("個数を選択", selection: $selectedNumberPrice) {
                    ForEach(Util.NumberPrice(), id: \.self) { number in
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

// 画像・アルバム
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        imagePicker.sourceType = sourceType
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    PostView()
}

//
//  FavViewModel.swift
//  RC
//
//  Created by HFFM-012 on 2024/10/01.
//

import Foundation
import RealmSwift

class FavViewModel: ObservableObject {
    
    private let baseApi = BaseApiModel()
    @Published var favDataArray: [History] = []
    @Published var favImage: [String: UIImage] = [:]
    @Published var image: UIImage?
    
    /*
     * お気に入り登録を取得する
     */
    public func fetchFav(completion: @escaping ([History]) -> Void) {
        baseApi.getFav { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self?.favDataArray = data
                    self?.loadImages()
                }
                completion(data)
            case .failure(let error):
                print("Error fetching history: \(error)")
                completion([])
            }
        }
    }
    
    /*
     * 商品名の文字数が多い場合はフォントサイズを調整するためのメソッド
     */
    public func FontSize(productName: String) -> CGFloat {
        let maxLength = 20 // フォントサイズを最大にする文字数
        let minLength = 10 // フォントサイズを最小にする文字数
        let scaleFactor: CGFloat = 0.5 // 文字数1文字に対するフォントサイズの減少率
        let productNameLength = productName.count
        
        // フォントサイズを計算
        var fontSize = CGFloat(maxLength - productNameLength) * scaleFactor + 16 // デフォルトのフォントサイズ16
        if fontSize < CGFloat(minLength) {
            fontSize = CGFloat(minLength)
        }
        return fontSize
    }
    
    /*
     * 日付のフォーマットを変える
     */
    public func FormatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        // 新しい日付フォーマット
        dateFormatter.dateFormat = "yyyy/MM/dd"
        if let date = dateFormatter.date(from: dateString) {
            return dateFormatter.string(from: date)
        } else {
            // 日付の変換に失敗した場合は元の文字列を返す
            return dateString
        }
    }
    
    /*
     * 投稿画像をRealmから取得する
     */
    public func loadImage(for favData: History) {
        let realm = try! Realm()
        let id = favData.ID
        let realmImage = realm.objects(ImageRealm.self).filter("ID == %@", id)
        if let realmImageObject = realmImage.first, let imageData = realmImageObject.imageData {
            DispatchQueue.main.async {
                self.favImage[id] = UIImage(data: imageData)
            }
        }
    }
    
    /*
     * 画像を読み込む
     */
    private func loadImages() {
        for favData in favDataArray {
            loadImage(for: favData)
        }
    }
    
    /*
     * 選択された投稿お気に入りから削除する
     */
    public func deleteFav(favId: Set<String>, completion: @escaping (Bool) -> Void) {
        let historyIdArray = Array(favId)
        baseApi.deleteHistoryFavData(id: historyIdArray) { result in
            switch result {
            case .success(let message):
                completion(true)
            case .failure(let error):
                print("削除失敗: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
}

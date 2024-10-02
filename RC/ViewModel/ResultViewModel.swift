//
//  ResultViewModel.swift
//  RC
//
//  Created by HFFM-012 on 2024/09/10.
//

import Foundation
import RealmSwift
import UIKit


class ResultViewModel: ObservableObject {
    
    private let baseApi = BaseApiModel()
    @Published var resultDataArray: [ResultModel] = []
    @Published var resultImage: [String: UIImage] = [:]
    @Published var image: UIImage?
    
    
    /*
     * 投稿履歴を取得する
     */
    public func fetchResult(janl: String?, count: String?, prodact: String?) {
        baseApi.getResult(janl: janl, count: count, prodact: prodact) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self?.resultDataArray = data
                    self?.resultloadImages()
                }
            case .failure(let error):
                print("Error fetching history: \(error)")
            }
        }
    }
    
    /*
     * 商品名の文字数が多い場合はフォントサイズを調整するためのメソッド
     */
    public func FontSize(productName: String) -> CGFloat {
        // フォントサイズを最大にする文字数
        let maxLength = 20
        // フォントサイズを最小にする文字数
        let minLength = 10
        // 文字数1文字に対するフォントサイズの減少率
        let scaleFactor: CGFloat = 0.5
        let productNameLength = productName.count
        
        // フォントサイズを計算
        // デフォルトのフォントサイズ16
        var fontSize = CGFloat(maxLength - productNameLength) * scaleFactor + 16
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
    public func resultloadImage(for resultData: ResultModel) {
        let realm = try! Realm()
        let id = resultData.ID
        let realmImage = realm.objects(ImageRealm.self).filter("ID == %@", id)
        if let realmImageObject = realmImage.first, let imageData = realmImageObject.imageData {
            DispatchQueue.main.async {
                self.resultImage[id] = UIImage(data: imageData)
            }
        }
    }
    
    /*
     * 画像を読み込む
     */
    private func resultloadImages() {
        for resultData in resultDataArray {
            resultloadImage(for: resultData)
        }
    }
    
    /*
     * 選択された画像を削除する
     */
    public func resultDeleteImage(for resultId: String) {
        let realm = try! Realm()
        
        // Realmに該当の画像データが存在するかチェック
        if let realmImageObject = realm.objects(ImageRealm.self).filter("ID == %@", resultId).first {
            try! realm.write {
                // 画像データの削除
                realm.delete(realmImageObject)
            }
        }
        // メモリ上のキャッシュからも削除
        DispatchQueue.main.async {
            self.resultImage[resultId] = nil
        }
    }
    
    /*
     * 選択された投稿を削除する
     */
    public func deleteResult(resultId: Set<String>, completion: @escaping (Bool) -> Void) {
        let resultIdArray = Array(resultId)
        baseApi.deleteHistoryData(id: resultIdArray) { result in
            switch result {
            case .success(let message):
                for id in resultIdArray {
                    self.resultDeleteImage(for: id)
                }
                completion(true)
            case .failure(let error):
                print("削除失敗: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
}

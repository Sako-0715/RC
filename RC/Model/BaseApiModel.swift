//
//  BaseApiModel.swift
//  RC
//
//  Created by HFFM-012 on 2024/08/28.
//

import Foundation
import Alamofire

class BaseApiModel {
    // 投稿した履歴が入る配列
    private var historyDataArray: [History] = []
    
    /*
     * サーバーに送信する(投稿)
     */
    public func postShoppingData(id: String, janl: String, count: String, prodact: String, completion: @escaping (Result<String, Error>) -> Void) {
        // データーベースに送信する
        let url = "http://localhost:8888/RC_SAVE_API/iOS/Controller/ShopingController.php"
        let shopdata: [String: Any] = ["ID": id, "Janl": janl, "Count": count, "Prodact": prodact]
        
        AF.request(url, method: .post, parameters: shopdata, encoding: URLEncoding.default)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    if let resultString = String(data: data, encoding: .utf8) {
                        completion(.success(resultString))
                    } else {
                        completion(.failure(NSError(domain: "ResponseError", code: 0, userInfo: nil)))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    /*
     * サーバーから投稿履歴を全て取得する
     */
    public func getHistory(completion: @escaping (Result<[History], Error>) -> Void) {
        let url = "http://localhost:8888/RC_SAVE_API/iOS/Controller/ShopingHistoryController.php"
        AF.request(url).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode([History].self, from: data)
                    // デコードが成功したらコールバックで結果を返す
                    completion(.success(decodedData))
                } catch {
                    // デコードエラーが発生した場合
                    print("JSONデコードエラー: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                // リクエストが失敗した場合
                print("Error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    /*
     * サーバーから条件選択された内容を取得する
     */
    public func getResult(janl: String?, count: String?, prodact: String?, completion: @escaping (Result<[ResultModel], Error>) -> Void) {
        let url = "http://localhost:8888/RC_SAVE_API/iOS/Controller/ShopingSearchController.php"
        let searchData: [String: Any] = ["Janl": janl ?? "", "Count": count ?? "", "Prodact": prodact ?? ""]
        
        AF.request(url, method: .post, parameters: searchData, encoding: URLEncoding.default)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        // dataを[ResultModel]にデコード
                        let resultModels = try JSONDecoder().decode([ResultModel].self, from: data)
                        completion(.success(resultModels))
                    } catch {
                        // デコードエラー時の処理
                        completion(.failure(NSError(domain: "ResponseDecodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response"])))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    /*
     * サーバーに選択された投稿を削除する
     */
    public func deleteHistoryData(id: [String], completion: @escaping (Result<String, Error>) -> Void) {
        let url = "http://localhost:8888/RC_SAVE_API/iOS/Controller/ShopingDeleteController.php"
        let parameters: [String: Any] = ["ID": id]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    if let resultString = String(data: data, encoding: .utf8) {
                        completion(.success(resultString))
                    } else {
                        completion(.failure(NSError(domain: "ResponseError", code: 0, userInfo: nil)))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    /*
     * サーバーにお気に入り登録をする
     */
    public func updateHistoryFavData(id: [String], completion: @escaping (Result<String, Error>) -> Void) {
        let url = "http://localhost:8888/RC_SAVE_API/iOS/Controller/ShopingFavController.php"
        let parameters: [String: Any] = ["ID": id]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    if let resultString = String(data: data, encoding: .utf8) {
                        completion(.success(resultString))
                    } else {
                        completion(.failure(NSError(domain: "ResponseError", code: 0, userInfo: nil)))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    /*
     * サーバーに登録しているお気に入りを削除する
     */
    public func deleteHistoryFavData(id: [String], completion: @escaping (Result<String, Error>) -> Void) {
        let url = "http://localhost:8888/RC_SAVE_API/iOS/Controller/ShopingFavDeleteController.php"
        let parameters: [String: Any] = ["ID": id]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    if let resultString = String(data: data, encoding: .utf8) {
                        completion(.success(resultString))
                    } else {
                        completion(.failure(NSError(domain: "ResponseError", code: 0, userInfo: nil)))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    /*
     * サーバーからお気に入りを取得する
     */
    public func getFav(completion: @escaping (Result<[History], Error>) -> Void) {
        let url = "http://localhost:8888/RC_SAVE_API/iOS/Controller/ShopingFavListController.php"
        AF.request(url).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode([History].self, from: data)
                    // デコードが成功したらコールバックで結果を返す
                    completion(.success(decodedData))
                } catch {
                    // デコードエラーが発生した場合
                    print("JSONデコードエラー: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                // リクエストが失敗した場合
                print("Error: \(error)")
                completion(.failure(error))
            }
        }
    }
}

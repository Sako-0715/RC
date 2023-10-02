//
//  HistoryViewController.swift
//  RC
//
//  Created by 酒匂竜也 on 2023/09/30.
//

import UIKit
import RealmSwift

class HistoryViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var data:[RealmModel] = []
    var refreshControl = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        
        // リフレッシュコントロールを初期化し、TableViewに追加
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.addSubview(refreshControl)
        //APIから投稿履歴を取得
        Api()
        
    }
    
    
    func Api() {
        do {
            let realm = try Realm()
            self.data = Array(realm.objects(RealmModel.self).sorted(byKeyPath: "date", ascending: false)) // 日付順にソート
            
            // 画像データが正しく取得できているか確認する
            for shopData in self.data {
                if let imageData = shopData.imageData {
                    print("画像データが存在します。")
                    // imageData に対する追加の処理を行うこともできます
                } else {
                    print("画像データは存在しません。")
                }
            }
            // データ取得完了時にログを出力
            print("データ取得完了。データ件数: \(self.data.count)")
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing() // リフレッシュコントロールを終了
            }
        } catch {
            print("Realmデータの取得エラー: \(error.localizedDescription)")
        }
    }
    
    @objc func refreshData() {
            // 引っ張ってリフレッシュされた時に呼ばれるメソッド
            // データを再取得するための処理をここに追加
            Api()
        }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let imageView = cell.contentView.viewWithTag(1) as? UIImageView
        let janlLabel = cell.contentView.viewWithTag(2) as! UILabel
        let prodact = cell.contentView.viewWithTag(3) as! UILabel
        let price = cell.contentView.viewWithTag(4) as! UILabel
        let date = cell.contentView.viewWithTag(5) as! UILabel
        let shopData = data[indexPath.row]
        
        if indexPath.row < data.count {
            let shopData = data[indexPath.row]
            // 画像を読み込む
            if let imageData = shopData.imageData, let image = UIImage(data: imageData) {
                imageView?.image = image
            } else {
                imageView?.image = UIImage(named: "bkcamera") // 代替のデフォルト画像を設定
            }
            
            janlLabel.text = shopData.janl
            prodact.text = shopData.product
            price.text = "\(shopData.price)"
            date.text = shopData.date
            
            
            //        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
            //        let label = cell.contentView.viewWithTag(2) as! UILabel
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 300
    }
}

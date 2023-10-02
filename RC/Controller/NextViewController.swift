//
//  NextViewController.swift
//  RC
//
//  Created by 酒匂竜也 on 2023/10/01.
//

import UIKit
import RealmSwift

class NextViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate {
    
    var Janl = String()
    var products: Results<RealmModel>? // 商品情報を格納するRealmのResultsオブジェクト
    let realm = try! Realm()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        // Realmで検索を行う
        products = realm.objects(RealmModel.self).filter("janl == %@", Janl)
        if let products = products {
            if products.isEmpty {
                // データが存在しない場合の処理（例: メッセージを表示するなど）
                print("No products found")
            }
        } else {
            // エラーが発生した場合の処理（例: エラーメッセージを表示するなど）
            print("Error fetching products")
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let imageView = cell.contentView.viewWithTag(1) as? UIImageView
        let prodact = cell.contentView.viewWithTag(2) as! UILabel
        let price = cell.contentView.viewWithTag(3) as! UILabel
        let date = cell.contentView.viewWithTag(4) as! UILabel
        
        if let product = products?[indexPath.row] {
            // 商品情報をセルに表示
            prodact.text = product.product
            price.text = "\(product.price)"
            
            // 画像データが存在する場合、セルのイメージビューに表示
            if let imageData = product.imageData, let image = UIImage(data: imageData) {
                imageView?.image = image
            }
            
            // 日付情報を表示（日付のフォーマットは必要に応じて調整）
            date.text = product.date
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 300
    }
    
}

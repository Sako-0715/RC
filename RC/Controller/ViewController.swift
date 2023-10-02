//
//  ViewController.swift
//  RC
//
//  Created by 酒匂竜也 on 2023/09/30.
//

import UIKit
import RealmSwift

class ViewController: UIViewController,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var JanlText: UITextField!
    @IBOutlet weak var PriceText: UITextField!
    @IBOutlet weak var ProdactText: UITextField!
    @IBOutlet weak var InputButton: UIButton!
    
    
    var privateCamera = false
    var JanlPicker = UIPickerView()
    var PricePicker = UIPickerView()
    var ProdactNameString = ""
    let realm = try! Realm()
    var imageData: Data?
    var pickedImage: UIImage?
    
    var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    //ジャンル
    var JanlString = [String]()
    //個数
    var PriceInt = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        JanlText.inputView = JanlPicker
        JanlPicker.delegate = self
        JanlPicker.dataSource = self
        
        JanlText.delegate = self
        
        JanlPicker.tag = 1
        
        PriceText.inputView = PricePicker
        PricePicker.delegate = self
        PricePicker.dataSource = self
        PriceText.delegate = self
        PricePicker.tag = 2
        
        ProdactText.delegate = self
        
        InputButton.isEnabled = false
        // Do any additional setup after loading the view.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            JanlString = Util.Janl()
            return JanlString.count
        case 2:
            PriceInt = ([Int])(1...10)
            return PriceInt.count
        default:
            return 0
        }
    }
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            JanlText.text = JanlString[row]
            JanlText.resignFirstResponder()
            break
        case 2:
            PriceText.text = String(PriceInt[row])
            PriceText.resignFirstResponder()
            break
        default:
            break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return JanlString[row]
        case 2:
            return String(PriceInt[row])
        default:
            return ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
        if JanlText.text?.count ?? 0  > 0 && PriceText.text?.count ?? 0 > 0 && ProdactText.text?.count ?? 0 > 0 {
            
            InputButton.isEnabled = true
            
        } else {
            
            InputButton.isEnabled = false
        }
        
        
    }
    
    
    @IBAction func SendButton(_ sender: Any) {
        // フォームから入力されたデータを取得
                let janl = JanlText.text ?? ""
                let price = Int(PriceText.text ?? "") ?? 0
                let product = ProdactText.text ?? ""
                
                // 保存する日時を取得し、文字列に変換
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let newdateString = dateFormatter.string(from: date)
                
                // Realmにデータを保存
                let realm = try! Realm()
                let shopData = RealmModel()
                shopData.janl = janl
                shopData.price = price
                shopData.product = product
                shopData.date = newdateString
                
                // 画像データも保存する場合は以下のように設定
                shopData.imageData = imageData
                
                // データをRealmに書き込む
                try! realm.write {
                    realm.add(shopData)
                }
                
                // 送信後、フォームをクリア
                ImageView.image = UIImage(named: "bkcamera")
                JanlText.text = ""
                PriceText.text = ""
                ProdactText.text = ""
        }
    
    
        
    @IBAction func tapGesture(_ sender: Any) {
        openCamera()
    }
    
    
    func openCamera(){
        let sourceType:UIImagePickerController.SourceType = .photoLibrary
        // カメラが利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            // インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = true
            privateCamera = true
            //            cameraPicker.showsCameraControls = true
            present(cameraPicker, animated: true, completion: nil)
            
        }else{
            
        }
    }
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            pickedImage = image // 選択された画像を pickedImage に格納
                ImageView.image = pickedImage // 画像を ImageView に表示
            imageData = image.jpegData(compressionQuality: 1.0)
                }
                picker.dismiss(animated: true, completion: nil)
        }
        // 撮影がキャンセルされた時に呼ばれる
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
            
     }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
        
    }

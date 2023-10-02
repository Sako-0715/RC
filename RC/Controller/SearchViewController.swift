//
//  SearchViewController.swift
//  RC
//
//  Created by 酒匂竜也 on 2023/10/01.
//

import UIKit

class SearchViewController: UIViewController,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UINavigationControllerDelegate {
    
    var JanlPicker = UIPickerView()
    var JanlString = [String]()
    @IBOutlet weak var JanlText: UITextField!
    @IBOutlet weak var SearchBT: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        JanlText.inputView = JanlPicker
        JanlPicker.delegate = self
        JanlPicker.dataSource = self
        JanlText.delegate = self
        JanlPicker.tag = 1
        
        SearchBT.isEnabled = false
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
        default:
            break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return JanlString[row]
        default:
            return ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
        if JanlText.text?.count ?? 0  > 0 {
            SearchBT.isEnabled = true
        } else {
            SearchBT.isEnabled = false
        }
    }
    
    @IBAction func SearchButton(_ sender: Any) {
//        if let nextViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "nextVC") as? NextViewController {
//            nextViewController.Janl = JanlText.text ?? ""
//            self.navigationController?.pushViewController(nextViewController, animated: true)
//            
//            
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "nextVC" {
                if let destinationVC = segue.destination as? NextViewController {
                    destinationVC.Janl = JanlText.text ?? ""
                }
            }
        }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

//
//  ViewController.swift
//  taskapp
//
//  Created by 岡山将也 on 2017/11/09.
//  Copyright © 2017年 shouya.okayama. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var pickTextField: UITextField!
    
    let realm = try! Realm()
    var ctUIPicker: UIPickerView!
    var indexPath : IndexPath!
    //var categoryArray = [""]
    var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: false)
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    
    var task: Task!
    var category: Category!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableview.delegate = self
        tableview.dataSource = self
        
        
        ctUIPicker = UIPickerView()
        ctUIPicker.delegate = self
        ctUIPicker.dataSource = self
        ctUIPicker.showsSelectionIndicator = true
        
        let toolbar = UIToolbar(frame: CGRectMake(0,0,0,35))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ViewController.cancel))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ViewController.cancel))
        toolbar.setItems([cancelItem, doneItem], animated: true)
        
        
        self.pickTextField.inputView = ctUIPicker
        self.pickTextField.inputAccessoryView = toolbar
        
        print(taskArray)
        print(categoryArray)
        //let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        //self.view.addGestureRecognizer(tapGesture)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryArray[row].category
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        print(categoryArray[row])
        print(taskArray)
        let categoryNum = categoryArray[row]
        let categoryName = categoryNum.category
        print(categoryName)
        self.pickTextField.text = categoryArray[row].category
        
        let rlmid = try! Realm().objects(Task.self).filter("category.category = %@", categoryName)
        taskArray = rlmid
        tableview.delegate = self
        tableview.dataSource = self
        tableview.reloadData()
        
    }
    func cancel() {
        self.pickTextField.text = ""
        self.pickTextField.endEditing(true)
        
        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.reloadData()
    }
    
    func done() {
        self.pickTextField.endEditing(true)
        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.reloadData()
        print(taskArray)
        print(categoryArray)
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //データの数(セルの数)を返す
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    //各セルの内容を返す
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date as Date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    //各セルを選択したときに実行される
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath: IndexPath){
        performSegue(withIdentifier: "cellSegue", sender: nil)
        
    }
    
    //セルが削除可能なことを伝える
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    //delete が押されたときに呼ばれる
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            // 削除されたタスクを取得する
            let task = self.taskArray[indexPath.row]
            let category = self.categoryArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            center.removePendingNotificationRequests(withIdentifiers: [String(category.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                self.realm.delete(category)
                tableview.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableview.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
            inputViewController.category = taskArray[indexPath!.row].category
            //inputViewController.category = categoryArray[indexPath!.row]
            
            print(inputViewController.task)
            
            print(inputViewController.category)
        } else {
            let task = Task()
            let category = Category()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max(ofProperty: "id")! + 1
            }
            if categoryArray.count != 0 {
                category.id = categoryArray.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
            inputViewController.category = category
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.reloadData()
    }
    func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
}


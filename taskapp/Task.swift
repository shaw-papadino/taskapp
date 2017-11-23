//
//  Task.swift
//  taskapp
//
//  Created by 岡山将也 on 2017/11/13.
//  Copyright © 2017年 shouya.okayama. All rights reserved.
//
import RealmSwift

class Task: Object {
    dynamic var id = 0
    
    dynamic var title = ""
    
    dynamic var contents = ""
    
    dynamic var date = NSDate()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
class Category: Object {
    dynamic var id = 0
    
    dynamic var category = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */



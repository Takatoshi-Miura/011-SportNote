//
//  SettingViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/28.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    // セルの中身
    let cellTitle = ["アカウント","通知"]
    
    
    // セルをタップした時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // タップしたときの選択色を消去
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        // タップしたセルによって遷移先を変える
        if cellTitle[indexPath.row] == "アカウント" {
            // アカウント設定画面へ遷移
            performSegue(withIdentifier: "goSettingAccountViewController", sender: nil)
        } else {
            // 通知設定画面へ遷移
            performSegue(withIdentifier: "goSettingNotificationViewController", sender: nil)
        }
    }
    
    
    // セルの個数を返却
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitle.count
    }
    
    // テーブルの行ごとのセルを返却する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        // セルに表示する値を設定する
        cell.textLabel!.text = cellTitle[indexPath.row]
        return cell
    }


}
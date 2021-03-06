//
//  ResolvedTaskViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/30.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ResolvedTaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // データのないセルを非表示
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 解決済みの課題データを取得
        dataManager.getResolvedTaskData({
            // テーブルビューの更新
            self.tableView?.reloadData()
        })
    }
    
    
    //MARK:- 変数の宣言
    
    var dataManager = DataManager()   // データ用
    var indexPath:Int = 0             // 行番号格納用
    
    
    //MARK:- UIの設定
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK:- テーブルビューの設定
    
    // セルをタップした時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // タップしたときの選択色を消去
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        // タップしたセルの行番号を取得
        self.indexPath = indexPath.row
        
        // 詳細確認画面へ遷移
        performSegue(withIdentifier: "goResolvedTaskDetailViewController", sender: nil)
    }
    
    // 解決済みのTaskDataArrayの項目数を返却
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataManager.taskDataArray.count
    }
    
    // テーブルの行ごとのセルを返却する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 未解決の課題セルを返却
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "resolvedTaskCell", for: indexPath)
        cell.textLabel!.text = dataManager.taskDataArray[indexPath.row].getTitle()
        cell.detailTextLabel!.text = "原因：\(dataManager.taskDataArray[indexPath.row].getCause())"
        cell.detailTextLabel?.textColor = UIColor.systemGray
        return cell
    }
    
    
    //MARK:- 画面遷移
    
    // 画面遷移時に呼ばれる処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goResolvedTaskDetailViewController" {
            // 表示する課題データを課題詳細確認画面へ渡す
            let taskDetailViewController = segue.destination as! TaskDetailViewController
            taskDetailViewController.taskData = dataManager.taskDataArray[indexPath]
            taskDetailViewController.previousControllerName = "ResolvedTaskViewController"
        }
    }
    
    // ResolvedTaskViewControllerに戻ったときの処理
    @IBAction func goToResolvedTaskViewController(_segue:UIStoryboardSegue) {
    }
    
}

//
//  MeasuresDetailViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/29.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class MeasuresDetailViewController: UIViewController,UINavigationControllerDelegate {
    
    //MARK:- ライフサイクルメソッド

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートの指定
        navigationController?.delegate = self
        
        // チェックボックスの設定
        self.checkButton.setImage(uncheckedImage, for: .normal)
        self.checkButton.setImage(checkedImage, for: .selected)

        // 受け取った対策データを表示
        printMeasuresData(taskData)
    }
    
    
    
    //MARK:- 変数の宣言
    var taskData = TaskData()   // 課題データ格納用
    var indexPath = 0           // 行番号格納用
    
    
    
    //MARK:- UIの設定
    
    // テキスト
    @IBOutlet weak var measuresTitleTextField: UITextField!
    @IBOutlet weak var measuresEffectivenessTextView: UITextView!
    
    // チェックボックス
    @IBOutlet weak var checkButton: UIButton!
    private let checkedImage = UIImage(named: "check_on")
    private let uncheckedImage = UIImage(named: "check_off")
    
    // チェックボックスがタップされた時の処理
    @IBAction func checkButtonTap(_ sender: Any) {
        // 選択状態を反転させる
        self.checkButton.isSelected = !self.checkButton.isSelected
    }
    
    
    
    //MARK:- 画面遷移
    
    // 前画面に戻るときに呼ばれる処理
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is TaskDetailViewController {
            // 対策データを更新
            taskData.updateMeasures(measuresTitleTextField.text!, measuresEffectivenessTextView.text!, indexPath)
            
            // チェックボックスが選択されている場合は、この対策を最有力にする
            if self.checkButton.isSelected {
                taskData.setMeasuresPriorityIndex(indexPath)
            }
            
            taskData.updateTaskData()
        }
    }
    
    
    
    //MARK:- その他のメソッド
    
    // データを表示するメソッド
    func printMeasuresData(_ taskData:TaskData) {
        // テキストの表示
        measuresTitleTextField.text        = taskData.getMeasuresTitle(indexPath)
        measuresEffectivenessTextView.text = taskData.getMeasuresEffectiveness(indexPath)
        
        // 最有力の対策ならチェックボックスを選択済みにする
        if taskData.getMeasuresPriorityIndex() == indexPath {
            self.checkButton.isSelected = !self.checkButton.isSelected
        }
    }
    
    // テキストフィールド以外をタップでキーボードを下げる設定
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

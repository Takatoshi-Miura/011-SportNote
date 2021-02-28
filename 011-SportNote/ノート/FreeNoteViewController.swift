//
//  FreeNoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/03.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase

class FreeNoteViewController: UIViewController,UINavigationControllerDelegate,UITextFieldDelegate,UITextViewDelegate {

    //MARK:- ライフサイクルメソッド

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートの設定
        titleTextField.delegate = self
        detailTextView.delegate = self
        navigationController?.delegate = self
        
        // 受け取ったフリーノートデータの文字列を表示
        printText()
        
        // テキストビューの枠線付け
        detailTextView.layer.borderColor = UIColor.systemGray.cgColor
        detailTextView.layer.borderWidth = 1.0
        
        // キーボードでテキストフィールドが隠れない設定
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // ツールバーを作成
        createToolBar()
    }
    
    
    
    //MARK:- 変数の宣言
    
    // フリーノートデータ格納用
    var dataManager = DataManager()
    
    
    //MARK:- UIの設定
    
    // テキスト
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    
    
    //MARK:- 画面遷移
    
    // 前画面に戻るときに呼ばれる処理
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // フリーノートデータを更新
        updateFreeNoteData()
    }
    
    
    //MARK:- データベース関連
    
    // Firebaseのデータを更新するメソッド
    func updateFreeNoteData() {
        dataManager.updateFreeNoteData(titleTextField.text!, detailTextView.text!, {})
    }
    
    
    //MARK:- その他のメソッド
    
    // 文字列表示メソッド
    func printText() {
        titleTextField.text = dataManager.freeNoteData.getTitle()
        detailTextView.text = dataManager.freeNoteData.getDetail()
    }
    
    // キーボードを出したときの設定
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            detailTextView.contentInset = .zero
        } else {
            detailTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        detailTextView.scrollIndicatorInsets = detailTextView.contentInset

        let selectedRange = detailTextView.selectedRange
        detailTextView.scrollRangeToVisible(selectedRange)
    }
    
    // ツールバーを作成するメソッド
    func createToolBar() {
        // ツールバーのインスタンスを作成
        let toolBar = UIToolbar()

        // ツールバーに配置するアイテムのインスタンスを作成
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let okButton: UIBarButtonItem = UIBarButtonItem(title: "完了", style: UIBarButtonItem.Style.plain, target: self, action: #selector(tapOkButton(_:)))

        // アイテムを配置
        toolBar.setItems([flexibleItem, okButton], animated: true)

        // ツールバーのサイズを指定
        toolBar.sizeToFit()
        
        // テキストフィールドにツールバーを設定
        titleTextField.inputAccessoryView = toolBar
        detailTextView.inputAccessoryView = toolBar
    }
    
    // OKボタンの処理
    @objc func tapOkButton(_ sender: UIButton){
        // キーボードを閉じる
        self.view.endEditing(true)
    }

}

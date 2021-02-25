//
//  CreateAccountViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/08/18.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class CreateAccountViewController: UIViewController {

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // データ取得
        loadFreeNoteData()
        loadTargetData()
        loadNoteData()
        loadTaskData()
    }
    

    //MARK:- UIの設定
    
    // テキストフィールド
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // アカウント作成ボタンの処理
    @IBAction func createAccountButton(_ sender: Any) {
        // アドレス,パスワード名,アカウント名の入力を確認
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            // アドレス,パスワード名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty {
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            
            // アカウント作成処理
            self.createAccount(mail: address, password: password)
        }
    }
    
    // 閉じるボタンの処理
    @IBAction func closeButton(_ sender: Any) {
        // モーダルを閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK:- 変数の宣言
    
    // データ格納用
    var dataManager = DataManager()
    var taskDataArray = [TaskData]()
    
    
    //MARK:- データベース関連
    
    // アカウントを作成するメソッド
    func createAccount(mail address:String,password pass:String) {
        // HUDで処理中を表示
        SVProgressHUD.show(withStatus: "アカウントを作成しています")
        
        // アカウント作成処理
        Auth.auth().createUser(withEmail: address, password: pass) { authResult, error in
            if error == nil {
                // エラーなし
            } else {
                // エラーのハンドリング
                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                    switch errorCode {
                        case .invalidEmail:
                            SVProgressHUD.showError(withStatus: "メールアドレスの形式が違います。")
                        case .emailAlreadyInUse:
                            SVProgressHUD.showError(withStatus: "既にこのメールアドレスは使われています。")
                        case .weakPassword:
                            SVProgressHUD.showError(withStatus: "パスワードは6文字以上で入力してください。")
                        default:
                            SVProgressHUD.showError(withStatus: "エラーが起きました。しばらくしてから再度お試しください。")
                    }
                    return
                }
            }
            // ユーザーデータを削除
            let userData = UserData()
            userData.removeUserData()
            
            // FirebaseのユーザーIDをセット
            UserDefaults.standard.set(Auth.auth().currentUser!.uid, forKey: "userID")
            UserDefaults.standard.set(address, forKey:"address")
            UserDefaults.standard.set(pass,forKey:"password")
            
            // データの引継ぎを通知
            SVProgressHUD.show(withStatus: "データの引継ぎをしています")
            
            // FirebaseアカウントのIDでデータを複製
            self.reproductionUserData()
        }
    }
    
    // データを複製するメソッド
    func reproductionUserData() {
        // フリーノートデータを複製
        createFreeNoteData()
        
        // 目標データを複製
        for targetData in dataManager.targetDataArray {
            createTargetData(data: targetData)
        }
        
        // ノートデータを複製
        for noteData in dataManager.noteDataArray {
            createNoteData(data: noteData)
        }
        
        // 課題データを複製
        for taskData in taskDataArray {
            createTaskData(data: taskData)
        }
        
        // ユーザーデータを作成
        let userData = UserData()
        userData.createUserData()
        
        // ノート画面へ遷移
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10.0) {
            // ノート画面へ遷移
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "TabBarController")
            self.present(nextView, animated: true, completion: nil)
        }
    }
    
    // Firebaseからフリーノートデータを読み込むメソッド
    func loadFreeNoteData() {
        dataManager.getFreeNoteData({})
    }
    
    // Firebaseから目標データを取得するメソッド
    func loadTargetData() {
        dataManager.getTargetData({})
    }
    
    // Firebaseからデータを取得するメソッド
    func loadNoteData() {
        dataManager.getNoteData({})
    }
    
    // 課題データを取得するメソッド
    func loadTaskData() {        
        // 配列の初期化
        taskDataArray = []
        
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        
        // ユーザーの課題データ取得
        let db = Firestore.firestore()
        db.collection("TaskData")
            .whereField("userID", isEqualTo: userID)
            .whereField("isDeleted", isEqualTo: false)
            .order(by: "taskID", descending: true)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let taskDataCollection = document.data()
                
                    // 取得データを基に、課題データを作成
                    let databaseTaskData = TaskData()
                    databaseTaskData.setTaskID(taskDataCollection["taskID"] as! Int)
                    databaseTaskData.setTaskTitle(taskDataCollection["taskTitle"] as! String)
                    databaseTaskData.setTaskCause(taskDataCollection["taskCause"] as! String)
                    databaseTaskData.setTaskAchievement(taskDataCollection["taskAchievement"] as! Bool)
                    databaseTaskData.setIsDeleted(taskDataCollection["isDeleted"] as! Bool)
                    databaseTaskData.setUserID(taskDataCollection["userID"] as! String)
                    databaseTaskData.setCreated_at(taskDataCollection["created_at"] as! String)
                    databaseTaskData.setUpdated_at(taskDataCollection["updated_at"] as! String)
                    databaseTaskData.setMeasuresData(taskDataCollection["measuresData"] as! [String:[[String:Int]]])
                    databaseTaskData.setMeasuresPriority(taskDataCollection["measuresPriority"] as! String)
                    
                    // 課題データを格納
                    self.taskDataArray.append(databaseTaskData)
                }
            }
        }
    }
    
    // フリーノートデータを作成するメソッド
    func createFreeNoteData() {
        // FirebaseアカウントのuserIDを取得
        let userID = Auth.auth().currentUser!.uid
        
        // ユーザーUIDをセット
        dataManager.freeNoteData.setUserID(userID)
        
        // Firebaseにデータを保存
        let db = Firestore.firestore()
        db.collection("FreeNoteData").document("\(dataManager.freeNoteData.getUserID())").setData([
            "title"      : dataManager.freeNoteData.getTitle(),
            "detail"     : dataManager.freeNoteData.getDetail(),
            "userID"     : dataManager.freeNoteData.getUserID(),
            "created_at" : dataManager.freeNoteData.getCreated_at(),
            "updated_at" : dataManager.freeNoteData.getUpdated_at()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    // 目標データを作成するメソッド
    func createTargetData(data targetData:TargetData) {
        // FirebaseアカウントのuserIDを取得
        let userID = Auth.auth().currentUser!.uid
        
        // userIDをセット
        targetData.setUserID(userID)
        
        // Firebaseにデータを保存
        let db = Firestore.firestore()
        db.collection("TargetData").document("\(userID)_\(targetData.getYear())_\(targetData.getMonth())").setData([
            "year"       : targetData.getYear(),
            "month"      : targetData.getMonth(),
            "detail"     : targetData.getDetail(),
            "isDeleted"  : targetData.getIsDeleted(),
            "userID"     : targetData.getUserID(),
            "created_at" : targetData.getCreated_at(),
            "updated_at" : targetData.getUpdated_at()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    // ノートデータを複製するメソッド
    func createNoteData(data noteData:NoteData) {
        // FirebaseアカウントのuserIDを取得
        let userID = Auth.auth().currentUser!.uid
        
        // userIDをセット
        noteData.setUserID(userID)
        
        // Firebaseにデータを保存
        let db = Firestore.firestore()
        db.collection("NoteData").document("\(noteData.getUserID())_\(noteData.getNoteID())").setData([
            "noteID"                : noteData.getNoteID(),
            "noteType"              : noteData.getNoteType(),
            "year"                  : noteData.getYear(),
            "month"                 : noteData.getMonth(),
            "date"                  : noteData.getDate(),
            "day"                   : noteData.getDay(),
            "weather"               : noteData.getWeather(),
            "temperature"           : noteData.getTemperature(),
            "physicalCondition"     : noteData.getPhysicalCondition(),
            "purpose"               : noteData.getPurpose(),
            "detail"                : noteData.getDetail(),
            "target"                : noteData.getTarget(),
            "consciousness"         : noteData.getConsciousness(),
            "result"                : noteData.getResult(),
            "reflection"            : noteData.getReflection(),
            "taskTitle"             : noteData.getTaskTitle(),
            "measuresTitle"         : noteData.getMeasuresTitle(),
            "measuresEffectiveness" : noteData.getMeasuresEffectiveness(),
            "isDeleted"             : noteData.getIsDeleted(),
            "userID"                : noteData.getUserID(),
            "created_at"            : noteData.getCreated_at(),
            "updated_at"            : noteData.getUpdated_at()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    // 課題データを作成するメソッド
    func createTaskData(data taskData:TaskData) {
        // FirebaseアカウントのuserIDを取得
        let userID = Auth.auth().currentUser!.uid
        
        // ユーザーUIDをセット
        taskData.setUserID(userID)
        
        // Firebaseにアクセス
        let db = Firestore.firestore()
        db.collection("TaskData").document("\(userID)_\(taskData.getTaskID())").setData([
            "taskID"           : taskData.getTaskID(),
            "taskTitle"        : taskData.getTaskTitle(),
            "taskCause"        : taskData.getTaskCouse(),
            "taskAchievement"  : taskData.getTaskAchievement(),
            "isDeleted"        : taskData.getIsDeleted(),
            "userID"           : taskData.getUserID(),
            "created_at"       : taskData.getCreated_at(),
            "updated_at"       : taskData.getUpdated_at(),
            "measuresData"     : taskData.getMeasuresData(),
            "measuresPriority" : taskData.getMeasuresPriority()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }

}

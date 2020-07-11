//
//  NoteDetailContentViewController.swift
//  
//
//  Created by Takatoshi Miura on 2020/07/11.
//

import UIKit

class NoteDetailContentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // テキストビューに表示
        physicalConditionTextView.text = ""
        purposeTextView.text = ""
        detailTextView.text = ""
        reflectionTextView.text = ""
    }
    
    //MARK:- UIの設定
    
    @IBOutlet weak var physicalConditionTextView: UITextView!
    @IBOutlet weak var purposeTextView: UITextView!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var reflectionTextView: UITextView!
    

}

//
//  ChatViewController.swift
//  ChatApp1
//
//  Created by Hitomi Nagano on 2021/04/13.
//

import UIKit
import ChameleonFramework
import Firebase

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    let screenSize = UIScreen.main.bounds.size
    var chatArray = [Message]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        messageTextField.delegate = self

        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "Cell")
        // テーブルの高さを可変にする
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        // キーボードを開いた時、テキストフィールドも上に移動
        // NotificationCenter：キーボードの表示・非表示時を検知
        // 参考：https://hiromiick.com/swift-keyboard-notification/
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)

        fetchCommentsData()

        tableView.separatorStyle = .none
    }

    @objc func keyboardWillShow(_ notification: NSNotification) {
        let keyboardHeight = ((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as Any) as AnyObject).cgRectValue.height
        messageTextField.frame.origin.y = screenSize.height - keyboardHeight - messageTextField.frame.height
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        messageTextField.frame.origin.y = screenSize.height - messageTextField.frame.height
        // guard let：nilじゃなければ取り出す
        // @see https://programfromscratch.com/Swift入門-guard-letの使い方/
        guard let _ = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration) {
            let transform = CGAffineTransform(translationX: 0, y: 0)
            self.view.transform = transform
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        messageTextField.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // メッセージの数
        return chatArray.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell

        cell.messageLabel.text = chatArray[indexPath.row].message
        cell.userNameLabel.text = chatArray[indexPath.row].sender
        cell.iconImageView.image = UIImage(named: "dogAvatarImage")
        // @see 角丸：https://qiita.com/arthur87/items/a1aa46e9f498d85d6546
        cell.messageLabel.layer.cornerRadius = 20
        cell.messageLabel.layer.masksToBounds = true

        if cell.userNameLabel.text == (Auth.auth().currentUser?.email!) {
            cell.messageLabel.backgroundColor = UIColor.flatGreen()
        } else {
            cell.messageLabel.backgroundColor = UIColor.flatBlue()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    @IBAction func postComment(_ sender: Any) {
        messageTextField.endEditing(true)
        messageTextField.isEnabled = false
        sendButton.isEnabled = false

        if messageTextField.text!.count > 15 {
            print("15文字以上が入力された")
            return
        }

        // @see https://firebase.google.com/docs/database/ios/read-and-write?hl=ja
        let chatDB = Database.database().reference().child("chats")
        // Dictionary 型で内容を送信
        let messageInfo = [
            "sender": Auth.auth().currentUser?.email,
            "message": messageTextField.text!
        ]
        // chatDB に入れる
        // @see https://firebase.google.com/docs/database/ios/read-and-write?hl=ja
        chatDB.childByAutoId().setValue(messageInfo) {(error, result) in
              if let error = error {
                print("Data could not be saved: \(error).")
              } else {
                print("Data saved successfully!")
                self.messageTextField.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextField.text = ""
              }
        }
    }

    func fetchCommentsData() {
        let fetchDataRef = Database.database().reference().child("chats")
        // 新しく更新があったときだけ取得したい
        fetchDataRef.observe(.childAdded) { (snapShot) in
            let snapShotData = snapShot.value as AnyObject
            let text = snapShotData.value(forKey: "message")
            let sender = snapShotData.value(forKey: "sender")
            let message = Message()
            message.message = text as! String
            message.sender = sender as! String

            self.chatArray.append(message)
            self.tableView.reloadData()
        }
    }
}

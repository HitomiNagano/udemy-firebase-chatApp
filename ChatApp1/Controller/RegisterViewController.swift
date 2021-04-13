//
//  RegisterViewController.swift
//  ChatApp1
//
//  Created by Hitomi Nagano on 2021/04/13.
//

import UIKit
import Firebase
import Lottie

class RegisterViewController: UIViewController {
    var loading = LottieLoading()

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    // Firebase にユーザーを作成する
    @IBAction func registerNewUser(_ sender: Any) {
        // @see https://firebase.google.com/docs/auth/ios/start?hl=ja#sign_up_new_users
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { authResult, error in

            self.loading.startAnimation()

            if error != nil {
                print(error as Any)
            } else {
                print("ユーザーの作成が成功しました")
                self.loading.stopAnimation()
                self.performSegue(withIdentifier: "chat", sender: nil)
            }
        }
    }
}

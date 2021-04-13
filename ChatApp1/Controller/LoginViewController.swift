//
//  LoginViewController.swift
//  ChatApp1
//
//  Created by Hitomi Nagano on 2021/04/13.
//

import UIKit
import Firebase
import Lottie

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    var loading = LottieLoading()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func login(_ sender: Any) {
        // @see https://firebase.google.com/docs/auth/ios/facebook-login?hl=ja#authenticate_with_firebase
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            self.loading.startAnimation()

            if error != nil {
                print(error as Any)
            } else {
                print("ログインが成功しました")
                self.loading.stopAnimation()
                self.performSegue(withIdentifier: "chat", sender: nil)
            }
        }
    }
}

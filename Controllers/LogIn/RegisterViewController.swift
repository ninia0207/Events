//
//  RegisterViewController.swift
//  Events
//
//  Created by Ninia Sabadze on 06.02.24.
//

import UIKit

class RegisterViewController: UIViewController {

    struct Constants{
        static let cornerRadius : CGFloat = 8.0
    }
    
    private let emailField : UITextField = {
        let field = UITextField()
        field.placeholder = "Email"
        field.returnKeyType = .next
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Constants.cornerRadius
        field.backgroundColor = .secondarySystemBackground
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        return field
    }()
    
    private let usernameField : UITextField = {
        let field = UITextField()
        field.placeholder = "Username"
        field.returnKeyType = .next
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Constants.cornerRadius
        field.backgroundColor = .secondarySystemBackground
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        return field
    }()
    
    private let passwordField : UITextField = {
        let field = UITextField()
        field.isSecureTextEntry = true
        field.placeholder = "Password"
        field.returnKeyType = .continue
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Constants.cornerRadius
        field.backgroundColor = .secondarySystemBackground
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        //field.autocorrectionType = .no
        field.textContentType = .oneTimeCode
        return field
    }()
    
    //buttons
    private let registerButton : UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.cornerRadius
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        view.addSubview(usernameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(registerButton)
        
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        usernameField.frame = CGRect(
            x: 20,
            y: view.safeAreaInsets.top+100,
            width: view.width-40,
            height: 52
        )
        
        emailField.frame = CGRect(
            x: 20,
            y: usernameField.bottom+10,
            width: view.width-40,
            height: 52
        )
        
        passwordField.frame = CGRect(
            x: 20,
            y: emailField.bottom+10,
            width: view.width-40,
            height: 52
        )
        
        registerButton.frame = CGRect(
            x: 20,
            y: passwordField.bottom+10,
            width: view.width-40,
            height: 52
        )
    }
    
    @objc private func didTapRegister(){
        emailField.resignFirstResponder()
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty, password.count >= 8,
              let username = usernameField.text, !username.isEmpty else{
     
            return
        }
        
       // Firebase Create Account
        AuthManager.shared.registerNewUser(username: username, email: email, password: password) {registered in
            DispatchQueue.main.async {
                if registered{
                    //successfully registered
                    //self.alertUserSuccessfulRegistration(message: "You registered successfully. Please log into your account.")
                    self.dismiss(animated: true, completion: nil)
                    
                }else{
                    //failed
                    self.alertUserRegisterError(message: "Registration failed. Please enter all information.")
                }
                
            }
        }
        
        
    }
    
    func alertUserRegisterError(message: String){
        let alert = UIAlertController(title: "Registration",
                                      message: message,
                                      preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        self.present(alert, animated: true)
    }
    
    func alertUserSuccessfulRegistration(message: String){
        let alert = UIAlertController(title: "Registration",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", 
                                      style: .cancel,
                                      handler: nil))
        self.present(alert, animated: true)
    }
}

extension RegisterViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField{
            emailField.becomeFirstResponder()
        }
        else if textField == emailField{
            passwordField.becomeFirstResponder()
        }
        else{
            didTapRegister()
        }
        
        return true
    }
}


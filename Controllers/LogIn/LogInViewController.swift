//
//  LogInViewController.swift
//  Events
//
//  Created by Ninia Sabadze on 06.02.24.
//

import UIKit

class LogInViewController: UIViewController {

    struct Constants{
        static let cornerRadius : CGFloat = 8.0
    }
    
    
    //unanimous closure
    private let usernameEmailField : UITextField = {
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
        return field
    }()
    
    //buttons
    private let loginButton : UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.cornerRadius
        button.backgroundColor = .systemGray
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let createAccountButton : UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Create an Account", for: .normal)
        
        return button
    }()
    
    
    //header
    private let headerView : UIView = {
        let header = UIView()
        header.layer.masksToBounds = true
        let backgroundView = UIImageView(image: UIImage(named: "top_gradient"))
        header.addSubview(backgroundView)
        return header
    }()
    
    //footer
    private let footerView : UIView = {
        let footer = UIView()
        footer.layer.masksToBounds = true
        let backgroundView = UIImageView(image: UIImage(named: "bottom_gradient"))
        footer.addSubview(backgroundView)
        return footer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.addTarget(self,
                              action: #selector(didTapLoginButton),
                              for: .touchUpInside)
        createAccountButton.addTarget(self,
                              action: #selector(didTapCreateAccountButton),
                              for: .touchUpInside)
        
        usernameEmailField.delegate = self
        passwordField.delegate = self
        addSubviews()
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //assign frames
        
        headerView.frame = CGRect(
            x: 0,
            y: 0.0,
            width: view.width,
            height: view.height/3.0
        )
        
        usernameEmailField.frame = CGRect(
            x: 25,
            y: headerView.bottom + 40,
            width: view.width-50,
            height: 52.0
        )
        
        passwordField.frame = CGRect(
            x: 25,
            y: usernameEmailField.bottom + 10,
            width: view.width-50,
            height: 52.0
        )
        
        loginButton.frame = CGRect(
            x: 25,
            y: passwordField.bottom + 10,
            width: view.width-50,
            height: 52.0
        )
        
        createAccountButton.frame = CGRect(
            x: 25,
            y: loginButton.bottom + 10,
            width: view.width-50,
            height: 52.0
        )
        configureHeaderView()
        //configureFooterView()
    }
    
    private func configureHeaderView(){
        guard headerView.subviews.count == 1 else{
            return
        }
        
        guard let backgroundView = headerView.subviews.first else{
            return
        }
        backgroundView.frame = headerView.bounds
        
        //add logo
        let imageView = UIImageView(image: UIImage(named: "bga_logo"))
        headerView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(
            x: headerView.width/3.0,
            y: view.safeAreaInsets.top,
            width: headerView.width/3.5,
            height: headerView.height - view.safeAreaInsets.top
        )
        
    }
    
    private func configureFooterView(){
        guard footerView.subviews.count == 1 else{
            return
        }
        
        guard let backgroundView = footerView.subviews.first else{
            return
        }
        
        backgroundView.frame = footerView.bounds
        
    }
    
    
    private func addSubviews(){
        view.addSubview(usernameEmailField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(headerView)
        view.addSubview(createAccountButton)
        view.addSubview(footerView)
    }
    
    @objc private func didTapLoginButton(){
        passwordField.resignFirstResponder()
        usernameEmailField.resignFirstResponder()
        
        guard let usernameEmail = usernameEmailField.text, !usernameEmail.isEmpty,
              let password = passwordField.text, !password.isEmpty, password.count >= 8 else{
            
            alertUserLoginError()
            return
        }
        
        //Firebase Login
        //login functionality
        var username: String?
        var email: String?
        
        if usernameEmail.contains("@"), usernameEmail.contains("."){
            //email
            email = usernameEmail
        }else{
            //username
            username = usernameEmail
        }
        
        
        //Firebase Log In User
        AuthManager.shared.logInUser(username: username, email: email, password: password){result in
            DispatchQueue.main.async{
                if result{
                    //user logged in
                    self.dismiss(animated: true, completion: nil)
                    
                }else{
                    //error occured
                    self.alertUserLoginError()
                }
                
            }
            
        }
    }
    
    func alertUserLoginError(){
        let alert = UIAlertController(title: "Log In Error",
                                      message: "Please enter all information correctly",
                                      preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        self.present(alert, animated: true)
    }
    
    @objc private func didTapCreateAccountButton(){
        let vc = RegisterViewController()
        vc.title = "Create Account"
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

extension LogInViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if textField == usernameEmailField{
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField{
            didTapLoginButton()
        }
        
        return true
    }
}


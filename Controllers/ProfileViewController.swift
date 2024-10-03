//
//  ProfileViewController.swift
//  Events
//
//  Created by Ninia Sabadze on 06.02.24.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    private let adminLabel: UILabel = {
       let label = UILabel()
        label.text = "Admin"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    private let studentLabel: UILabel = {
       let label = UILabel()
        label.text = "Student"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    private let composeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium)),
                        for: .normal)
        button.layer.cornerRadius = 30
        button.layer.shadowOpacity = 0.4
        button.layer.shadowColor = UIColor.label.cgColor
        button.layer.shadowRadius = 10
        return button
    }()
    
    private let logOutButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log Out", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 6
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let userEmail = Auth.auth().currentUser?.email
        //let userEmail = currentUser.email
        //let testEmail = "test1@user.com"
        
        Auth.auth().addStateDidChangeListener{(auth, user) in
            if let user = user{
                DatabaseManager.shared.isAdmin(email: user.email!){ (isAdmin) in
                    if isAdmin {
                        self.studentLabel.removeFromSuperview()
                        self.view.addSubview(self.composeButton)
                        self.view.addSubview(self.adminLabel)
                    } else {
                        self.composeButton.removeFromSuperview()
                        self.adminLabel.removeFromSuperview()
                        self.view.addSubview(self.studentLabel)
                    }
                }
            }
        }
        
//        DatabaseManager.shared.isAdmin(email: userEmail!){ (isAdmin) in
//            if isAdmin {
//                self.view.addSubview(self.composeButton)
//                self.view.addSubview(self.adminLabel)
//            } else {
//                self.view.addSubview(self.studentLabel)
//            }
//        }
        
        //view.addSubview(composeButton)
        view.addSubview(logOutButton)
        
        composeButton.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
        logOutButton.addTarget(self, action: #selector(logOut), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        composeButton.frame = CGRect(
            x: view.frame.width - 80 - 16,
            y: view.frame.height - 80 - 16 - view.safeAreaInsets.bottom,
            width: 60,
            height: 60
        )
        logOutButton.frame = CGRect(
            x: 20,
            y: 400,
            width: view.frame.size.width-40,
            height: 50
        )
        adminLabel.frame = CGRect(
            x: (view.frame.size.width-70)/2,
            y: 200,
            width: view.frame.size.width-40,
            height: 50
        )
        studentLabel.frame = CGRect(
            x: (view.frame.size.width-70)/2,
            y: 200,
            width: view.frame.size.width-40,
            height: 50
        )
    }
    
    @objc private func didTapCreate(){
        let vc = PublishViewController()
        vc.title = "Publish New Event"
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
        
    @objc private func logOut(){
        //Firebase Log Out User
        AuthManager.shared.logOut(completion: {success in
            DispatchQueue.main.async {
                if success{
                    //present log in
                    let loginVC = LogInViewController()
                    loginVC.modalPresentationStyle = .fullScreen
                    self.present(loginVC, animated: true){
                        self.navigationController?.popToRootViewController(animated: false)
                        self.tabBarController?.selectedIndex = 0
                    }
                }else{
                    //error occured
                    fatalError("Could not log out the user")
                }
            }
        })
    }

}

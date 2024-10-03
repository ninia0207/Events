//
//  EventActionsTableViewCell.swift
//  Events
//
//  Created by Ninia Sabadze on 27.02.24.
//

import UIKit
import FirebaseAuth
protocol PostActionsTableViewCellDelegate: AnyObject{
    func didTapAttendButton()
    func didTapSaveButton()
    func didTapDeleteButton()
}

class EventActionsTableViewCell: UITableViewCell {
    
    weak var delegate: PostActionsTableViewCellDelegate?
    
    static let identifier = "EventActionsTableViewCell"
    
    private let attendButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let image = UIImage(systemName: "checkmark.circle", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemTeal
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let image = UIImage(systemName: "bookmark", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemTeal
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let image = UIImage(systemName: "trash", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemRed
        return button
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(attendButton)
        contentView.addSubview(saveButton)
        
        let userEmail = (Auth.auth().currentUser?.email)!;
        Auth.auth().addStateDidChangeListener{(auth, user) in
            if let user = user{
                DatabaseManager.shared.isAdmin(email: user.email!){ (isAdmin) in
                    if isAdmin {
                        self.contentView.addSubview(self.deleteButton)
                    }else{
                        self.deleteButton.removeFromSuperview()
                    }
                }
            }
        }
//        DatabaseManager.shared.isAdmin(email: userEmail){ (isAdmin) in
//            if isAdmin {
//                self.contentView.addSubview(self.deleteButton)
//            }
//        }
        
        
        attendButton.addTarget(self,
                             action: #selector(didTapAttendButton),
                             for: .touchUpInside)
        saveButton.addTarget(self,
                             action: #selector(didTapSaveButton),
                             for: .touchUpInside)
        deleteButton.addTarget(self,
                             action: #selector(didTapDeleteButton),
                             for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc private func didTapAttendButton(){
        delegate?.didTapAttendButton()
    }
    
    @objc private func didTapSaveButton(){
        delegate?.didTapSaveButton()
    }
    
    @objc private func didTapDeleteButton(){
        delegate?.didTapDeleteButton()
    }
    
    public func configure(){
        //configure the cell
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //like, send
        
        
        let buttonSize = contentView.height-10
        
        let buttons = [attendButton, saveButton]
        for x in 0..<buttons.count{
            let button = buttons[x]
            button.frame = CGRect(
                x: (CGFloat(x)*buttonSize) + (10*CGFloat(x+1)),
                y: 5,
                width: buttonSize,
                height: buttonSize
            )
        }
        
        deleteButton.frame = CGRect(
            x: contentView.right - 50,
            y: 5,
            width: buttonSize,
            height: buttonSize
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

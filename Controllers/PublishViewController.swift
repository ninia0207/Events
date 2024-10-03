//
//  PublishViewController.swift
//  Events
//
//  Created by Ninia Sabadze on 06.02.24.
//

import UIKit

class PublishViewController: UIViewController {
    
    //Title Field
    //Image Header
    //Description
    //Date
    
    private let titleField : UITextField = {
        let field = UITextField()
        field.placeholder = "Enter Title..."
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.autocapitalizationType = .words
        field.autocorrectionType = .yes
        field.layer.cornerRadius = 6.5
        field.layer.masksToBounds = true
        field.backgroundColor = .secondarySystemBackground
        return field
    }()
    
    private let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(systemName: "photo")
        imageView.backgroundColor = .tertiarySystemBackground
        
        return imageView
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = true
        textView.font = .systemFont(ofSize: 15)
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 6.5
        return textView
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        
        return datePicker
    }()
    
    private var selectedHeaderImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(headerImageView)
        view.addSubview(textView)
        view.addSubview(titleField)
        view.addSubview(datePicker)
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(didTapHeader))
        headerImageView.addGestureRecognizer(tap)
        configureButtons()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        titleField.frame = CGRect(
            x: 10,
            y: view.safeAreaInsets.top,
            width: view.width - 20,
            height: 50
        )
        headerImageView.frame = CGRect(
            x: 0,
            y: titleField.bottom + 10,
            width: view.width,
            height: 160
        )
        textView.frame = CGRect(
            x: 10,
            y: headerImageView.bottom+10,
            width: view.width-20,
            height: 400
        )
        datePicker.frame = CGRect(
            x: 10,
            y: textView.bottom + 5,
            width: view.width/2,
            height: 50
        )
    }
    
    @objc private func didTapHeader(){
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func configureButtons(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .done,
            target: self,
            action: #selector(didTapCancel)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Publish",
            style: .done,
            target: self,
            action: #selector(didTapPublish)
        )
    }
    
    @objc private func didTapCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapPublish(){
        guard let title = titleField.text,
              let body = textView.text,
              let headerImage = selectedHeaderImage,
        !title.trimmingCharacters(in: .whitespaces).isEmpty,
        !body.trimmingCharacters(in: .whitespaces).isEmpty else{
            return
        }
        
        //upload header image
        
        //insert post into db
        
        let eventId = UUID().uuidString
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yy HH:mm"
        
        let filename = "\(eventId).png"
        
        let event = Event(
            id: eventId,
            title: title,
            ImageURL: filename,
            description: body,
            date: dateFormatter.string(from: datePicker.date),
            attending: 0
        )
        
        guard let data = headerImage.pngData() else {
            
            return
            
        }
        
        StorageManager.shared.uploadEventHeaderImage(with: data,
                                                   fileName: filename,
                                                   completion: {result in
            switch result {
                
            case .success(let downloadUrl):
                UserDefaults.standard.set(downloadUrl, forKey: "event_image_url")
                print(downloadUrl)
            case .failure(let error):
                print("Storage manager error: \(error)")
            }
        })
        
        DatabaseManager.shared.insertNewEvent(with: event) { inserted in
            DispatchQueue.main.async {
                if inserted{
                    //successfully inserted
                    self.dismiss(animated: true, completion: nil)
                    
                }else{
                    //failed
                    self.alertUserUploadError(message: "Upload failed. Try again.")
                }
                
            }
        }
    }
    
    func alertUserUploadError(message: String = "Please enter all information"){
        let alert = UIAlertController(title: "Upload",
                                      message: message,
                                      preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        self.present(alert, animated: true)
    }
}

extension PublishViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.originalImage] as? UIImage else{
            return
        }
        
        selectedHeaderImage = image
        headerImageView.image = image
    }
}

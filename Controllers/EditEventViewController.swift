//
//  EditEventViewController.swift
//  Events
//
//  Created by Ninia Sabadze on 09.04.24.
//

import UIKit

public class EditEventViewControllerModel {
    let eventTitle: String?
    let imageUrl: URL?
    let eventDescription: String?
    let eventDate: String?
    var imageData: Data?
    
    init(eventTitle: String?, imageUrl: URL?, eventDescription: String?, eventDate: String?){
        self.imageUrl = imageUrl
        self.eventTitle = eventTitle
        self.eventDescription = eventDescription
        self.eventDate = eventDate
    }
}

class EditEventViewController: UIViewController {
    
    public var eventID: String = ""
    public var eventTitle: String = ""
    public var imageUrl: URL? = nil
    public var eventDescription: String = ""
    public var eventDate: String = ""
    public var imageData: Data?
    //Title Field
    //Image Header
    //Description
    //Date
    
    private let titleField : UITextField = {
        let field = UITextField()
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
        //imageView.image = UIImage(systemName: "photo")
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
        configure()
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
            title: "Save",
            style: .done,
            target: self,
            action: #selector(didTapSave)
        )
    }
    
    private func configure(){
        if let data = imageData{
            headerImageView.image = UIImage(data: data)
        }
        else if let url = imageUrl{
            // fetch and cache image
            
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data else{
                    return
                }
                
                self!.imageData = data
                DispatchQueue.main.async {
                    self?.headerImageView.image = UIImage(data: data)
                }
                
            }
            
            task.resume()
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yy HH:mm"
        titleField.text = eventTitle
        textView.text = eventDescription
        datePicker.date = dateFormatter.date(from: eventDate)!

    }
    
    @objc private func didTapCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapSave(){
        guard let title = titleField.text,
              let body = textView.text,
              let headerImage = selectedHeaderImage,
        !title.trimmingCharacters(in: .whitespaces).isEmpty,
        !body.trimmingCharacters(in: .whitespaces).isEmpty else{
            return
        }
        
        let editId = UUID().uuidString
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yy HH:mm"
        
        let filename = "\(eventID)_\(editId).png"
        
        let event = Event(
            id: eventID,
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
        
        DatabaseManager.shared.updateEvent(event: event) { error in
            if let error = error {
                print("Error updating event: \(error.localizedDescription)")
            } else {
                print("Event updated successfully")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func alertUserUploadError(message: String = "Please enter all information"){
        let alert = UIAlertController(title: "Save",
                                      message: message,
                                      preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        self.present(alert, animated: true)
    }
}

extension EditEventViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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


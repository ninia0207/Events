//
//  SingleEventViewController.swift
//  Events
//
//  Created by Ninia Sabadze on 27.02.24.
//

import UIKit
import UserNotifications
import FirebaseAuth

class SingleEventViewController: UIViewController{

    private var event: Event?
    
    
    private let tableView: UITableView = {
        let tableView = UITableView()

        tableView.register(EventActionsTableViewCell.self,
                           forCellReuseIdentifier: EventActionsTableViewCell.identifier)
        tableView.register(EventHeaderTableViewCell.self,
                           forCellReuseIdentifier: EventHeaderTableViewCell.identifier)
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.clipsToBounds = true
        button.backgroundColor = .systemBackground
        return button
        
    }()
    
    
    
    init(event: Event) {
        self.event = event
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        
    }

}

extension SingleEventViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5 //title, image, description, date, actions
    }
    
    @objc public func didTapEditEventButton(){
        let vc = EditEventViewController()
        vc.title = "Edit Event"
        present(UINavigationController(rootViewController: vc), animated: true)
        vc.eventTitle = event!.title
        vc.eventDescription = event!.description
        vc.eventDate = event!.date
        vc.imageUrl = URL(string: event!.ImageURL)
        vc.eventID = event!.id
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        switch index {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = event?.title
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = .systemFont(ofSize: 25, weight: .bold)
            cell.selectionStyle = .none
            
            let userEmail = Auth.auth().currentUser?.email
            //let testEmail = "test1@user.com"
            Auth.auth().addStateDidChangeListener{(auth, user) in
                if let user = user{
                    DatabaseManager.shared.isAdmin(email: user.email!){ (isAdmin) in
                        if isAdmin {
                            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                                title: "Edit",
                                style: .done,
                                target: self,
                                action: #selector(self.didTapEditEventButton)
                            )
                        }else{
                            self.navigationItem.rightBarButtonItem = nil
                        }
                    }
                }
            }
            
//            DatabaseManager.shared.isAdmin(email: userEmail!){ (isAdmin) in
//                if isAdmin {
//                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
//                        title: "Edit",
//                        style: .done,
//                        target: self,
//                        action: #selector(self.didTapEditEventButton)
//                    )
//                }
//            }
            //cell.addSubview(editButton)
            editButton.frame = CGRect(
                x: view.frame.width - 100,
                y: 100,
                width: 20,
                height: cell.height
            )
            editButton.addTarget(self,
                                 action: #selector(didTapEditEventButton),
                                 for: .touchUpInside)
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EventHeaderTableViewCell.identifier,
                                                           for: indexPath) as? EventHeaderTableViewCell else{
                fatalError()
            }
            let path = "images/\(event!.ImageURL)"
                
            StorageManager.shared.downloadImageURL(for: path) { result in
                switch result {
                case.success(let url):
                    DispatchQueue.main.async {
                        // Use the URL to download the image and display it
                        cell.configure(with:.init(imageUrl: url))
                    }
                case.failure(let error):
                    print("Failed to get download URL: \(error)")
                    cell.configure(with:.init(imageUrl: URL(string: defaultImageURL)!))
                }
            }
            
            //cell.configure(with: .init(imageUrl: URL(string: event?.ImageURL ?? defaultImageURL)))
            cell.selectionStyle = .none
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = event?.description
            cell.textLabel?.numberOfLines = 0
            cell.selectionStyle = .none
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = event?.date
            cell.textLabel?.numberOfLines = 0
            cell.selectionStyle = .none
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: EventActionsTableViewCell.identifier,
                                                     for: indexPath) as! EventActionsTableViewCell
            cell.delegate = self
            cell.configure()
            return cell
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let index = indexPath.row
        
        switch index {
        case 0:
            return UITableView.automaticDimension
        case 1:
            return 400
        case 2:
            return UITableView.automaticDimension
        case 3:
            return UITableView.automaticDimension
        case 4:
            return UITableView.automaticDimension
        default:
            fatalError()
        }
    }
}

extension SingleEventViewController: PostActionsTableViewCellDelegate{
    func didTapAttendButton() {
        //event?.attending += 1
        DatabaseManager.shared.incrementAttend(event: event!) { error in
            if let error = error {
                print("Attending Increment Failed: \(error.localizedDescription)")
            } else {
                print("Attending Increment Success")
            }
        }
    }
    
    func didTapSaveButton() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {success, error in
            if success{
                //schedule test
                let content = UNMutableNotificationContent()
                content.title = "BGA Events"
                content.sound = .default
                content.body = "Event \(self.event!.title) is approaching. Date: \(self.event!.date)"
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yy HH:mm"
                
                //for demonstration only
                let testTargetDate = Date().addingTimeInterval(5)
                
                let targetDate = dateFormatter.date(from: self.event!.date)?.addingTimeInterval(-172800)
                let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                                                                          from: testTargetDate),
                                                            repeats: false)
                
                let request = UNNotificationRequest(identifier: "id", content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
                    if error != nil{
                        print("something went wrong")
                    }
                })
            }else if let error = error{
                //error
                print("error occured")
            }
        })
        print("saved")
    }
    
    func didTapDeleteButton() {
        let alertController = UIAlertController(title: "Delete Event", message: "Are you sure you want to delete this event?", preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in

            DatabaseManager.shared.deleteEvent(id: self.event!.id) { error in
                if let error = error {
                    print("Error deleting event: \(error.localizedDescription)")
                    // Show an error alert
                    let errorAlert = UIAlertController(title: "Error", message: "There was an error deleting the event: \(error.localizedDescription)", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                } else {
                    print("Event deleted successfully")
                    // Show a success alert
                    let successAlert = UIAlertController(title: "Success", message: "The event has been deleted successfully", preferredStyle: .alert)
                    successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    self.present(successAlert, animated: true, completion: nil)
                    
                    
                }
            }
        }))

        // Present the alert to the user
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}

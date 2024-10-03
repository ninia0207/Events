//
//  EventsViewController.swift
//  Events
//
//  Created by Ninia Sabadze on 13.02.24.
//

import UIKit
import FirebaseAuth
import UserNotifications

class EventsViewController: UIViewController{
    
    public var fetchedEvents: [Event] = []
    
    private let tableView: UITableView = {
       let tableView = UITableView()
        tableView.register(FeedEventTableViewCell.self,
                           forCellReuseIdentifier: FeedEventTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = .red
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        DatabaseManager.shared.fetchEventsData { (events) in
            self.fetchedEvents = events
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        //check authentication status
        handleNotAuthenticated();
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    private func handleNotAuthenticated(){
        //if user is not signed in
        if Auth.auth().currentUser == nil{
            //Show log in
            let loginVC = LogInViewController()
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: false)
        }
    }
    

}

extension EventsViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = fetchedEvents[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedEventTableViewCell.identifier, for: indexPath) as? FeedEventTableViewCell
        else{
            fatalError()
        }
        
        let path = "images/\(event.ImageURL)"
            
            StorageManager.shared.downloadImageURL(for: path) { result in
                switch result {
                case.success(let url):
                    DispatchQueue.main.async {
                        // Use the URL to download the image and display it
                        cell.configure(with:.init(title: event.title, imageUrl: url, date: event.date))
                    }
                case.failure(let error):
                    print("Failed to get download URL: \(error)")
                    cell.configure(with:.init(title: event.title, imageUrl: URL(string: defaultImageURL), date: event.date))
                }
            }
        
        cell.backgroundColor = .red
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = SingleEventViewController(event: fetchedEvents[indexPath.row])
        vc.title = fetchedEvents[indexPath.row].title
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}


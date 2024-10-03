//
//  FeedEventTableViewCell.swift
//  Events
//
//  Created by Ninia Sabadze on 27.02.24.
//

import UIKit

class FeedEventTableViewCellModel{
    let title: String
    let imageUrl: URL?
    var imageData: Data?
    let date: String
    
    init(title: String, imageUrl: URL?, date: String){
        self.title = title
        self.imageUrl = imageUrl
        self.date = date
    }
}

class FeedEventTableViewCell: UITableViewCell { 
    
    static let identifier = "FeedEventTableViewCell"
    
    private let eventImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let eventTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    private let eventDateLabel: UILabel = {
       let dateLabel = UILabel()
        dateLabel.numberOfLines = 0
        dateLabel.font = .systemFont(ofSize: 14, weight: .medium)
        return dateLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.clipsToBounds = true

        contentView.addSubview(eventImageView)
        contentView.addSubview(eventTitleLabel)
        contentView.addSubview(eventDateLabel)
    }
    
    public func configure(with string: String){
        //configure the cell
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        eventImageView.frame = CGRect(
            x: separatorInset.left,
            y: 5,
            width: contentView.height - 10,
            height: contentView.height - 10
        )
        //eventImageView.right + 10
        eventTitleLabel.frame = CGRect(
            x: eventImageView.right + 10,
            y: 2,
            width: contentView.width - 5 - separatorInset.left - eventImageView.width,
            height: contentView.height - 30
        )
        
        eventDateLabel.frame = CGRect(
            x: eventImageView.right + 10,
            y: 15,
            width: contentView.width - 5 - separatorInset.left - eventImageView.width,
            height: contentView.height - 10
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        eventTitleLabel.text = nil
        eventImageView.image = nil
        eventDateLabel.text = nil
    }
    
    func configure(with viewModel: FeedEventTableViewCellModel){
        eventTitleLabel.text = viewModel.title
        eventDateLabel.text = viewModel.date
        
        if let data = viewModel.imageData{
            eventImageView.image = UIImage(data: data)
        }
        else if let url = viewModel.imageUrl{
            // fetch and cache image
            
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data else{
                    return
                }
                
                viewModel.imageData = data
                DispatchQueue.main.async {
                    self?.eventImageView.image = UIImage(data: data)
                }
                
            }
            
            task.resume()
        }
    }
}

//
//  EventHeaderTableViewCell.swift
//  Events
//
//  Created by Ninia Sabadze on 27.02.24.
//

import UIKit

class EventHeaderTableViewCellModel {
    let imageUrl: URL?
    var imageData: Data?
    
    init(imageUrl: URL?){
        self.imageUrl = imageUrl
    }
}

class EventHeaderTableViewCell: UITableViewCell {
    static let identifier = "EventHeaderTableViewCell"
    
    private let eventImgaeView: UIImageView = {
       let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.clipsToBounds = true
        contentView.addSubview(eventImgaeView)
    }
    
    public func configure(with string: String){
        //configure the cell
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        eventImgaeView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        eventImgaeView.image = nil
    }
    
    func configure(with viewModel: EventHeaderTableViewCellModel){
        if let data = viewModel.imageData{
            eventImgaeView.image = UIImage(data: data)
        }
        else if let url = viewModel.imageUrl{
            // fetch and cache image
            
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data else{
                    return
                }
                
                viewModel.imageData = data
                DispatchQueue.main.async {
                    self?.eventImgaeView.image = UIImage(data: data)
                }
                
            }
            
            task.resume()
        }
    }
}

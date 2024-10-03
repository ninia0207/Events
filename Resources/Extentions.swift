//
//  Extentions.swift
//  Events
//
//  Created by Ninia Sabadze on 06.02.24.
//

import Foundation
import UIKit

extension UIView{
    
    public var width : CGFloat {
        return frame.width
    }
    
    public var height : CGFloat {
        return frame.height
    }
    
    public var top : CGFloat {
        return frame.origin.y
    }
    
    public var bottom : CGFloat {
        return frame.origin.y + frame.size.height
    }
    
    public var left : CGFloat {
        return frame.origin.x
    }
    
    public var right : CGFloat {
        return frame.origin.x + frame.size.width
    }
}

extension String{
    func safeDatabaseKey() -> String{
        
        return self.replacingOccurrences(of: ".", with: "-").replacingOccurrences(of: "@", with: "-")
    }
}

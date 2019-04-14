//
//  UITableViewCell+Identifier.swift
//  TableController
//
//  Created by Александр on 10/01/2019.
//  Copyright © 2019 Александр. All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    static public func getIdentifier() -> String {
        
        return String(describing: self)
    }
}


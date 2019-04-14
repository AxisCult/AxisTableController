//
//  AxisTableDailySection.swift
//  TableController
//
//  Created by Александр on 29/03/2019.
//  Copyright © 2019 Александр. All rights reserved.
//

import UIKit

public class AxisTableDailySection<T: AxisTableDailyModelProtocol> {
    
    public var rows = Array<T>()
    public var date: Date
    
    public init(date: Date) {
        self.date = date
    }
    
    public func sort(order ascending: Bool) {
        
        self.rows.sort { (lhs, rhs) -> Bool in
            let ascending = lhs.getDate() < rhs.getDate()
            guard ascending else {
                return ascending
            }
            return !ascending
        }
    }
    
    public func clone() -> AxisTableDailySection<T> {
        
        let retval = AxisTableDailySection(date: self.date)
        retval.rows = self.rows
        
        return retval
    }
}


//
//  AxisModel.swift
//  TableControllerTests
//
//  Created by Александр on 09/04/2019.
//  Copyright © 2019 Александр. All rights reserved.
//

import UIKit

struct AxisModel {
    
    let date: Date
}

// MARK: - AxisTableDailyModelProtocol
extension AxisModel: AxisTableDailyModelProtocol {
    
    func getDate() -> Date {
        return self.date
    }
}


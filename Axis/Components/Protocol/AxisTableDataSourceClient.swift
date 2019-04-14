//
//  AxisTableDataSourceClient.swift
//  TableController
//
//  Created by Александр on 29/03/2019.
//  Copyright © 2019 Александр. All rights reserved.
//

import UIKit

public protocol AxisTableDataSourceClient: class {
    func update(type: AxisTableUpdateType)
}


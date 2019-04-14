//
//  AxisTableUpdateModel.swift
//  TableController
//
//  Created by Александр on 29/03/2019.
//  Copyright © 2019 Александр. All rights reserved.
//

import UIKit

public enum AxisTableUpdateType {
    case reload
    case update(params: AxisTableUpdateModel)
}

public struct AxisTableUpdateModel {
    
    public var sectionsInserted: IndexSet
    public var sectionsDeleted: IndexSet
    public var sectionsUpdated: IndexSet
    public var rowsInserted: [IndexPath]
    public var rowsDeleted: [IndexPath]
    public var rowsUpdated: [IndexPath]
    
    static var zero: AxisTableUpdateModel {
        get {
            return AxisTableUpdateModel(sectionsInserted: IndexSet(), sectionsDeleted: IndexSet(), sectionsUpdated: IndexSet(), rowsInserted: [], rowsDeleted: [], rowsUpdated: [])
        }
    }
}


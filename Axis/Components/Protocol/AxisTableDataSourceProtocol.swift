//
//  AxisTableDataSourceProtocol.swift
//  TableController
//
//  Created by Александр on 29/03/2019.
//  Copyright © 2019 Александр. All rights reserved.
//

import UIKit

public protocol AxisTableDataSourceProtocol: class {
    associatedtype T
    
    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func getModel(for indexPath: IndexPath) -> T
    func getIndexPath(for model: T) -> IndexPath?
    
    func insertModels(_ models: [T], animated: Bool, callback: (() -> Void)? )
    func updateModels(_ models: [T], animated: Bool, callback: (() -> Void)? )
    func replaceModels(with models: [T], callback: (() -> Void)? )
    
    func deleteModels(at indexPaths: [IndexPath], animated: Bool)
}


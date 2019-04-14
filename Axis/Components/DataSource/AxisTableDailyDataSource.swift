//
//  AxisTableDailyDataSource.swift
//  TableController
//
//  Created by Александр on 29/03/2019.
//  Copyright © 2019 Александр. All rights reserved.
//

import UIKit

public protocol AxisTableDailyModelProtocol: Equatable {
    
    func getDate() -> Date
}

public class AxisTableDailyDataSource<T: AxisTableDailyModelProtocol> {
    
    private let queue: DispatchQueue
    private let calendar: Calendar
    private let timeZone: TimeZone
    private var sections: [AxisTableDailySection<T>]
    private var isOrderAscending: Bool
    
    private weak var client: AxisTableDataSourceClient?
    
    public init(timeZone: TimeZone) {
        
        self.queue = DispatchQueue(label: "AxisEnrollmentQueue")
        
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        self.calendar = calendar
        self.sections = [AxisTableDailySection<T>]()
        self.isOrderAscending = true
        self.timeZone = timeZone
    }
}

// MARK: - private
extension AxisTableDailyDataSource {
    
    private func processModels(models: [T], replace: Bool, animated: Bool, callback: (() -> Void)? ) {
        
        guard models.isEmpty == false else {
            
            DispatchQueue.main.sync {
                let updateType: AxisTableUpdateType = .reload
                self.client?.update(type: updateType)
                callback?()
            }
            return
        }
        var updateParams = AxisTableUpdateModel.zero
        var insertedSections = [AxisTableDailySection<T>]()
        var trackedModels = [T]()
        var sections = replace ? [] : self.sections.compactMap({ $0.clone() })
        
        let sortedModels = models.sorted { (lhs, rhs) -> Bool in
            guard self.isOrderAscending else {
                return lhs.getDate() < rhs.getDate()
            }
            return lhs.getDate() > rhs.getDate()
        }
        
        // split models in sections
        for model in sortedModels {
            guard let date = self.getRoundedDate(for: model) else { continue }
            
            if let section = sections.first(where: { $0.date == date }) {
                section.rows.append(model)
            } else {
                let newSection = AxisTableDailySection<T>(date: date)
                newSection.rows.append(model)
                sections.append(newSection)
                insertedSections.append(newSection)
            }
            
            if !insertedSections.contains(where: { $0.date == date }) {
                trackedModels.append(model)
            }
        }
        
        // sort models in sections
        sections.forEach {
            $0.sort(order: self.isOrderAscending)
        }
        
        // sort sections
        sections.sort { (lhs, rhs) -> Bool in
            let ascending = lhs.date < rhs.date
            guard self.isOrderAscending else {
                return ascending
            }
            return !ascending
        }
        
        // get indexes of new sections
        var insertedSectionIndexes = IndexSet()
        for section in insertedSections {
            if let index = sections.firstIndex(where: { $0.date == section.date }) {
                insertedSectionIndexes.insert(index)
            }
        }
        
        // find inserted models in resulting sections
        var insertedItemsIndexes: [IndexPath] = []
        for model in trackedModels {
            
            let date = self.getRoundedDate(for: model)
            guard let sectionIndex = sections.firstIndex(where: { $0.date == date }) else { continue }
            guard let row = sections[sectionIndex].rows.firstIndex(where: { $0 == model }) else { continue }
            
            let indexPath = IndexPath(row: row, section: sectionIndex)
            insertedItemsIndexes.append(indexPath)
        }
        updateParams.sectionsInserted = insertedSectionIndexes
        updateParams.rowsInserted = insertedItemsIndexes
        
        DispatchQueue.main.sync {
            self.sections = sections
            
            if animated {
                let updateType: AxisTableUpdateType = .update(params: updateParams)
                self.client?.update(type: updateType)
            } else {
                let updateType: AxisTableUpdateType = .reload
                self.client?.update(type: updateType)
            }
            callback?()
        }
    }
    
    private func getRoundedDate(for model: T, useUtc: Bool = true) -> Date? {
        
        let date = model.getDate()
        var calendar = Calendar.current
        if useUtc, let timeZone = TimeZone(abbreviation: "UTC") {
            
            calendar.timeZone = timeZone
        } else {
            
            calendar.timeZone = self.timeZone
        }
        
        let dateComponents = calendar.dateComponents([.day, .month, .year], from: date)
        return calendar.date(from: dateComponents)
    }
    
    private func getIndexPathForModel(_ model: T) -> IndexPath {
        for (indexSection, section) in sections.enumerated() {
            if let index = section.rows.firstIndex(where: { model == $0 }) {
                return IndexPath(row: index, section: indexSection)
            }
        }
        
        return IndexPath(row: 0, section: 0)
    }
}

// MARK: - public
extension AxisTableDailyDataSource {
    
    public func setClient(_ client: AxisTableDataSourceClient) {
        
        self.client = client
    }
    
    public func getDate(for section: Int) -> (date: Date, timeZone: TimeZone) {
        
        return (date: self.sections[section].date, timeZone: self.timeZone)
    }
    
    public func numberOfRowsInSection(indexOfSection: Int) -> Int {
        
        return self.sections[indexOfSection].rows.count
    }
}

// MARK: - AxisTableDataSourceProtocol
extension AxisTableDailyDataSource: AxisTableDataSourceProtocol {
    
    public func setOrderAscending(_ isAscending: Bool) {
        
        guard self.isOrderAscending != isAscending else { return }
        self.isOrderAscending = isAscending
        
        guard self.sections.isEmpty == false else { return }
        let models = self.sections.reduce([]) { (result, section) -> [T] in
            return result + section.rows
        }
        self.replaceModels(with: models, callback: nil)
    }
    
    public func numberOfSections() -> Int {
        
        return self.sections.count
    }
    
    public func numberOfRowsInSection(_ section: Int) -> Int {
        
        return self.sections[section].rows.count
    }
    
    public func getModel(for indexPath: IndexPath) -> T {
        
        let section = self.sections[indexPath.section]
        let row = section.rows[indexPath.row]
        return row
    }
    
    public func getIndexPath(for model: T) -> IndexPath? {
        
        for (indexSection, section) in self.sections.enumerated() {
            if let index = section.rows.firstIndex(where: { $0 == model }) {
                return IndexPath(row: index, section: indexSection)
            }
        }
        return nil
    }
    
    public func insertModels(_ models: [T], animated: Bool, callback: (() -> Void)? ) {
        
        self.queue.async {
            self.processModels(models: models, replace: false, animated: animated, callback: callback)
        }
    }
    
    public func updateModels(_ models: [T], animated: Bool, callback: (() -> Void)? ) {
        
        self.queue.async {
            
            var indexPathsOfModels = [IndexPath]()
            var indexSetOfSections = IndexSet()
            
            models.forEach { (model) in
                for section in self.sections {
                    if let index = section.rows.firstIndex(where: { $0 == model }) {
                        section.rows[index] = model
                    }
                }
                
                let indexPath = self.getIndexPathForModel(model)
                indexPathsOfModels.append(indexPath)
                indexSetOfSections.insert(indexPath.section)
            }
            
            var updateParams = AxisTableUpdateModel.zero
            updateParams.sectionsUpdated = indexSetOfSections
            updateParams.rowsInserted = indexPathsOfModels
            
            DispatchQueue.main.sync {
                
                if animated {
                    let updateType: AxisTableUpdateType = .update(params: updateParams)
                    self.client?.update(type: updateType)
                } else {
                    let updateType: AxisTableUpdateType = .reload
                    self.client?.update(type: updateType)
                }
                callback?()
            }
        }
    }
    
    public func replaceModels(with models: [T], callback: (() -> Void)? ) {
        
        self.queue.async {
            
            self.processModels(models: models, replace: true, animated: false, callback: callback)
        }
    }
    
    public func deleteModels(at indexPaths: [IndexPath], animated: Bool) {
        
        self.queue.async {
            
            var sections = self.sections.compactMap({ $0.clone() })
            var deletedSections = IndexSet()
            let deletedIndexes = indexPaths
            
            // Find deleted models in data source
            var deletedModels = [T]()
            for indexPath in indexPaths {
                let deletedModel = self.sections[indexPath.section].rows[indexPath.row]
                deletedModels.append(deletedModel)
            }
            
            // Remove these models from corresponding sections
            for section in sections {
                for i in 0..<deletedModels.count {
                    
                    let deletedModel = deletedModels[i]
                    if let index = section.rows.firstIndex(where: { $0 == deletedModel }) {
                        section.rows.remove(at: index)
                        deletedModels.remove(at: i)
                    }
                }
            }
            
            // Delete empty sections
            sections.enumerated().reversed().forEach({ (offset, section) in
                if section.rows.isEmpty {
                    sections.remove(at: offset)
                    deletedSections.insert(offset)
                }
            })
            
            DispatchQueue.main.sync {
                
                self.sections = sections
                let updateType: AxisTableUpdateType
                if animated {
                    
                    var updateParams = AxisTableUpdateModel.zero
                    updateParams.rowsDeleted = deletedIndexes
                    updateParams.sectionsDeleted = deletedSections
                    updateType = .update(params: updateParams)
                } else {
                    
                    updateType = .reload
                }
                self.client?.update(type: updateType)
            }
        }
    }
}


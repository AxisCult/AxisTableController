//
//  TableControllerTests.swift
//  TableControllerTests
//
//  Created by Александр on 10/01/2019.
//  Copyright © 2019 Александр. All rights reserved.
//

import XCTest
@testable import TableController

class TableControllerTests: XCTestCase {
    
    var referenceDate: Date!
    var dataSource: AxisTableDailyDataSource<AxisModel>!
    override func setUp() {
        
        let referenceDate = Date(timeIntervalSince1970: 100000000)
        self.referenceDate = referenceDate
        let dataSource = AxisTableDailyDataSource<AxisModel>(timeZone: .current)
        self.dataSource = dataSource
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    private func generateModel(daysOffset: Int, hoursOffset: Int) -> AxisModel {
        let hourLength: TimeInterval = 60 * 60
        let dayLength: TimeInterval = hourLength * 24
        let date = Date(timeIntervalSinceNow: TimeInterval(daysOffset) * dayLength + TimeInterval(hoursOffset) * hourLength)
        return AxisModel(date: date)
    }
    
    func testDataSource() {
        
        let expectation = XCTestExpectation(description: "Correctly put data in data source")
        
        var models = [AxisModel]()
        models.append(self.generateModel(daysOffset: 0, hoursOffset: 1))
        models.append(self.generateModel(daysOffset: 1, hoursOffset: 0))
        models.append(self.generateModel(daysOffset: 1, hoursOffset: 2))
        models.append(self.generateModel(daysOffset: 0, hoursOffset: 2))
        models.append(self.generateModel(daysOffset: 0, hoursOffset: 0))
        models.append(self.generateModel(daysOffset: 1, hoursOffset: 1))
        
        self.dataSource.insertModels(models, animated: false) {
            
            XCTAssert(self.dataSource.numberOfSections() == 2, "Should be 2 sections")
            
            var resultingDates = [Date]()
            for section in 0..<self.dataSource.numberOfSections() {
                for row in 0..<self.dataSource.numberOfRowsInSection(section) {
                    
                    let indexPath = IndexPath(row: row, section: section)
                    let model = self.dataSource.getModel(for: indexPath)
                    resultingDates.append(model.getDate())
                }
            }
            let sortedDates = resultingDates.sorted(by: { return $0 > $1 })
            
            XCTAssert(resultingDates.count == 6, "Should be 6 items")
            XCTAssert(resultingDates == sortedDates, "Dates should be sorted")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}


//
//  AxisTableConfiguration.swift
//  TableController
//
//  Created by Александр on 10/01/2019.
//  Copyright © 2019 Александр. All rights reserved.
//

import UIKit

public protocol AxisTableControllerComponentsProvider: class {
    
    func axisTableControllerNeedsNextPageLoaderView(_ controller: AxisTableController) -> UIView?
    func axisTableControllerNeedsNextPageErrorView(_ controller: AxisTableController) -> UIView?
    func axisTableControllerNeedsNoContentView(_ controller: AxisTableController) -> UIView?
    func axisTableControllerNeedsNoContentErrorView(_ controller: AxisTableController) -> UIView?
}

public protocol AxisTableControllerPullToRefreshDelegate: class {
    
    func axisTableControllerPulledToRefresh(_ controller: AxisTableController)
}

public protocol AxisTableControllerPagerDelegate: class {
    
    func axisTableControllerShouldDisplayNextPageLoader(_ controller: AxisTableController) -> Bool
    func axisTableControllerNeedsNextPage(_ controller: AxisTableController)
}

public struct AxisTableConfiguration {
    
    public weak var tableDelegate: UITableViewDelegate?
    public weak var tableDataSource: UITableViewDataSource?
    public weak var pullToRefreshDelegate: AxisTableControllerPullToRefreshDelegate?
    public weak var pagedLoadingDelegate: AxisTableControllerPagerDelegate?
    public weak var componentsProvider: AxisTableControllerComponentsProvider?
}


//
//  AxisTableController.swift
//  TableController
//
//  Created by Александр on 10/01/2019.
//  Copyright © 2019 Александр. All rights reserved.
//

import UIKit

public class AxisTableController: UITableViewController {
   
   public enum ContentState {
      case unknown
      case haveSomeContent
      case haveAllContent
   }
   public enum ActivityType {
      case idle                   // Do nothing
      case error                  // Do nothing after failed activity
      case resetting              // Pull-to-refresh, resetting all content
      case loading                // Loading next page only
   }
   
   private var usingPageLoading = false
   private var offsetObservation: NSKeyValueObservation?
   private var registeredCellClasses = Set<String>()
   private let configuration: AxisTableConfiguration
   private weak var pullToRefreshDelegate: AxisTableControllerPullToRefreshDelegate?
   private weak var pagedLoadingDelegate: AxisTableControllerPagerDelegate?
   private weak var componentsProvider: AxisTableControllerComponentsProvider?
   
   private var contentState: ContentState = .unknown
   private var fetchState: ActivityType = .idle
   
   private init() { fatalError() }
   
   init(configuration: AxisTableConfiguration) {
      self.configuration = configuration
      super.init(nibName: nil, bundle: nil)
      
      if configuration.pullToRefreshDelegate != nil {
         let refreshControl = UIRefreshControl()
         refreshControl.addTarget(self, action: #selector(self.actionRefresh), for: .valueChanged)
         self.refreshControl = refreshControl
      }
      if configuration.pagedLoadingDelegate != nil {
         self.usingPageLoading = true
      }
   }
   
   required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   public override func viewDidLoad() {
      super.viewDidLoad()
      
      self.tableView.delegate = self.configuration.tableDelegate
      self.tableView.dataSource = self.configuration.tableDataSource
      self.pullToRefreshDelegate = self.configuration.pullToRefreshDelegate
      self.pagedLoadingDelegate = self.configuration.pagedLoadingDelegate
      self.componentsProvider = self.configuration.componentsProvider
   }
   
   public override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.setContentOffsetObservationEnabled(true)
   }
   
   public override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      self.setContentOffsetObservationEnabled(false)
   }
   
   private func setContentOffsetObservationEnabled(_ enabled: Bool) {
      
      if enabled {
         
         guard self.usingPageLoading else { return }
         guard self.offsetObservation == nil else { return }
         self.offsetObservation = self.tableView.observe(\.contentOffset, options: [.new], changeHandler: { (_, change) in
            
            guard let currentOffset = change.newValue?.y else { return }
            let contentSize = self.tableView.contentSize.height
            let frameSize = self.tableView.frame.size.height
            let fetchThreshold = contentSize - frameSize
            
            let thresholdPassed = currentOffset - fetchThreshold > 0
            if thresholdPassed && self.contentState != .haveAllContent && self.fetchState == .idle {
               self.pagedLoadingDelegate?.axisTableControllerNeedsNextPage(self)
            }
         })
      } else if let offsetObservation = self.offsetObservation {
         offsetObservation.invalidate()
         self.offsetObservation = nil
      }
   }
   
   @objc private func actionRefresh() {
      
      self.pullToRefreshDelegate?.axisTableControllerPulledToRefresh(self)
   }
   
   private func setFooterView(_ footer: UIView?) {
      guard let footer = footer else {
         self.tableView.tableFooterView = UIView()
         return
      }
      let container = UIView()
      container.addSubview(footer)
      let height = container.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
      var width = self.tableView.frame.width
      if width == 0 {
         width = UIScreen.main.bounds.width
      }
      container.frame = CGRect(x: 0, y: 0, width: width, height: height)
      self.tableView.tableFooterView = container
   }
}

extension AxisTableController {
   
   public func dequeueCell<T: UITableViewCell>(indexPath: IndexPath) -> T {
      let reuseIdentifier = T.getIdentifier()
      if self.registeredCellClasses.contains(reuseIdentifier) == false {
         self.tableView.register(T.self, forCellReuseIdentifier: reuseIdentifier)
         self.registeredCellClasses.insert(reuseIdentifier)
      }
      return self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! T
   }
   
   public func updateState(_ activityType: ActivityType, contentState: ContentState) {
      
      switch activityType {
      case .idle:
         self.refreshControl?.endRefreshing()
         self.setFooterView(nil)
      case .error:
         self.refreshControl?.endRefreshing()
         switch contentState {
         case .haveSomeContent:
            self.setFooterView(self.componentsProvider?.axisTableControllerNeedsNextPageErrorView(self))
         case .haveAllContent, .unknown:
            self.setFooterView(self.componentsProvider?.axisTableControllerNeedsNoContentErrorView(self))
         }
      case .resetting:
         self.setFooterView(nil)
      case .loading:
         if self.pagedLoadingDelegate?.axisTableControllerShouldDisplayNextPageLoader(self) == true {
            
            self.setFooterView(self.componentsProvider?.axisTableControllerNeedsNextPageLoaderView(self))
         }
      }
   }
}


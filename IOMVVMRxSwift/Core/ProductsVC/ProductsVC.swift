//
//  ProductsVC.swift
//  IOMVVMRxSwift
//
//  Created by Ajay Bhanushali on 24/05/19.
//  Copyright © 2019 ajaybhanushali. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ProductsVC: UIViewController, ControllerType {
    typealias ViewModelType = ProductsViewModel
    
    // MARK:- Outlets
    @IBOutlet weak var tableViewProducts: UITableView!
    private let refreshControl = UIRefreshControl()
    
    // MARK:- Class Properties
    var viewModel:  ProductsViewModel!
    var dataSource: RxTableViewSectionedReloadDataSource<SectionOfProducts>?
    let disposeBag = DisposeBag()
    
    // MARK:- Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        configure(with: viewModel)
    }
    
    // MARK:- Custom Methods
    private func prepareUI() {
        // registering cells with table
        tableViewProducts.register(UINib(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "ProductCell")
        
        // Preparing refreshcontrol
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        if #available(iOS 10.0, *) {
            tableViewProducts.refreshControl = refreshControl
        } else {
            tableViewProducts.addSubview(refreshControl)
        }
    }
    
    // MARK:- MVVM Binding Method
    func configure(with viewModel: ViewModelType) {
        
        // DataSource implementation
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfProducts>(
            configureCell: { [weak self] dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
                cell.prepareCell(with: item)
                
                // Binding Cell item with viewModel's input
                cell.buttonLike.rx.tap
                    .map{_ in item}
                    .bind(to: (self?.viewModel.input.likedProduct)!)
                    .disposed(by: cell.disposeBag)
                
                return cell
        })
        self.dataSource = dataSource
        
        // Binding reachedBottom trigger with viewModel's input for pagination of products
        tableViewProducts.rx.reachedBottom.asObservable()
            .bind(to: viewModel.input.nextPageTrigger)
            .disposed(by: disposeBag)
        
        // Bind refresh control to viewModel
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: self.viewModel.input.refreshTrigger)
            .disposed(by: disposeBag)
        
        // Binding viewModel's output's products with tableview items
        viewModel.output.products.asObservable()
            .bind(to: tableViewProducts.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

extension ProductsVC {
    static func create(with viewModel: ViewModelType) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ProductsVC") as! ProductsVC
        controller.viewModel = viewModel
        return controller
    }
}


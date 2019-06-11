//
//  ProductsViewModel.swift
//  IOMVVMRxSwift
//
//  Created by Ajay Bhanushali on 24/05/19.
//  Copyright © 2019 ajaybhanushali. All rights reserved.
//

import RxSwift
import RxCocoa

class ProductsViewModel: ViewModelProtocol {
    // Input consists of user inputs such as like any product, pull to refresh and get data for next page
    struct Input {
        let likedProduct: AnyObserver<ProductModel>
        let refreshTrigger: AnyObserver<Void>
        let nextPageTrigger: AnyObserver<Void>
    }
    
    // products are provided as output show on ViewController
    struct Output {
        let products: Driver<[ProductModel]>
    }
    
    let input: Input
    let output: Output
    
    private let disposeBag = DisposeBag()
    
    private let likedProductSubject = PublishSubject<ProductModel>()
    private let refreshTriggerSubject = PublishSubject<Void>()
    private let loadAfterTriggerSubject = PublishSubject<Void>()
    
    init(_ interactor: ProductsInteractorProtocol) {
        // Init Input
        input = Input(likedProduct: likedProductSubject.asObserver(),
                      refreshTrigger: refreshTriggerSubject.asObserver(),
                      nextPageTrigger: loadAfterTriggerSubject.asObserver())
        
        var products = interactor.getProductBase().subscribe { (event) in
            let mproducts = event.element?.data?.dimProductList
//            output = Output(products: mproducts.)
//            output = Output(products: )
        }
        
        
        // Init Output
//        output = Output(products: products.asDriver(onErrorJustReturn: <#T##ProductsBase#>))
    }
}

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
    }
    
    // products are provided as output show on ViewController
    struct Output {
        let products: Driver<[SectionOfProducts]>
        let error: Observable<Error>
    }
    
    let input: Input
    let output: Output
    
    private let likedProductSubject = PublishSubject<ProductModel>()
    private let refreshTriggerSubject = PublishSubject<Void>()
    
    init(_ interactor: ProductsInteractorProtocol) {
        // Init Input
        input = Input(likedProduct: likedProductSubject.asObserver(), refreshTrigger: refreshTriggerSubject.asObserver())

        let productsObservable = interactor.getProductBase().materialize().share()
        
        let refreshedProductsObservable = refreshTriggerSubject
            .flatMapLatest { productsObservable }
        
        let sectionOfProducts = refreshedProductsObservable.map({$0.element})
            .filter({$0 != nil})
            .map { base in
                return [SectionOfProducts(header: "", items: base?.data?.item ?? [])]
        }
    
        let error = refreshedProductsObservable.map({$0.error}).filter { $0 != nil }.map({$0!})
    
        output = Output(products: sectionOfProducts.asDriver(onErrorJustReturn: []), error: error)
    }
}

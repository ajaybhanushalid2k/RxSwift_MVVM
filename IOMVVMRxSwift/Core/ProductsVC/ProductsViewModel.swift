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
        let products: Driver<[SectionOfProducts]>
        let errorMessage: Driver<String>
        let endRefreshing: Driver<Void>
    }
    
    let input: Input
    let output: Output
    
    private let likedProductSubject = PublishSubject<ProductModel>()
    private let refreshTriggerSubject = PublishSubject<Void>()
    private let nextPageTriggerSubject = PublishSubject<Void>()
    
    init(_ interactor: ProductsInteractorProtocol) {
        input = Input(likedProduct: likedProductSubject.asObserver(),
                      refreshTrigger: refreshTriggerSubject.asObserver(),
                      nextPageTrigger: nextPageTriggerSubject.asObserver())
        
        let productsObservable = interactor.getProductBase().materialize().share()
        
        // First: Observable<Event<ProductsBase>>
        let refreshedProductsObservable = refreshTriggerSubject
            .flatMapLatest { productsObservable }
        
        // Second: Observable<Event<ProductsBase>>
        let nextPageObservable = interactor.getNextProductBase(pageURL: "http://219.90.67.69:8011/OrderManagement_API/api/Product/InStock?PageNumber=2&PageSize=20&CustomerId=11&CategoryId=0&SubCategoryId=0&version=v2&TypeId=0&pincode=").materialize().share()
        
        let nextProductsObservable = nextPageTriggerSubject
            .flatMapLatest { nextPageObservable }
        
        let tuple = refreshedProductsObservable.map({$0.element})
            .filter({$0 != nil})
            .withLatestFrom(nextProductsObservable.map({$0.element})){($0, $1)}
//            .map { base in
//                // Here I am parsing data to required pattern for tableViews from the first observable response
//                // Want to append base?.data?.item from the Second Observable also
//                return [SectionOfProducts(header: "", items: base?.data?.item ?? [])]
//        }

        
        let experiment = refreshedProductsObservable.map({$0.element}).map({$0?.data?.item})
            .withLatestFrom(nextProductsObservable.map({ (event) in
               return event.element
            }))
            .map { base in
                base?.data?.item
        }
            .map  { products in
                return [SectionOfProducts(header: "", items: products ?? [])]
        }
        
        
//        let sectionOfProducts = experiment.map { products in
//            return [SectionOfProducts(header: "", items: products ?? [])]
//        }
        
        
        let errorMessage = refreshedProductsObservable
            .map({$0.error?.localizedDescription})
            .filter({$0 != nil })
            .map{$0!}
            .asDriverLogError()
        
        let endRefreshing = refreshedProductsObservable
            .map { _ in }
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
        
        
        
        
        output = Output(products: experiment.asDriver(onErrorJustReturn: []), errorMessage: errorMessage, endRefreshing: endRefreshing)
    }
}

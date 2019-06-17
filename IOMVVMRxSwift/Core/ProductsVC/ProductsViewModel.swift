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
        let likedProduct: AnyObserver<String>
        let refreshTrigger: AnyObserver<Void>
        let nextPageTrigger: AnyObserver<Void>
    }
    
    // products are provided as output show on ViewController
    struct Output {
        let products: Driver<[SectionOfProducts]>
        let errorMessage: Driver<String>
        let endRefreshing: Driver<Void>
        let liked: Driver<Bool>
    }
    
    let input: Input
    let output: Output
    
    private let likedProductSubject = PublishSubject<String>()
    private let refreshTriggerSubject = PublishSubject<Void>()
    private let nextPageTriggerSubject = PublishSubject<Void>()
    
    init(_ interactor: ProductsInteractorProtocol) {
        input = Input(likedProduct: likedProductSubject.asObserver(),
                      refreshTrigger: refreshTriggerSubject.asObserver(),
                      nextPageTrigger: nextPageTriggerSubject.asObserver())
        
        // Get products, Refresh Products
        let productsObservable = interactor.getProductBase().materialize().share()
        
        let refreshedProductsObservable = refreshTriggerSubject
            .flatMapLatest { productsObservable }
        
        var sectionOfProducts = refreshedProductsObservable.map({$0.element})
            .filter({$0 != nil})
            .map { base in
                return [SectionOfProducts(header: "", items: base?.data?.item ?? [])]
        }
        
        // Next Products
        let nextPageObservable = nextPageTriggerSubject
            .flatMapLatest {interactor.getNextProductBase(pageURL: APIConstants.sampleNextPageURL.rawValue)}.materialize().share()
        
        let sectionOfProductsnext = nextPageObservable.map({$0.element})
            .filter({$0 != nil})
            .map { base in
                return [SectionOfProducts(header: "", items: base?.data?.item ?? [])]
        }
        sectionOfProducts = Observable.concat([sectionOfProducts, sectionOfProductsnext]).scan([], accumulator: +)

        // Like Products
        let likedObservable = likedProductSubject
            .flatMapLatest { id in
            return interactor.like(product: id, favorite: true).materialize().share()
        }
        
        // Error handling
        let errorMessage = refreshedProductsObservable
            .map({$0.error?.localizedDescription})
            .filter({$0 != nil })
            .map{$0!}
            .asDriverLogError()
        
        let endRefreshing = refreshedProductsObservable
            .map { _ in }
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
        
        let liked = likedObservable
        .map({$0.element!})
        .asDriverLogError()
        
        output = Output(products: sectionOfProducts.asDriver(onErrorJustReturn: []), errorMessage: errorMessage, endRefreshing: endRefreshing, liked: liked)
    }
}

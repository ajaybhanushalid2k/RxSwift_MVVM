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
    struct Input {
        let likedProduct: AnyObserver<ProductModel>
        let loadAfterTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let products: Driver<[SectionOfProducts]>
    }
    
    let input: Input
    let output: Output
    
    private let disposeBag = DisposeBag()
    private let loadAfterTriggerSubject = PublishSubject<Void>()
    private let likedProductSubject = PublishSubject<ProductModel>()
    
    init(_ interactor: ProductsInteractorProtocol) {
        
        input = Input(likedProduct: likedProductSubject.asObserver(), loadAfterTrigger: loadAfterTriggerSubject.asObserver())
        
        var products = interactor.getProducts()
        

        likedProductSubject.subscribe ({ (event) in
            print("\(String(describing: event.element?.productName))")
        }).disposed(by: disposeBag)
        
        loadAfterTriggerSubject.subscribe ({ (event) in
            print("Get next Products")
            let newProducts = interactor.getNextProducts()
            products = Observable.concat([products, newProducts]).scan([], accumulator: +)
        })
        .disposed(by: disposeBag)
//        let newObserver = Observable.just(dataToPrepend)
//        items = Observable.combineLatest(items, newObserver) {
//            $1+$0
//        }
        output = Output(products: products.asDriver(onErrorJustReturn: []))
    }
}

enum TableTriggerType {
    case refresh, before, after
}

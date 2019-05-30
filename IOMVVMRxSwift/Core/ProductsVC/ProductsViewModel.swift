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
        
        let products = interactor.getProducts()
            .asDriver(onErrorJustReturn: [])

        likedProductSubject.subscribe ({ (event) in
            print("\(String(describing: event.element?.productName))")
        }).disposed(by: disposeBag)
        
        loadAfterTriggerSubject.subscribe ({ (event) in
            print("Get next Products")
        })
        .disposed(by: disposeBag)
        
        output = Output(products: products)
    }
}

enum TableTriggerType {
    case refresh, before, after
}

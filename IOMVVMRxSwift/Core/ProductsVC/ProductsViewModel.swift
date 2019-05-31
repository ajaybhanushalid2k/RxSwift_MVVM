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
    }
    
    let input: Input
    let output: Output
    
    private let disposeBag = DisposeBag()
    
    private let likedProductSubject = PublishSubject<ProductModel>()
    private let refreshTriggerSubject = PublishSubject<Void>()
    private let loadAfterTriggerSubject = PublishSubject<Void>()
    
    init(_ interactor: ProductsInteractorProtocol) {
        // Init Output
        input = Input(likedProduct: likedProductSubject.asObserver(),
                      refreshTrigger: refreshTriggerSubject.asObserver(),
                      nextPageTrigger: loadAfterTriggerSubject.asObserver())
        //>>>>>>>>>> Please review my code from here
        // When ViewModel initializes products are requested from the Interactor
        var products = interactor.getProducts()
        
        // Detect when like button is tapped in the ViewController's tableView's cell
        likedProductSubject.subscribe ({ (event) in
            print("\(String(describing: event.element?.productName))")
        }).disposed(by: disposeBag)
        
        // To get next gage data I have used danielt1263/PaginationNetworkLogic.swift: Link: https://gist.github.com/danielt1263/10bc5eb821c752ad45f281c6f4e3034b
        let source = PaginationUISource(refresh: refreshTriggerSubject.asObservable(), loadNextPage: loadAfterTriggerSubject.asObservable(), bag: disposeBag)
        let sink = PaginationSink(ui: source, loadData: interactor.getNextProducts(page:))
        
        // Concat new products with the previous products
        let newProducts = sink.elements.asObservable()
        products = Observable.concat([products, newProducts]).scan([], accumulator: +)
        //<<<<<<<<<<<< Till here
        
        // Init Output
        output = Output(products: products.asDriver(onErrorJustReturn: []))
    }
}

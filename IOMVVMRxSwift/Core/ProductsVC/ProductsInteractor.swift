//
//  ProductsInteractor.swift
//  IOMVVMRxSwift
//
//  Created by D2k on 29/05/19.
//  Copyright © 2019 ajaybhanushali. All rights reserved.
//

import Foundation

import Foundation
import RxSwift

protocol ProductsInteractorProtocol {
    func getProducts() -> Observable<[SectionOfProducts]>
}

final class ProductsInteractor: ProductsInteractorProtocol {
    
    func getProducts() -> Observable<[SectionOfProducts]> {
        var products: [ProductModel]?
        
        let requestData = ProductsRQM(categoryId: 0, subCategoryId: 0, typeId: 0, customerId: "11")
        
        return Observable.create { (observer) -> Disposable in
            APIRequests.shared.post(requestModel: requestData, requestPath: .requestProducts) { (error, data) in
                let jsonDecoder = JSONDecoder()
                let responseModel = try? jsonDecoder.decode(ProductsBase.self, from: data!)
                products = responseModel?.data?.item
                let section = [SectionOfProducts(header: "", items: products ?? [])]
                observer.onNext(section)
                observer.onCompleted()
            }
            return Disposables.create {}
        }
    }
}




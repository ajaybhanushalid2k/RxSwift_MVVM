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
    func getNextProducts(page: Int) -> Observable<[SectionOfProducts]>
}

final class ProductsInteractor: ProductsInteractorProtocol {
    
    var nextURLString: String = ""
    
    /// Sending a post request to get products
    ///
    /// - Returns: Array structured according to RxDataSources requirement
    func getProducts() -> Observable<[SectionOfProducts]> {
        var products: [ProductModel]?
        let requestData = ProductsRQM(categoryId: 0, subCategoryId: 0, typeId: 0, customerId: "11")
        return Observable.create { [weak self] (observer) -> Disposable in
            APIRequests.shared.post(requestModel: requestData, requestPath: .requestProducts) { (error, data) in
                let jsonDecoder = JSONDecoder()
                let responseModel = try? jsonDecoder.decode(ProductsBase.self, from: data!)
                
                // Products from the api are stored in products variable
                products = responseModel?.data?.item
                self?.nextURLString = responseModel?.data?.links?[0].href ?? ""
                let section = [SectionOfProducts(header: "", items: products ?? [])]
                observer.onNext(section)
                observer.onCompleted()
            }
            return Disposables.create {}
        }
    }
    
    /// Sending a get request to get products
    ///
    /// - Returns: Array structured according to RxDataSources requirement
    func getNextProducts(page: Int) -> Observable<[SectionOfProducts]> {
        var products: [ProductModel]?
        return Observable.create { [weak self] (observer) -> Disposable in
            if self?.nextURLString != "" {
                APIRequests.shared.get(requestURL: self?.nextURLString ?? "", callBack: { (error, data) in
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try? jsonDecoder.decode(ProductsBase.self, from: data!)
                    
                    // Products from the api are stored in products variable
                    products = responseModel?.data?.item
                    
                    // If true then nextPage is available else not
                    if responseModel?.data?.links?[0].rel != "previousPage" {
                        self?.nextURLString = responseModel?.data?.links?[0].href ?? ""
                    } else { // Else assigning nextURLString to nil to prevent unnecessary api call
                        self?.nextURLString = ""
                    }
                    let section = [SectionOfProducts(header: "", items: products ?? [])]
                    observer.onNext(section)
                    observer.onCompleted()
                })
            }
            return Disposables.create {}
        }
    }
}




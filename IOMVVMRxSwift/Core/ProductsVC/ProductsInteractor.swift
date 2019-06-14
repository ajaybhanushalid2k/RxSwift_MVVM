//
//  ProductsInteractor.swift
//  IOMVVMRxSwift
//
//  Created by D2k on 29/05/19.
//  Copyright © 2019 ajaybhanushali. All rights reserved.
//

import Foundation
import RxSwift

protocol ProductsInteractorProtocol {
    func getProductBase() -> Observable<ProductsBase>
    func getNextProductBase(pageURL: String) -> Observable<ProductsBase>
}

final class ProductsInteractor: ProductsInteractorProtocol {
    func getProductBase() -> Observable<ProductsBase> {
        let apiClient = APIClient()
        let requestData = ProductsRQM(categoryId: 0, subCategoryId: 0, typeId: 0, customerId: "11")
        let productsRequest = APIRequest(method: .POST, path: APIConstants.requestProducts.rawValue, parameters: requestData)
        return apiClient.send(apiRequest: productsRequest)
    }
    
    func getNextProductBase(pageURL: String) -> Observable<ProductsBase> {
        let apiClient = APIClient()
        let productsRequest = APIRequest(method: .GET, path: pageURL, parameters: nil)
        return apiClient.send(apiRequest: productsRequest)
    }
}

//
//  ProductsModel.swift
//  IOMVVMRxSwift
//
//  Created by Ajay Bhanushali on 24/05/19.
//  Copyright © 2019 ajaybhanushali. All rights reserved.
//

import Foundation
import RxDataSources

struct SectionOfProducts {
    var header: String
    var items: [Item]
}

extension SectionOfProducts: SectionModelType {
    typealias Item = ProductModel
    init(original: SectionOfProducts, items: [Item]) {
        self = original
        self.items = items
    }
}

//class ProductsRequest: APIRequest {
//    var method = RequestType.GET
//    var path = APIConstants.requestProducts.rawValue
//    var parameters = [String: String]()
//
//    init(name: String) {
//        parameters["name"] = name
//    }
//}

struct ProductsRQM: Codable {
    var categoryId : Int?
    var subCategoryId : Int?
    var typeId : Int?
    var customerId : String?
}

struct ProductsBase : Codable {
    let state : Int?
    let msg : String?
    let data : DataResponse?
    let results : Results?
    
    enum CodingKeys: String, CodingKey {
        
        case state = "state"
        case msg = "msg"
        case data = "data"
        case results = "results"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        state = try values.decodeIfPresent(Int.self, forKey: .state)
        msg = try values.decodeIfPresent(String.self, forKey: .msg)
        data = try values.decodeIfPresent(DataResponse.self, forKey: .data)
        results = try values.decodeIfPresent(Results.self, forKey: .results)
    }
}

struct DataResponse : Codable {
    let dimProductList     : [ProductModel]?
    let paging : Paging?
    let links : [Links]?
    let items : String?
    let item : [ProductModel]?
    
    enum CodingKeys: String, CodingKey {
        case dimProductList     = "dimProductList"
        case paging = "paging"
        case links = "links"
        case items = "items"
        case item = "item"
    }
    
    init(from decoder: Decoder) throws {
        
        let values         = try decoder.container(keyedBy: CodingKeys.self)
        
        dimProductList     = try values.decodeIfPresent([ProductModel].self, forKey: .dimProductList)
        
        // V2
        paging = try values.decodeIfPresent(Paging.self, forKey: .paging)
        links = try values.decodeIfPresent([Links].self, forKey: .links)
        items = try values.decodeIfPresent(String.self, forKey: .items)
        item = try values.decodeIfPresent([ProductModel].self, forKey: .item)
    }
    
}

struct Results : Codable {
    let status : Int?
    let msg : String?
    
    enum CodingKeys: String, CodingKey {
        
        case status = "status"
        case msg = "msg"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        msg = try values.decodeIfPresent(String.self, forKey: .msg)
    }
    
}

struct Paging : Codable {
    let totalItems : Int?
    let pageNumber : Int?
    let pageSize   : Int?
    let totalPages : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case totalItems = "totalItems"
        case pageNumber = "pageNumber"
        case pageSize = "pageSize"
        case totalPages = "totalPages"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        totalItems = try values.decodeIfPresent(Int.self, forKey: .totalItems)
        pageNumber = try values.decodeIfPresent(Int.self, forKey: .pageNumber)
        pageSize   = try values.decodeIfPresent(Int.self, forKey: .pageSize)
        totalPages = try values.decodeIfPresent(Int.self, forKey: .totalPages)
    }
    
}

struct Links : Codable {
    let rel    : String?
    let href   : String?
    let method : String?
    
    enum CodingKeys: String, CodingKey {
        
        case href   = "href"
        case rel    = "rel"
        case method = "method"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        rel        = try values.decodeIfPresent(String.self, forKey: .rel)
        href       = try values.decodeIfPresent(String.self, forKey: .href)
        method     = try values.decodeIfPresent(String.self, forKey: .method)
    }
}

struct ProductModel : Codable {
    let productAlt_Key : Int?
    let unit : String?
    let varietyAlt_Key : Int?
    let typeAlt_Key : Int?
    let productName : String?
    let varietyName : String?
    let typeName : String?
    let shgName : String?
    let shgid : Int?
    var newPrice : Double?
    let oldPrice : Double?
    let discountOffer : Int?
    let id : String?
    let stock : Double?
    let imageURL : String?
    var isInCart : Int?
    let cartId : Int?
    var cartQty : Double?
    var isLiked : Int?
    var nutriValue : String?
    let gst : Double?
    let cgst : Double?
    let sgst : Double?
    let cartunitName : String?
    //    let unitList : [UnitList]?
    //    let CartPrice : Double?
    var enLarge: Bool = false
    
    enum CodingKeys: String, CodingKey {
        
        case productAlt_Key = "productAlt_Key"
        case unit = "unit"
        case varietyAlt_Key = "varietyAlt_Key"
        case typeAlt_Key = "typeAlt_Key"
        case productName = "productName"
        case varietyName = "varietyName"
        case typeName = "typeName"
        case shgName = "shgName"
        case shgid = "shgid"
        case newPrice = "newPrice"
        case oldPrice = "oldPrice"
        case discountOffer = "discountOffer"
        case id = "id"
        case stock = "stock"
        case imageURL = "imageURL"
        case isInCart = "isInCart"
        case cartId = "cartId"
        case cartQty = "cartQty"
        case isLiked = "isLiked"
        case nutriValue = "nutriValue"
        case gst = "gst"
        case cgst = "cgst"
        case sgst = "sgst"
        case cartunitName = "cartunitName"
        //        case unitList = "unitList"
        case enLarge = "enLarge"
        //        case CartPrice = "CartPrice"
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        productAlt_Key = try values.decodeIfPresent(Int.self, forKey: .productAlt_Key)
        unit = try values.decodeIfPresent(String.self, forKey: .unit)
        varietyAlt_Key = try values.decodeIfPresent(Int.self, forKey: .varietyAlt_Key)
        typeAlt_Key = try values.decodeIfPresent(Int.self, forKey: .typeAlt_Key)
        productName = try values.decodeIfPresent(String.self, forKey: .productName)
        varietyName = try values.decodeIfPresent(String.self, forKey: .varietyName)
        typeName = try values.decodeIfPresent(String.self, forKey: .typeName)
        shgName = try values.decodeIfPresent(String.self, forKey: .shgName)
        shgid = try values.decodeIfPresent(Int.self, forKey: .shgid)
        newPrice = try values.decodeIfPresent(Double.self, forKey: .newPrice)
        oldPrice = try values.decodeIfPresent(Double.self, forKey: .oldPrice)
        discountOffer = try values.decodeIfPresent(Int.self, forKey: .discountOffer)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        stock = try values.decodeIfPresent(Double.self, forKey: .stock)
        imageURL = try values.decodeIfPresent(String.self, forKey: .imageURL)
        isInCart = try values.decodeIfPresent(Int.self, forKey: .isInCart)
        cartId = try values.decodeIfPresent(Int.self, forKey: .cartId)
        cartQty = try values.decodeIfPresent(Double.self, forKey: .cartQty)
        isLiked = try values.decodeIfPresent(Int.self, forKey: .isLiked)
        nutriValue = try values.decodeIfPresent(String.self, forKey: .nutriValue)
        gst = try values.decodeIfPresent(Double.self, forKey: .gst)
        cgst = try values.decodeIfPresent(Double.self, forKey: .cgst)
        sgst = try values.decodeIfPresent(Double.self, forKey: .sgst)
        cartunitName = try values.decodeIfPresent(String.self, forKey: .cartunitName)
        //        unitList = try values.decodeIfPresent([UnitList].self, forKey: .unitList)
        //        CartPrice = try values.decodeIfPresent(Double.self, forKey: .unitList)
    }
}

//
//  ProductCell.swift
//  IOMVVMRxSwift
//
//  Created by Ajay Bhanushali on 24/05/19.
//  Copyright © 2019 ajaybhanushali. All rights reserved.
//

import UIKit
import RxSwift

class ProductCell: UITableViewCell {

    @IBOutlet weak var buttonLike: UIButton!
    @IBOutlet weak var labelProductName: UILabel!
    
    var disposeBag = DisposeBag()
    var product: ProductModel?
    let indexPathSubject = PublishSubject<IndexPath>()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func prepareCell(with model: ProductModel) {
        self.product = model
        self.buttonLike.setTitle(model.isLiked?.description, for: .normal)
        self.labelProductName.text = model.productName
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }    
}

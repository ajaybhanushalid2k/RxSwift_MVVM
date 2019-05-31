//
//  PaginationViewModel.swift
//  IOMVVMRxSwift
//
//  Created by D2k on 31/05/19.
//  Copyright © 2019 ajaybhanushali. All rights reserved.
//

import Foundation
import RxSwift

enum TableTriggerType {
    case refresh, before, after
}

struct PaginationUISource {
    /// reloads first page and dumps all other cached pages.
    let refresh: Observable<Void>
    /// loads next page
    let loadNextPage: Observable<Void>
    let bag: DisposeBag
}

struct PaginationSink<T> {
    /// true if network loading is in progress.
    let isLoading: Observable<Bool>
    /// elements from all loaded pages
    let elements: Observable<[T]>
    /// fires once for each error
    let error: Observable<Error>
}

extension PaginationSink {
    init(ui: PaginationUISource, loadData: @escaping (Int) -> Observable<[T]>)
    {
        let loadResults = BehaviorSubject<[Int: [T]]>(value: [:])
        
        let maxPage = loadResults
            .map { $0.keys }
            .map { $0.max() ?? 1 }
        
        let reload = ui.refresh
            .map { -1 }
        
        let loadNext = ui.loadNextPage
            .withLatestFrom(maxPage)
            .map { $0 + 1 }
        
        let start = Observable.merge(reload, loadNext, Observable.just(1))
        
        let page = start
            .flatMap { page in
                Observable.combineLatest(Observable.just(page), loadData(page == -1 ? 1 : page)) { (pageNumber: $0, items: $1) }
                    .materialize()
                    .filter { $0.isCompleted == false }
            }
            .share()
        
        page
            .map { $0.element }
            .filter { $0 != nil }
            .map { $0! }
            .withLatestFrom(loadResults) { (pages: $1, newPage: $0) }
            .map { $0.newPage.pageNumber == -1 ? [1: $0.newPage.items] : $0.pages.merging([$0.newPage], uniquingKeysWith: { $1 }) }
            .subscribe(loadResults)
            .disposed(by: ui.bag)
        
        let _isLoading = Observable.merge(start.map { _ in 1 }, page.map { _ in -1 })
            .scan(0, accumulator: +)
            .map { $0 > 0 }
            .distinctUntilChanged()
        
        let _elements = loadResults
            .map { $0.sorted(by: { $0.key < $1.key }).flatMap { $0.value } }
        
        let _error = page
            .map { $0.error }
            .filter { $0 != nil }
            .map { $0! }
        
        isLoading = _isLoading
        elements = _elements
        error = _error
    }
}


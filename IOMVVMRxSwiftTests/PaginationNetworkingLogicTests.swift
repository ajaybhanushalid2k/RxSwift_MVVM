//
//  PaginationNetworkingLogicTests.swift
//  IOMVVMRxSwiftTests
//
//  Created by D2k on 31/05/19.
//  Copyright © 2019 ajaybhanushali. All rights reserved.
//
import RxSwift
import RxTest
import XCTest
@testable import IOMVVMRxSwift

class PaginationTests: XCTestCase {
    
    var testScheduler: TestScheduler!
    var bag: DisposeBag!
    var isLoading: TestableObserver<Bool>!
    var elements: TestableObserver<[Int]>!
    var error: TestableObserver<Error>!
    var dataLoader: DataLoader!
    
    override func setUp() {
        super.setUp()
        testScheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
        isLoading = testScheduler.createObserver(Bool.self)
        elements = testScheduler.createObserver([Int].self)
        error = testScheduler.createObserver(Error.self)
        dataLoader = DataLoader(testScheduler: testScheduler)
    }
    
    func testDefault() {
        let refreshTrigger = testScheduler.createColdObservable([Recorded<Event<Void>>]())
        let loadNextPageTrigger = testScheduler.createColdObservable([Recorded<Event<Void>>]())
        let source = PaginationUISource(refresh: refreshTrigger.asObservable(), loadNextPage: loadNextPageTrigger.asObservable(), bag: bag)
        let sink = PaginationSink(ui: source, loadData: dataLoader.loadData(page:))
        
        bag.insert(
            sink.isLoading.bind(to: isLoading),
            sink.elements.bind(to: elements),
            sink.error.bind(to: error)
        )
        testScheduler.start()
        
        XCTAssertEqual(isLoading.events, [.next(0, true), .next(10, false)])
        XCTAssertEqual(elements.events, [.next(0, [Int]()), .next(10, [1, 2, 3])])
        XCTAssertTrue(error.events.isEmpty)
        XCTAssertEqual(dataLoader.pages, [1])
    }
    
    func testRefresh() {
        let refreshTrigger = testScheduler.createColdObservable([.next(20, ())])
        let loadNextPageTrigger = testScheduler.createColdObservable([Recorded<Event<Void>>]())
        let source = PaginationUISource(refresh: refreshTrigger.asObservable(), loadNextPage: loadNextPageTrigger.asObservable(), bag: bag)
        let sink = PaginationSink(ui: source, loadData: dataLoader.loadData(page:))
        
        bag.insert(
            sink.isLoading.bind(to: isLoading),
            sink.elements.bind(to: elements),
            sink.error.bind(to: error)
        )
        testScheduler.start()
        
        XCTAssertEqual(isLoading.events, [.next(0, true), .next(10, false), .next(20, true), .next(30, false)])
        XCTAssertEqual(elements.events, [.next(0, [Int]()), .next(10, [1, 2, 3]), .next(30, [1, 2, 3])])
        XCTAssertTrue(error.events.isEmpty)
        XCTAssertEqual(dataLoader.pages, [1, 1])
    }
    
    func testNextPage() {
        let refreshTrigger = testScheduler.createColdObservable([Recorded<Event<Void>>]())
        let loadNextPageTrigger = testScheduler.createColdObservable([.next(20, ())])
        let source = PaginationUISource(refresh: refreshTrigger.asObservable(), loadNextPage: loadNextPageTrigger.asObservable(), bag: bag)
        let sink = PaginationSink(ui: source, loadData: dataLoader.loadData(page:))
        
        bag.insert(
            sink.isLoading.bind(to: isLoading),
            sink.elements.bind(to: elements),
            sink.error.bind(to: error)
        )
        testScheduler.start()
        
        XCTAssertEqual(isLoading.events, [.next(0, true), .next(10, false), .next(20, true), .next(30, false)])
        XCTAssertEqual(elements.events, [.next(0, [Int]()), .next(10, [1, 2, 3]), .next(30, [1, 2, 3, 4, 5, 6])])
        XCTAssertTrue(error.events.isEmpty)
        XCTAssertEqual(dataLoader.pages, [1, 2])
    }
    
    func testNextPageThenRefresh() {
        let refreshTrigger = testScheduler.createColdObservable([.next(40, ())])
        let loadNextPageTrigger = testScheduler.createColdObservable([.next(20, ())])
        let source = PaginationUISource(refresh: refreshTrigger.asObservable(), loadNextPage: loadNextPageTrigger.asObservable(), bag: bag)
        let sink = PaginationSink(ui: source, loadData: dataLoader.loadData(page:))
        
        bag.insert(
            sink.isLoading.bind(to: isLoading),
            sink.elements.bind(to: elements),
            sink.error.bind(to: error)
        )
        testScheduler.start()
        
        XCTAssertEqual(isLoading.events, [.next(0, true), .next(10, false), .next(20, true), .next(30, false), .next(40, true), .next(50, false)])
        XCTAssertEqual(elements.events, [.next(0, [Int]()), .next(10, [1, 2, 3]), .next(30, [1, 2, 3, 4, 5, 6]), .next(50, [1, 2, 3])])
        XCTAssertTrue(error.events.isEmpty)
        XCTAssertEqual(dataLoader.pages, [1, 2, 1])
    }
    
    func testNextPageBeforeInitialPage() {
        let refreshTrigger = testScheduler.createColdObservable([Recorded<Event<Void>>]())
        let loadNextPageTrigger = testScheduler.createColdObservable([.next(5, ())])
        let source = PaginationUISource(refresh: refreshTrigger.asObservable(), loadNextPage: loadNextPageTrigger.asObservable(), bag: bag)
        let sink = PaginationSink(ui: source, loadData: dataLoader.loadData(page:))
        
        bag.insert(
            sink.isLoading.bind(to: isLoading),
            sink.elements.bind(to: elements),
            sink.error.bind(to: error)
        )
        testScheduler.start()
        
        XCTAssertEqual(isLoading.events, [.next(0, true), .next(15, false)])
        XCTAssertEqual(elements.events, [.next(0, [Int]()), .next(10, [1, 2, 3]), .next(15, [1, 2, 3, 4, 5, 6])])
        XCTAssertTrue(error.events.isEmpty)
        XCTAssertEqual(dataLoader.pages, [1, 2])
    }
    
    func testNextPageComesBeforeInitialPage() {
        let refreshTrigger = testScheduler.createColdObservable([Recorded<Event<Void>>]())
        let loadNextPageTrigger = testScheduler.createColdObservable([.next(3, ())])
        let source = PaginationUISource(refresh: refreshTrigger.asObservable(), loadNextPage: loadNextPageTrigger.asObservable(), bag: bag)
        let sink = PaginationSink(ui: source, loadData: dataLoader.reverseLoadData(page:))
        
        bag.insert(
            sink.isLoading.bind(to: isLoading),
            sink.elements.bind(to: elements),
            sink.error.bind(to: error)
        )
        testScheduler.start()
        
        XCTAssertEqual(isLoading.events, [.next(0, true), .next(10, false)])
        XCTAssertEqual(elements.events, [.next(0, [Int]()), .next(8, [4, 5, 6]), .next(10, [1, 2, 3, 4, 5, 6])])
        XCTAssertTrue(error.events.isEmpty)
        XCTAssertEqual(dataLoader.pages, [1, 2])
    }
    
    func testLoadError() {
        let refreshTrigger = testScheduler.createColdObservable([Recorded<Event<Void>>]())
        let loadNextPageTrigger = testScheduler.createColdObservable([Recorded<Event<Void>>]())
        let source = PaginationUISource(refresh: refreshTrigger.asObservable(), loadNextPage: loadNextPageTrigger.asObservable(), bag: bag)
        let sink = PaginationSink(ui: source, loadData: dataLoader.errorLoadData(page:))
        
        bag.insert(
            sink.isLoading.bind(to: isLoading),
            sink.elements.bind(to: elements),
            sink.error.bind(to: error)
        )
        testScheduler.start()
        
        XCTAssertEqual(isLoading.events, [.next(0, true), .next(10, false)])
        XCTAssertEqual(elements.events, [.next(0, [Int]())])
        XCTAssertEqual(error.events.count, 1)
        XCTAssertEqual(dataLoader.pages, [1])
    }
    
    func testErrorThenRetry() {
        let refreshTrigger = testScheduler.createColdObservable([.next(40, ())])
        let loadNextPageTrigger = testScheduler.createColdObservable([.next(20, ())])
        let source = PaginationUISource(refresh: refreshTrigger.asObservable(), loadNextPage: loadNextPageTrigger.asObservable(), bag: bag)
        let sink = PaginationSink(ui: source, loadData: dataLoader.errorThenSuccessLoadData(page:))
        
        bag.insert(
            sink.isLoading.bind(to: isLoading),
            sink.elements.bind(to: elements),
            sink.error.bind(to: error)
        )
        testScheduler.start()
        
        XCTAssertEqual(isLoading.events, [.next(0, true), .next(10, false), .next(20, true), .next(30, false), .next(40, true), .next(50, false)])
        XCTAssertEqual(elements.events, [.next(0, [Int]()), .next(10, [1, 2, 3]), .next(50, [1, 2, 3])])
        XCTAssertEqual(error.events.map { $0.time }, [30])
        XCTAssertEqual(dataLoader.pages, [1, 2, 1])
    }
}

class DataLoader {
    private (set) var pages: [Int] = []
    private let testScheduler: TestScheduler
    
    init(testScheduler: TestScheduler) {
        self.testScheduler = testScheduler
    }
    
    func loadData(page: Int) -> Observable<[Int]> {
        pages.append(page)
        let result = Array((0..<3).map { page * 3 - (2 - $0) })
        return self.testScheduler.createColdObservable([.next(10, result), .completed(10)])
            .asObservable()
    }
    
    func reverseLoadData(page: Int) -> Observable<[Int]> {
        pages.append(page)
        let result = Array((0..<3).map { page * 3 - (2 - $0) })
        let time = 15 - page * 5
        return self.testScheduler.createColdObservable([.next(time, result), .completed(time)])
            .asObservable()
    }
    
    func errorLoadData(page: Int) -> Observable<[Int]> {
        pages.append(page)
        let error = NSError(domain: "testing", code: -1, userInfo: nil)
        return self.testScheduler.createColdObservable([Recorded<Event<[Int]>>.error(10, error)])
            .asObservable()
    }
    
    func errorThenSuccessLoadData(page: Int) -> Observable<[Int]> {
        if pages.count == 1 {
            return errorLoadData(page: page)
        }
        else {
            return loadData(page: page)
        }
    }
}

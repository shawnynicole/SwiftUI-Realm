//
//  RealmViewModel.swift
//  RealmSwiftUI
//
//  Created by DeShawn Jackson on 6/28/20.
//

import Foundation
import RealmSwift

class RealmViewModel<T: RealmSwift.Object>: ObservableObject, Verbose where T: Identifiable {
    
    typealias Element = T
    
    enum Status {
        // Display ProgressView
        case fetching
        // Display "No records found."
        case empty
        // Display results
        case results
        // Display error
        case error(Swift.Error)
        
        enum _Error: String, Swift.Error {
            case fetchNotCalled = "System Error."
        }
    }
    
    init() {
        fetch()
    }
    
    deinit {
        token?.invalidate()
    }
    
    @Published private(set) var status: Status = .error(Status._Error.fetchNotCalled)
    
    // Frozen results: Used for View
    
    @Published private(set) var results: Results<Element>?
    
    // Live results: Used for NotificationToken
    
    private var __results: Results<Element>?
    
    private var token: NotificationToken?
    
    private func notification(_ change: RealmCollectionChange<Results<Element>>) {
        switch change {
            case .error(let error):
                verbose(error)
                self.__results = nil
                self.results = nil
                self.token = nil
                self.status = .error(error)
            case .initial(let results):
                verbose("count:", results.count)
                //self.results = results.freeze()
                //self.status = results.count == 0 ? .empty : .results
            case .update(let results, let deletes, let inserts, let updates):
                verbose("results:", results.count, "deletes:", deletes, "inserts:", inserts, "updates:", updates)
                self.results = results.freeze()
                self.status = results.count == 0 ? .empty : .results
        }
    }
    
    var count: Int { results?.count ?? 0 }
    
    subscript(_ i: Int) -> Element? { results?[i] }
    
    func fetch() {
        
        status = .fetching
        
        //Realm.asyncOpen(callback: asyncOpen(_:_:))
        
        do {
            let realm = try Realm()
            let results = realm.objects(Element.self).sorted(byKeyPath: "id")
            self.__results = results
            self.results = results.freeze()
            self.token = self.__results?.observe(notification)
            
            status = results.count == 0 ? .empty : .results
            
        } catch {
            verbose(error)
            
            self.__results = nil
            self.results = nil
            self.token = nil
            
            status = .error(error)
        }
    }
    
    func insert(_ data: Element) throws {
        let realm = try Realm()
        try realm.write({
            realm.add(data)
        })
    }
    
    func delete(at offsets: IndexSet) throws {
        let realm = try Realm()
        try realm.write({
            
            offsets.forEach { (i) in
                guard let id = results?[i].id else { return }
                guard let data = __results?.first(where: { $0.id == id }) else { return }
                realm.delete(data)
            }
        })
    }
}

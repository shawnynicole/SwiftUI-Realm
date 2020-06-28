//
//  RealmResultsView.swift
//  RealmSwiftUI
//
//  Created by DeShawn Jackson on 6/28/20.
//

import SwiftUI
import RealmSwift

struct RealmResultsView<T: RealmSwift.Object>: View, Verbose where T: Identifiable {
    
    typealias Element = T
    typealias ViewModel = RealmViewModel<Element>
    
    @ObservedObject var viewModel = ViewModel()
    
    var body: some View {
        
        VStack(spacing: 0) {
            switch viewModel.status {
                case .fetching: fetchingView
                case .empty: emptyView
                case .results: resultsView
                case .error(let error): errorView(error)
            }
        }
        .navigationBarTitle(String(describing: Element.self) + " Results")
        .navigationBarItems(trailing: trailing)
    }
    
    var trailing: some View {
        Button(action: insert, label: { Image(systemName: "plus") })
    }
    
    var fetchingView: some View {
        ProgressView("Loading...")
    }
    
    var emptyView: some View {
        Text("No records found.").padding()
    }
    
    var resultsView: some View {
        List {
            ForEach(viewModel.results!) { ResultRow($0) }
                .onDelete(perform: delete)
        }
    }
    
    func errorView( _ error: Swift.Error) -> some View {
        switch error {
            case ViewModel.Status._Error.fetchNotCalled:
                verbose(type: .fatal, error)
                fatalError()
            default:
                verbose(error)
                return Text("Error fetching records.").padding()
        }
    }
    
    func insert() {
        verbose(type: .title("Insert"))
        
        let data = ViewModel.Element()
        try? viewModel.insert(data)
        
        verbose("count:", viewModel.count)
    }
    
    func delete(at indexSet: IndexSet) {
        verbose(type: .title("Delete"))
        
        try? viewModel.delete(at: indexSet)
        
        verbose("count:", viewModel.count)
    }
    
    struct ResultRow: View, Verbose {
        
        let data: Element
        
        init(_ data: Element) {
            self.data = data
            verbose(type(of: data), data.id)
        }
        
        var body: some View {
            Text(String(describing: data.id))
        }
    }
}

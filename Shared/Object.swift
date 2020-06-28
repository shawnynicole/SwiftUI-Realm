//
//  Object.swift
//  RealmSwiftUI
//
//  Created by DeShawn Jackson on 6/27/20.
//

import Foundation
import RealmSwift

class Object: RealmSwift.Object, Identifiable {
    
    @objc dynamic private(set) var id: String = UUID().uuidString
    @objc dynamic private(set) var createdAt: Date = Date()
    @objc dynamic var updatedAt: Date = Date()
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

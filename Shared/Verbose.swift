//
//  Verbose.swift
//  PrintMate
//
//  Created by DeShawn Jackson on 11/18/19.
//

import Foundation

// MARK: -

public enum VerboseType: Equatable { //String {
    case standard, error, warning, fatal, title(String?)
    
    public var value: String {
        
        let value: String = {
            switch self {
            case .standard: return "standard"
            case .error: return "error"
            case .warning: return "warning"
            case .fatal: return "fatal"
            case .title(let x): return x ?? ""
            }
        }()
        
        return value
    }
    
    public static func ==(lhs: VerboseType, rhs: VerboseType) -> Bool {
        
        switch (lhs, rhs) {
        case (.standard, .standard): return true
        case (.error, .error): return true
        case (.warning, .warning): return true
        case (.fatal, .fatal): return true
        case (.title(_), .title(_)): return true
        default: return false
        }
    }
}

// MARK: -

extension NSObject: Verbose { }
extension String: Verbose { }
extension Array: Verbose { }

// MARK: -

public protocol Verbose { }

extension Verbose {
    
    // MARK: -
    
    public func verbose(type verboseType: VerboseType = .standard, _ items: Any?..., separator: String = " ", terminator: String = "\n", file: String = #file, line: Int = #line, function:  Any = #function) {

        var verboseType = verboseType
        
        if verboseType == .standard && items.count == 1 && items.first is Error {
            verboseType = .error
        }
        
        type(of: self).verbose(type: verboseType, items: items, separator, terminator, file, line, function)
    }
    
    public static func verbose(type verboseType: VerboseType = .standard, _ items: Any?..., separator: String = " ", terminator: String = "\n", file: String = #file, line: Int = #line, function:  Any = #function) {
        
        verbose(type: verboseType, items: items, separator, terminator, file, line, function)
    }
    
//    // MARK: -
//    
//    public func verbose(error: Error, title: String = " ", terminator: String = "\n", file: String = #file, line: Int = #line, function:  Any = #function) {
//        
//        type(of: self).verbose(type: .error, items: [error], separator, terminator, file, line, function)
//    }

    // MARK: -
    
    private static func verbose(type verboseType: VerboseType, items: [Any?], _ separator: String = " ", _ terminator: String = "\n", _ file: String = #file, _ line: Int = #line, _ function:  Any = #function) {
        
        // Format Date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss a"
        let now = formatter.string(from: Date())
        //let now = Date()
        //let date = now.format(dateStyle: .short, timeStyle: .none)
        //let time = now.format(dateStyle: .none, timeStyle: .medium)
        
        // Get file name
        
        let fileURL = URL(fileURLWithPath: file)
        let bundle = Bundle(url: fileURL.deletingLastPathComponent())?.bundleURL.lastPathComponent ?? "nil"
        let file = fileURL.lastPathComponent
        
        // Create separators
        
        let before: String = {
            
            let value = "\n************************************************************** \(verboseType.value.uppercased()) **************************************************************"
            
            switch verboseType {
            case .standard: return ""
            // case .title(let string): return string == nil ? "" : value
            default: return value
            }
            
        }()
        
        let after: String = {
            
            let value = "\n***********************************************************************************************************************************"
            
            switch verboseType {
            case .standard: return ""
            // case .title(let string): return string == nil ? value : ""
            default: return value
            }
            
        }()
        
        // Unwrap nil values
        
        let items: [Any] = items.map({ $0 == nil ? $0 as Any : $0! })
        
        // Print to console
        
        print("\(before)\n[" + [now, "\(bundle).\(file)", "\(self).\(function)", line].joined(" ") + "] ", items.joined(separator) + after, separator: "", terminator: terminator)
        //if type == .fatal { fatalError() }
    }
}

extension Array {
        
    public func joined(_ separator: String) -> String {
        
        var string = ""
        
        self.enumerated().forEach({ (i, element) in
            if i > 0 { string += separator }
            string += String(describing: element)
            
        })
        
        return string
    }
}

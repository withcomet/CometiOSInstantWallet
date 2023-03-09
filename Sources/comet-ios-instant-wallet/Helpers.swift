//
//  File.swift
//  
//
//  Created by Ishan Pandey on 3/8/23.
//

import Foundation

class Helpers {
    static func isEmail(input: String) -> Bool {
        return input.contains("@")
    }
    static func jsonToString(obj: Any) -> String? {
        return try? JSONSerialization.data(withJSONObject: obj, options: []).utf8String
    }
    static func getFileUrl(fileName: String, type: String) -> String? {
        return Bundle.main.path(forResource: fileName, ofType: type)
    }
    static func getDataFromFile(fileName: String, type: String) -> Data? {
        do {
            let url = getFileUrl(fileName: fileName, type: type)
            return try Data(contentsOf: URL(fileURLWithPath: url!), options: .mappedIfSafe)
        } catch {
            print(error)
            return nil
        }
    }
    
    
    static let successfulCometApiCallMsg = "Successful Comet network request."
}
struct CometNetworkError: Error {
    var localizedDescription: String, statusCode: Int, callStack: [String]
}

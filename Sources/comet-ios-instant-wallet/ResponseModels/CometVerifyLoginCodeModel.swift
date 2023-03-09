//
//  File.swift
//  
//
//  Created by Ishan Pandey on 3/8/23.
//

import Foundation

public struct CometVerifyLoginCodeModel: Codable {
    public let token: UserAuthToken
    
    public struct UserAuthToken: Codable {
        public let string: String
        public let valid: Bool
        public let expires: String
    }
}

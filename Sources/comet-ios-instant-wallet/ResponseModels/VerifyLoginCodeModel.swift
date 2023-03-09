//
//  File.swift
//  
//
//  Created by Ishan Pandey on 3/8/23.
//

import Foundation

public struct VerifyLoginCodeModel: Codable {
    let token: Token
    
    public struct Token: Codable {
        let string: String
        let valid: Bool
        let expires: String
    }
}

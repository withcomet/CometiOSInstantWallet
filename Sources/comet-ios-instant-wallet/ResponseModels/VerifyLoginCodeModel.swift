//
//  File.swift
//  
//
//  Created by Ishan Pandey on 3/8/23.
//

import Foundation

struct VerifyLoginCodeModel: Codable {
    let token: Token
    
    struct Token: Codable {
        let string: String
        let valid: Bool
        let expires: String
    }
}

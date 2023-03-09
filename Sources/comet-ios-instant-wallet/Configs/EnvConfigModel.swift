//
//  File.swift
//  
//
//  Created by Ishan Pandey on 3/8/23.
//

struct CometEnvConfig: Codable {
    let local: Environment
    let dev: Environment
    let prod: Environment
    struct Environment: Codable {
        let comet: Comet
        let solanaChainCode: Int
        struct Comet: Codable {
            let baseApiUrl: String
            let uploads: String
            let uploadApi: String
        }
    }
}

//
//  File.swift
//  
//
//  Created by Ishan Pandey on 3/8/23.
//

public struct EnvConfig: Codable {
    let local: Environment
    let dev: Environment
    let prod: Environment
    public struct Environment: Codable {
        let comet: Comet
        let solanaChainCode: Int
        public struct Comet: Codable {
            let baseApiUrl: String
            let uploads: String
            let uploadApi: String
        }
    }
}

//
//  File.swift
//  
//
//  Created by Ishan Pandey on 3/8/23.
//

import Foundation

public struct CometUserWallet: Decodable, Hashable {
    public var address: String
    public var privateKey: String
    public var chainId: Int
    public var chainType: String
    public var environment: CometEnvironmentType
}

struct CognitoModel: Codable {
    let identityId: String
    let identityPool: String
    let identityToken: String
    let userId: String
    let keyId: String
}

struct SnowballResponseModel: Decodable {
    var snowballs : [SnowballModel]
}

struct SnowballModel: Decodable {
    var encryptedPrivateKey: String
    var keyId: String
    var chainType: String
    var address: String
}

struct NonceModel: Codable {
    let address: String
    let nonce: String
}

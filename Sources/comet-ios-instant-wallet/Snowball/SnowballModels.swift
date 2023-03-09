//
//  File.swift
//  
//
//  Created by Ishan Pandey on 3/8/23.
//

import Foundation

public struct UserWallet: Decodable, Hashable {
    var address: String
    var privateKey: String
    var chainId: Int
    var chainType: String
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

//
//  TokensModel.swift
//  
//
//  Created by Ishan Pandey on 3/8/23.
//

import Foundation

struct TokenModel: Decodable, Identifiable {
    var id = UUID().uuidString
    var name: String, symbol: String, description: String? = nil, seller_fee_basis_points: Int? = nil, image: String? = nil, edition: String? = nil
    var chainUrl: String? = nil
    var minted: Int? = nil
    
    var collection_name: String?, chainType: String?, chainId: Int?, subtype: String?, price: Double?, maxSupply: String?, publicKey: String?, pricingModel: String? = nil
    var communities: [CommunityModel]? = nil
    
    mutating func addMetadata(detailsModel: NFTDetailsModel) {
        collection_name = detailsModel.name
        chainType = detailsModel.chainType
        chainId = detailsModel.chainId
        subtype = detailsModel.subtype
        price = detailsModel.metadata.config.price
        pricingModel = detailsModel.metadata.config.pricingModel
        maxSupply = detailsModel.metadata.config.maxSupply
        publicKey = detailsModel.metadata.config.publicKey
        description = detailsModel.metadata.config.description
        communities = detailsModel.communities
    }
}

struct NFTDetailsModel: Decodable {
    var id: String? = nil, name: String, chainType: String, chainId: Int, subtype: String, symbol: String? = nil
    var metadata: Metadata
    struct Metadata: Decodable {
        var config: Config
        struct Config: Decodable {
            var price: Double, pricingModel: String? = nil, publicKey: String? = nil, description: String
            @Flexible var maxSupply: String
        }
    }
    var communities: [CommunityModel]? = nil
}

struct CommunityModel: Decodable, Identifiable, Equatable {
    static func == (lhs: CommunityModel, rhs: CommunityModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String, profilePicUpload: String? = nil, bannerPicUpload: String? = nil, name: String? = nil, description: String? = nil, domain: String? = nil
    var posts: Posts? = nil
    var directory: [DirectoryModel]? = nil
    var tokens: [TokenResponseFromDomain]? = nil
    var memberSettings: MemberSettings? = nil
    struct TokenResponseFromDomain: Decodable, Identifiable {
        var id: String
        var name: String, symbol: String
        var metadata: NFTDetailsModel.Metadata
    }
    struct MemberSettings: Decodable {
        var postNotifications: String? = nil
        var replyNotifications: String? = nil
        var upvoteNotifications: String? = nil
    }
}

struct DirectoryModel: Codable, Hashable, Identifiable {
    var id: String, username: String
}

struct TokenDescription: Decodable, Identifiable {
    var id: String? = nil, name: String? = nil, symbol: String? = nil
    var metadata: Metadata? = nil
    var communities: [Community]? = nil
    struct Metadata: Decodable {
        var config: Config? = nil
        struct Config: Decodable {
            var price: Double? = nil, maxSupply: Int? = nil, description: String? = nil, backgroundUpload: String? = nil
        }
    }
    struct Community: Decodable {
        var domain: String? = nil
    }
}

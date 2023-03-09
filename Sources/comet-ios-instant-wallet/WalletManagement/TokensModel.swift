//
//  TokensModel.swift
//  
//
//  Created by Ishan Pandey on 3/8/23.
//

import Foundation

public struct CometNFTTokenModel: Decodable, Identifiable {
    public var id = UUID().uuidString
    public var name: String, symbol: String, description: String? = nil, seller_fee_basis_points: Int? = nil, image: String? = nil, edition: String? = nil, chainUrl: String? = nil, minted: Int? = nil, collection_name: String?, chainType: String?, chainId: Int?, subtype: String?, price: Double?, maxSupply: String?, publicKey: String?, pricingModel: String? = nil, communities: [CommunityModel]? = nil
    
    public mutating func addMetadata(detailsModel: NFTDetailsModel) {
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
    public struct NFTDetailsModel: Decodable {
        public var id: String? = nil, name: String, chainType: String, chainId: Int, subtype: String, symbol: String? = nil, metadata: Metadata
        public struct Metadata: Decodable {
            var config: Config
            struct Config: Decodable {
                var price: Double, pricingModel: String? = nil, publicKey: String? = nil, description: String
                @Flexible var maxSupply: String
            }
        }
        public var communities: [CommunityModel]? = nil
    }
}

public struct CommunityModel: Decodable, Identifiable, Equatable {
    public static func == (lhs: CommunityModel, rhs: CommunityModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    public var id: String, profilePicUpload: String? = nil, bannerPicUpload: String? = nil, name: String? = nil, description: String? = nil, domain: String? = nil, posts: Posts? = nil, directory: [DirectoryModel]? = nil, tokens: [TokenResponseFromDomain]? = nil, memberSettings: MemberSettings? = nil
    public struct TokenResponseFromDomain: Decodable, Identifiable {
        public var id: String
        public var name: String, symbol: String, metadata: CometNFTTokenModel.NFTDetailsModel.Metadata
    }
    public struct MemberSettings: Decodable {
        public var postNotifications: String? = nil, replyNotifications: String? = nil, upvoteNotifications: String? = nil
    }
    public struct DirectoryModel: Codable, Hashable, Identifiable {
        public var id: String, username: String
    }
}





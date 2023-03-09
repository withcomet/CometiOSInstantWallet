//
//  NFTClient.swift
//  
//
//  Created by Ishan Pandey on 3/8/23.
//

import Foundation

public class CometNFTClient {
    var cometApiClient: CometApiClient
    var cometUserWallet: CometUserWallet
    public init(cometUserWallet: CometUserWallet) {
        self.cometApiClient = CometApiClient(userCometAuthKey: cometUserWallet.privateKey, configManager: CometConfigManager(environment: cometUserWallet.environment))
        self.cometUserWallet = cometUserWallet
    }
    public func getNFTList(listener: @escaping (Result<[CometNFTTokenModel], Error>) -> Void) {
        Task {
            do {
                var tokens: [CometNFTTokenModel] = []
                let (data, resp) = try await cometApiClient.baseCometCall(url: cometApiClient.configManager.baseConfig.cometTokenApi.replacingOccurrences(of: "${snowballAddress}", with: self.cometUserWallet.address), postType: "GET")
                
                resp.handleResponse(data: data, defaultErrorMsg: "Failed getNFTList's call to Comet API.", listener: listener) {
                    var tokenModels = try JSONDecoder().decode([CometNFTTokenModel].self, from: data)
                    for (index, token) in tokenModels.enumerated() {
                        if let tokenId = token.image?.slice(from: "token/", to: "/metadata") {
                            tokenModels[index].id = tokenId
                            tokens.append(tokenModels[index])
                        }
                    }
                    return tokenModels
                }
            } catch {
                listener(.failure(error))

            }
        }
    }
    public func getNFTMetadata(token: CometNFTTokenModel, listener: @escaping (Result<CometNFTTokenModel.NFTDetailsModel, Error>) -> Void) {
        Task {
            do {
                let (data, resp) = try await cometApiClient.baseCometCall(url: cometApiClient.configManager.baseConfig.token.definition.replacingOccurrences(of: "${tokenId}", with: token.id), postType: "GET")
                
                resp.handleResponse(data: data, defaultErrorMsg: "Failed getNFTMetadata's call to Comet API.", listener: listener) {
                    let nftDetailsModel = try JSONDecoder().decode(CometNFTTokenModel.NFTDetailsModel.self, from: data)
                    return nftDetailsModel
                }
            } catch {
                listener(.failure(error))
            }
        }
    }
}

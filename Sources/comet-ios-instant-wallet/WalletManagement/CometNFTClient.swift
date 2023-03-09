//
//  NFTClient.swift
//  
//
//  Created by Ishan Pandey on 3/8/23.
//

import Foundation

public class CometNFTClient {
    var cometApiClient: CometApiClient
    public init(environment: CometEnvironmentType, userCometAuthKey: String? = nil) {
        self.cometApiClient = CometApiClient(userCometAuthKey: userCometAuthKey, configManager: CometConfigManager(environment: environment))
    }
    public func getNFTList(userWallet: CometUserWallet, listener: @escaping (Result<[TokenModel], Error>) -> Void) {
        Task {
            do {
                var tokens: [TokenModel] = []
                let (data, resp) = try await cometApiClient.baseCometCall(url: cometApiClient.configManager.baseConfig.cometTokenApi.replacingOccurrences(of: "${snowballAddress}", with: userWallet.address), postType: "GET")
                
                resp.handleResponse(data: data, defaultErrorMsg: "Failed getNFTList's call to Comet API.", listener: listener) {
                    var tokenModels = try JSONDecoder().decode([TokenModel].self, from: data)
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
    public func getNFTMetadata(token: TokenModel, listener: @escaping (Result<TokenModel.NFTDetailsModel, Error>) -> Void) {
        Task {
            do {
                let (data, resp) = try await cometApiClient.baseCometCall(url: cometApiClient.configManager.baseConfig.token.definition.replacingOccurrences(of: "${tokenId}", with: token.id), postType: "GET")
                
                resp.handleResponse(data: data, defaultErrorMsg: "Failed getNFTMetadata's call to Comet API.", listener: listener) {
                    let nftDetailsModel = try JSONDecoder().decode(TokenModel.NFTDetailsModel.self, from: data)
                    return nftDetailsModel
                }
            } catch {
                listener(.failure(error))
            }
        }
    }
}

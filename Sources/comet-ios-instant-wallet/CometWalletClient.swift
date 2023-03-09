//
//  File.swift
//  
//
//  Created by Ishan Pandey on 3/8/23.
//

import Foundation

class CometWalletClient {
    
    /*
     * Send login code to user's phone number or email
     */
    static func sendLoginCode(phoneOrEmailInput: String, environment: EnvironmentType, listener: @escaping (Result<String, Error>) -> Void) {
        let isEmail = Helpers.isEmail(input: phoneOrEmailInput)
        let configManager = ConfigManager(environment: environment)
        let uriConfig = isEmail ? configManager.baseConfig.cometAuth.email : configManager.baseConfig.cometAuth.phone
        let parametersJson = [
            (isEmail ? "email" : "number"): phoneOrEmailInput
        ]
        let parametersString = Helpers.jsonToString(obj: parametersJson)
        Task {
            do {
                let (data, resp) = try await CometApiClient(configManager: configManager).baseCometCall(
                    url: uriConfig.send,
                    postType: "POST",
                    data: parametersString)
                
                resp.handleResponse(data: data, defaultErrorMsg: "Failed to send login code.", listener: listener) {
                    return Helpers.successfulCometApiCallMsg
                }
            } catch {
                listener(.failure(error))
            }
        }
    }
    
    /*
     * Verify entered login code is correct
     */
    static func verifyLoginCode(phoneOrEmailInput: String, verificationCode: String, environment: EnvironmentType, listener: @escaping (Result<VerifyLoginCodeModel, Error>) -> Void) {
        let isEmail = Helpers.isEmail(input: phoneOrEmailInput)
        let configManager = ConfigManager(environment: environment)
        let uriConfig = isEmail ? configManager.baseConfig.cometAuth.email : configManager.baseConfig.cometAuth.phone
        let parametersJson = [
            (isEmail ? "email" : "number"): phoneOrEmailInput,
            "code": verificationCode
        ]
        let parametersString = Helpers.jsonToString(obj: parametersJson)
        Task {
            do {
                let (data, resp) = try await CometApiClient(configManager: configManager).baseCometCall(
                    url: uriConfig.verify,
                    postType: "POST",
                    data: parametersString)
               let verifyLoginCodeModel = try JSONDecoder().decode(VerifyLoginCodeModel.self, from: data)
                resp.handleResponse(data: data, defaultErrorMsg: "Failed to verify login code.", listener: listener) {
                    return verifyLoginCodeModel
                }
            } catch {
                listener(.failure(error))
            }
        }
    }
    
    /*
     * If user has wallet return existing wallet, else return a new wallet for them.
     */
    static func initializeWallet(userCometAuthKey: String, environment: EnvironmentType, walletListener: ((UserWallet) -> Void)? = nil) {
        let configManager = ConfigManager(environment: environment)
        let snowballClient = SnowballClient(cometApiClient: CometApiClient(userCometAuthKey: userCometAuthKey, configManager: configManager), walletListener: walletListener)
        snowballClient.getCognitoIdentity()
    }
}
public enum EnvironmentType {
    case dev, prod
}

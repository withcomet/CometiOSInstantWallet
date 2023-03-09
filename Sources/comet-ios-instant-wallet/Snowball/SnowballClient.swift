////
////  File.swift
////
////
////  Created by Ishan Pandey on 3/8/23.
////
//
import Foundation
import AWSCore
import AWSKMS
import Solana
import TweetNacl
//
class SnowballClient {
    var cometApiClient: CometApiClient
    var walletListener: ((UserWallet) -> Void)? = nil

    private var keyId : String = ""
    private var userId : String = ""
    private var kmsClient: AWSKMS? = nil

    init(cometApiClient: CometApiClient, walletListener: ((UserWallet) -> Void)? = nil) {
        self.cometApiClient = cometApiClient
        self.walletListener = walletListener
    }
    
    func getCognitoIdentity() {
        Task {
            do {
                // Step 1: Get user's cognito identity using Comet API call
                let (bodyData, _) = try await cometApiClient.baseCometCall(
                    url: cometApiClient.configManager.baseConfig.cometAuth.snowball.identity,
                    postType: "GET",
                    headers: ["cache-control": "no-cache"])

                // Step 2: Extract important identity info for KMS calls
                let cognitoModel: CognitoModel = try JSONDecoder().decode(CognitoModel.self, from: bodyData)
                let poolId = cognitoModel.identityPool.components(separatedBy: ":")[1]
                keyId = cognitoModel.keyId
                userId = cognitoModel.userId
                setKMSAuth(poolId: poolId, identityId: cognitoModel.identityId, identityToken: cognitoModel.identityToken)

            } catch {
                print("Request failed with error: \(error)")
            }
        }
    }
    private func setKMSAuth(poolId: String, identityId: String, identityToken: String) {
        let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: nil)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        let identity = AWSCognitoIdentity.default()
        let input = AWSCognitoIdentityGetCredentialsForIdentityInput()
        input?.identityId = identityId
        input?.logins = ["cognito-identity.amazonaws.com":identityToken]
        identity.getCredentialsForIdentity(input!).continueWith{(task: AWSTask) -> Any? in
            if let result = task.result,
               let accessKey = result.credentials?.accessKeyId,
               let secretKey = result.credentials?.secretKey,
               let sessionToken = result.credentials?.sessionToken {
                let credentialsProvider = CometAWSCredentialsProvider(
                    accessKey: accessKey,
                    secretKey: secretKey,
                    sessionToken: sessionToken)
                self.createKMSClient(poolId: poolId, credentialsProvider: credentialsProvider)
            } else {
//                self.snowballFormattingFailed()
            }
            return nil
          }
    }
    private func createKMSClient(poolId: String, credentialsProvider: CometAWSCredentialsProvider) {
        let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialsProvider)
        AWSKMS.register(with: configuration!, forKey: "CometKMS")

        kmsClient = AWSKMS(forKey: "CometKMS")
        configuration?.credentialsProvider.credentials()

        getSnowballs()
    }

    private func getSnowballs() {
        Task {
            do {
                // Get user's existing snowballs
                let (bodyData, _) = try await cometApiClient.baseCometCall(
                    url: cometApiClient.configManager.baseConfig.cometAuth.snowball.snowballs,
                    postType: "GET",
                    headers: ["cache-control": "no-cache"])
                let snowballsResponse: SnowballResponseModel = try JSONDecoder().decode(SnowballResponseModel.self, from: bodyData)

                // If user has no snowballs, create new wallet. Else, get keys for existing wallet
                if snowballsResponse.snowballs.isEmpty {
                    let snowballModel = generateWallet()
                    if let _ = self.walletListener, let userWallet = snowballModel {
                        self.walletListener!(userWallet)
                        encryptKey(userSnowball: userWallet)
                    }
                } else {
                    decryptKey(snowballModel: snowballsResponse.snowballs[0])
                }

            } catch {
                print("Request failed with error: \(error)")
            }
        }
    }
    private func decryptKey(snowballModel: SnowballModel) {
        let decrypt = AWSKMSDecryptRequest()
        decrypt?.ciphertextBlob = Data(snowballModel.encryptedPrivateKey.hexaBytes)

        decrypt?.keyId = keyId
        decrypt?.encryptionContext = ["userId": userId]
        kmsClient!.decrypt(decrypt!).continueWith { (task: AWSTask<AWSKMSDecryptResponse>) -> Any? in
            let response = task.result
            DispatchQueue.main.async {
                let userWallet = UserWallet(address: snowballModel.address, privateKey: response?.plaintext?.utf8String ?? "", chainId: self.cometApiClient.configManager.envConfig.solanaChainCode, chainType: "solana")
                if let _ = self.walletListener {
                    self.walletListener!(userWallet)
                }
            }
            return nil
        }
    }

    private func generateWallet() -> UserWallet? {
        //TODO: If prod, mainnet
        let account = HotAccount()
        if let address = account?.publicKey.base58EncodedString,
           let pKey = account?.secretKey {
            let privateKey = Base58.encode([UInt8](pKey))
            return UserWallet(address: address, privateKey: privateKey, chainId: self.cometApiClient.configManager.envConfig.solanaChainCode, chainType: "solana")
        }
        return nil
    }
    private func encryptKey(userSnowball: UserWallet) {
        let encrypt = AWSKMSEncryptRequest()
        //TODO:  issue
        let data = userSnowball.privateKey.data(using: .utf8)!
        encrypt?.plaintext = data
        encrypt?.keyId = keyId
        encrypt?.encryptionContext = ["userId": userId]
        kmsClient!.encrypt(encrypt!).continueWith { [self] (task: AWSTask<AWSKMSEncryptResponse>) -> Any? in
            let response = task.result

            if let encryptedKey = response?.ciphertextBlob?.toHexString() {
                self.persistWallet(encryptedPrivateKey: encryptedKey, userSnowball: userSnowball)
            }
            return nil
        }
    }
    private func persistWallet(encryptedPrivateKey: String, userSnowball: UserWallet) {
        let dataObj = [
            "encryptedPrivateKey": encryptedPrivateKey,
            "address": userSnowball.address ?? "",
            "chainType": "solana",
            "chainId": self.cometApiClient.configManager.envConfig.solanaChainCode,
            "keyId": keyId,
        ] as [String : Any]

        Task {
            do {
                // Persist Wallet
                let jsonData = try JSONSerialization.data(withJSONObject: dataObj, options: [])
                let (bodyDataPersistWallet, respPersistWallet) = try await cometApiClient.baseCometCall(
                    url: cometApiClient.configManager.baseConfig.cometAuth.snowball.snowballs,
                    postType: "POST",
                    data: jsonData.utf8String,
                    headers: ["cache-control": "no-cache"])
                
                // Start address verification with Solana
                let body = Helpers.jsonToString(obj: ["address": userSnowball.address])
                let (bodyStartVerification, respStartVerification) = try await cometApiClient.baseCometCall(url: cometApiClient.configManager.baseConfig.cometAuth.solana.start, postType: "POST", data: body)
                let nonceObj: NonceModel = try JSONDecoder().decode(NonceModel.self, from: bodyDataPersistWallet)
                
                
                if let nonceData = nonceObj.nonce.data(using: .utf8) {
                    let decryptedKey = Base58.decode(userSnowball.privateKey)
                    let decryptedData = Data(decryptedKey)
                    let signatureBytes = try NaclSign.signDetached(message: nonceData, secretKey: decryptedData)
                    let signatureString = Base58.encode([UInt8](signatureBytes))
                    
                    let body = Helpers.jsonToString(obj: ["address": userSnowball.address as Any, "chainId": userSnowball.chainId as Any, "signature": signatureString])
                    let (_, respVerifyAddress) = try await cometApiClient.baseCometCall(url: cometApiClient.configManager.baseConfig.cometAuth.solana.verify, postType: "POST", data: body)
                    if ((respVerifyAddress as? HTTPURLResponse)?.statusCode) ?? 300 > 299 {
                        
                    }
                } else {
                    
                }
            } catch {
                
            }
        }
    }
}

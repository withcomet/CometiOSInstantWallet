# Comet iOS SDK: Instant Wallet

[![Version](https://img.shields.io/badge/Release-0.5.1-blue.svg)](https://github.com/withcomet/CometiOSInstantWallet/releases)
[![Made with Comet](https://img.shields.io/badge/Made%20with-Comet-%23d98a44.svg)](https://withcomet.com)

<p align="left">
  <img src="https://www.withcomet.com/comet.png" height="50" />
</p>

## Overview

Allow your users to instantly create a Solana wallet using just their phone number or email. Users can login and create a wallet with only 3 lines of code.

You can also pull any Comet NFT's and their metadata, launch collections, and sell/transfer NFT's effortlessly. Ethereum support is on the way! 

Welcome to iOS's first instant wallet API with extensive features and support, bringing Web 3.0 to the iOS world!

Contact support@withcomet.com with any questions.

## Installation

### Swift Package Manager

Go to `File | Swift Packages | Add Package Dependency...` in Xcode and search for "[https://github.com/withComet/CometiOSInstantWallet](https://github.com/withComet/CometiOSInstantWallet)".

## Usage

### Instant Wallet Creation

Add to the top of every page you use the SDK:

````swift
import CometWalletClient
````

#### Step 1: user login:

````swift
let walletClient = CometWalletClient(environment: .prod)

func sendLoginCode() {
    walletClient.sendLoginCode(phoneOrEmailInput: "USER_NUMBER_OR_EMAIL") { result in
        
        switch result {
        case .success(_):
            print("Sent code to user's device")
        case .failure(let error):
            print(error.localizedDescription)
        }
        
    }
}

func verifyLoginCode() {
    walletClient.verifyLoginCode(phoneOrEmailInput: "USER_NUMBER_OR_EMAIL", verificationCode: "CODE_SENT_TO_DEVICE") { result in
        
        switch result {
        case .success(let verifyCodeResponse):
            // User has been logged in.
            // Save this token in iOS Keychain for future use.
            let userAuthToken: UserAuthToken = verifyCodeResponse.token
        case .failure(let error):
            print(error.localizedDescription)
        }
        
    }
    
}
````

#### Step 2: wallet creation:

````swift
func createWallet(userAuthToken: String) {
    let walletClient = CometWalletClient(environment: .prod)
    walletClient.initializeWallet(userCometAuthKey: userAuthToken) { userWallet in
        // Wallet has been created for user and linked to their Comet account.
        let cometUserWallet: CometUserWallet = userWallet
    }
}
````

### NFTs in wallet:

#### Get full NFT list:

````swift
let nftClient = CometNFTClient(cometUserWallet: cometUserWallet)

func getNFTsInWallet() {
    nftClient.getNFTList() { result in
        
        switch result {
        case .success(let nftTokens):
            let nftList: [CometNFTTokenModel] = nftTokens
        case .failure(let error):
            print(error.localizedDescription)
        }
        
    }
}
````

#### Get an NFT's metadata:

````swift
func getNFTMetadata() {
    nftClient.getNFTMetadata(token: CometNFTTokenModel)() { result in
        
        switch result {
        case .success(let nftMetadata):
            let nftMetadata: CometNFTTokenModel.NFTDetailsModel = nftMetadata
        case .failure(let error):
            print(error.localizedDescription)
        }
        
    }
}
````

## About Comet
We are building an NFT-gated social community platform with countless uses! [Check out our website](http://withcomet.com) or [download our iOS app!](https://testflight.apple.com/join/Cat8eIhd)

Contact us at support@withcomet.com if you need help with a project.

## License

Comet iOS SDK is distributed under the MIT license. [See LICENSE](./LICENSE.md) for details.

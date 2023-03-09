//
//  File.swift
//  
//
//  Created by Ishan Pandey on 3/8/23.
//

struct BaseConfigModel: Codable {
    let cometAuth: CometAuth
    let token: Token
    let cometTokenApi: String
    let communitySearch: String
    let community: Community
    let notifications: Notifications
    let payment: String
    let mint: String
    let otherAccount: String
    let home: Home
    
    struct CometAuth: Codable {
        let account: String
        let email: AuthType
        let phone: AuthType
        let snowball: Snowball
        let solana: Solana
        let logout: String
        
        struct AuthType: Codable {
            let send: String
            let verify: String
        }
        
        struct Snowball: Codable {
            let identity: String
            let snowballs: String
        }

        struct  Solana: Codable {
            let start: String
            let verify: String
        }
    }
    struct Token: Codable {
        let definition: String
        let stats: String
        let image: String
        let create: String
    }
    struct Community: Codable {
        let posts: String
        let upvotePost: String
        let comments: String
        let upvoteComment: String
        let directory: String
        let fromDomain: String
        let create: String
        let access: String
    }
    struct Notifications: Codable {
        let account: String
        let community: String
        let register: String
        let deregister: String
        let getNotifications: String
    }
    struct Home: Codable {
        let explore: String
        let userFeed: String
    }
}

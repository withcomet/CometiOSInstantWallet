//
//  File.swift
//  
//
//  Created by Ishan Pandey on 3/8/23.
//

import Foundation
struct Posts: Decodable {
    var posts: [Post]
}
struct Comments: Decodable {
    var comments: [Post]
}

protocol PostProtocol: Decodable, Identifiable {
    var content: String? { get set }
    var timestamp: String { get set }
    var upvotes: Int? { get set }
    var numComments: Int? { get set }
    var myUpvote: Int? { get set }
    var type: String? { get set }
    var user: Post.User? { get set }
    var images: [Post.Image]? { get set }
    var id: String { get set }
}

struct Post: PostProtocol, Decodable, Identifiable {
    var id: String, title: String? = nil
    var content: String? = nil, timestamp: String, upvotes: Int? = nil, numComments: Int? = nil, myUpvote: Int? = nil, type: String? = nil, replies: [Reply]? = nil
    var user: User? = nil
    var images: [Image]? = nil
    var community: CommunityModel? = nil
    struct User: Codable, Hashable, Identifiable {
        var id: String, username: String, profile: Profile? = nil
        struct Profile: Codable, Hashable {
            var profilePictureKey: String? = nil
        }
    }
    struct Image: Codable, Identifiable {
        let id = UUID()
        var path: String
    }
}
struct Reply: PostProtocol, Codable, Identifiable {
    var id: String
    var content: String? = nil, timestamp: String, upvotes: Int? = nil, numComments: Int? = nil, myUpvote: Int? = nil, type: String? = nil
    var user: Post.User? = nil
    var images: [Post.Image]? = nil
    func replyToPost() -> Post {
        return Post(id: self.id,content: self.content, timestamp: self.timestamp, upvotes: self.upvotes, numComments: self.numComments, myUpvote: self.myUpvote, type: self.type, user: self.user, images: self.images)
    }
}


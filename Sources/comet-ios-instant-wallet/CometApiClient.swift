//
//  File.swift
//  
//
//  Created by Ishan Pandey on 3/8/23.
//

import Foundation
import Yams

class CometApiClient {
    var userCometAuthKey: String? = nil
    var configManager: ConfigManager
    init(userCometAuthKey: String? = nil, configManager: ConfigManager) {
        self.userCometAuthKey = userCometAuthKey
        self.configManager = configManager
    }
    
    func getBasicRequest(url: String, postType: String, data: String?, cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) -> URLRequest {
        var request = URLRequest(url: URL(string: url)!)
        request.cachePolicy = cachePolicy
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = postType
        if let postData = data?.data(using: .utf8) {
            request.httpBody = postData
        }
        return request
    }
    func baseCometCall(url: String, postType: String, data: String? = nil, headers: [String: String?]? = nil) async throws -> (Data, URLResponse) {
        var request = getBasicRequest(url: configManager.envConfig.comet.baseApiUrl + url, postType: postType, data: data)
        if let dAuthCode = userCometAuthKey {
            request.addValue("Bearer \(dAuthCode)", forHTTPHeaderField: "Authorization")
        }
        if let h = headers {
            addHeaders(request: &request, headers: h)
        }
        return try await URLSession.shared.data(for: request)
    }
    private func addHeaders(request: inout URLRequest, headers: [String: String?]) {
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}


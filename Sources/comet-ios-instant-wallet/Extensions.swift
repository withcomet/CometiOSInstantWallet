//
//  File.swift
//  
//
//  Created by Ishan Pandey on 3/8/23.
//

import Foundation

extension Data {
    var utf8String: String {
        return string(as: .utf8) ?? ""
    }
    
    func string(as encoding: String.Encoding) -> String? {
        return String(data: self, encoding: encoding)
    }
    var bytes: [UInt8] {
        return [UInt8](self)
    }
}
extension StringProtocol {
    var hexaData: Data { .init(hexa) }
    var hexaBytes: [UInt8] { .init(hexa) }
    private var hexa: UnfoldSequence<UInt8, Index> {
        sequence(state: startIndex) { startIndex in
            guard startIndex < self.endIndex else { return nil }
            let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}

extension URLResponse {
    func isValid() -> Bool {
        if let dRespCode = (self as? HTTPURLResponse)?.statusCode {
            return dRespCode >= 200 && dRespCode < 300
        }
        return false
    }
    func getCode() -> Int {
        if let dRespCode = (self as? HTTPURLResponse)?.statusCode {
            return dRespCode
        }
        return -1
    }
    func handleResponse<T>(data: Data, defaultErrorMsg: String, listener: @escaping (Result<T, Error>) -> Void, successAction: () throws -> T) {
        if self.isValid() {
            do {
                try listener(.success(successAction()))
            } catch {
                listener(.failure(error))
            }
        } else {
            let errorMsg = (try? JSONDecoder().decode(ErrorModel.self, from: data).message) ?? defaultErrorMsg
            listener(.failure(CometNetworkError(localizedDescription: errorMsg, statusCode: self.getCode(), callStack: Thread.callStackSymbols)))
        }
    }
}


extension String {
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}

@propertyWrapper struct Flexible<T: FlexibleDecodable>: Decodable {
    var wrappedValue: T
    
    init(from decoder: Decoder) throws {
        wrappedValue = try T(container: decoder.singleValueContainer())
    }
    init(wrapped: T) {
        wrappedValue = wrapped
    }
}

protocol FlexibleDecodable {
    init(container: SingleValueDecodingContainer) throws
}

extension String: FlexibleDecodable {
    init(container: SingleValueDecodingContainer) throws {
        if let string = try? container.decode(String.self) {
            self = string
        } else if let int = try? container.decode(Int.self) {
            self = String(int)
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath, debugDescription: "Invalid int value"))
        }
    }
}

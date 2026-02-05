// Endpoint.swift
// iOS-Networking-Architecture-Pro
//
// Created by Muhittin Camdali
// Copyright © 2025. All rights reserved.

import Foundation

/// Protocol defining a type-safe API endpoint
public protocol Endpoint: Sendable {
    /// Base URL for the endpoint
    var baseURL: URL { get }
    
    /// Path component of the URL
    var path: String { get }
    
    /// HTTP method
    var method: HTTPMethod { get }
    
    /// Request headers
    var headers: [String: String] { get }
    
    /// Query parameters
    var queryParameters: [String: Any]? { get }
    
    /// Request body
    var body: RequestBody? { get }
    
    /// Timeout interval for this endpoint
    var timeoutInterval: TimeInterval? { get }
    
    /// Cache policy for this endpoint
    var cachePolicy: CachePolicy { get }
    
    /// Retry policy for this endpoint
    var retryPolicy: RetryPolicy { get }
    
    /// Authentication requirement
    var requiresAuthentication: Bool { get }
    
    /// Content type
    var contentType: ContentType { get }
    
    /// Accept type
    var acceptType: ContentType { get }
}

// MARK: - Default Implementations

public extension Endpoint {
    var headers: [String: String] { [:] }
    var queryParameters: [String: Any]? { nil }
    var body: RequestBody? { nil }
    var timeoutInterval: TimeInterval? { nil }
    var cachePolicy: CachePolicy { .default }
    var retryPolicy: RetryPolicy { .default }
    var requiresAuthentication: Bool { false }
    var contentType: ContentType { .json }
    var acceptType: ContentType { .json }
    
    /// Full URL for the endpoint
    var url: URL {
        baseURL.appendingPathComponent(path)
    }
    
    /// Build URLRequest from endpoint
    func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Set timeout
        if let timeout = timeoutInterval {
            request.timeoutInterval = timeout
        }
        
        // Set default headers
        request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        request.setValue(acceptType.rawValue, forHTTPHeaderField: "Accept")
        
        // Set custom headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add query parameters
        if let queryParams = queryParameters, !queryParams.isEmpty {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            components?.queryItems = queryParams.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
            if let urlWithQuery = components?.url {
                request.url = urlWithQuery
            }
        }
        
        // Set body
        if let body = body {
            request.httpBody = try body.encode()
        }
        
        return request
    }
}

// MARK: - Content Type

/// HTTP Content types
public enum ContentType: String, Sendable {
    case json = "application/json"
    case xml = "application/xml"
    case formURLEncoded = "application/x-www-form-urlencoded"
    case multipartFormData = "multipart/form-data"
    case plainText = "text/plain"
    case html = "text/html"
    case octetStream = "application/octet-stream"
}

// MARK: - Request Body

/// Request body container
public enum RequestBody: Sendable {
    case json(Encodable & Sendable)
    case data(Data)
    case formURLEncoded([String: String])
    case multipart([MultipartFormData])
    case raw(Data, contentType: String)
    
    /// Encode the body to Data
    public func encode() throws -> Data {
        switch self {
        case .json(let encodable):
            return try JSONEncoder.networkingDefault.encode(AnyEncodable(encodable))
        case .data(let data):
            return data
        case .formURLEncoded(let params):
            let paramString = params.map { "\($0.key)=\($0.value.urlEncoded)" }.joined(separator: "&")
            guard let data = paramString.data(using: .utf8) else {
                throw NetworkError.encodingFailed(reason: "Failed to encode form data")
            }
            return data
        case .multipart(let parts):
            return try MultipartFormEncoder.encode(parts: parts)
        case .raw(let data, _):
            return data
        }
    }
}

// MARK: - AnyEncodable Wrapper

/// Type-erased Encodable wrapper
public struct AnyEncodable: Encodable, Sendable {
    private let _encode: @Sendable (Encoder) throws -> Void
    
    public init(_ value: Encodable & Sendable) {
        _encode = value.encode
    }
    
    public func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

// MARK: - Multipart Form Data

/// Multipart form data part
public struct MultipartFormData: Sendable {
    public let name: String
    public let data: Data
    public let filename: String?
    public let mimeType: String?
    
    public init(name: String, data: Data, filename: String? = nil, mimeType: String? = nil) {
        self.name = name
        self.data = data
        self.filename = filename
        self.mimeType = mimeType
    }
    
    public init(name: String, value: String) {
        self.name = name
        self.data = value.data(using: .utf8) ?? Data()
        self.filename = nil
        self.mimeType = nil
    }
    
    public init(name: String, fileURL: URL) throws {
        self.name = name
        self.data = try Data(contentsOf: fileURL)
        self.filename = fileURL.lastPathComponent
        self.mimeType = fileURL.mimeType
    }
}

// MARK: - Multipart Encoder

/// Multipart form data encoder
public enum MultipartFormEncoder {
    public static let boundary = "NetworkingArchitecture-\(UUID().uuidString)"
    
    public static func encode(parts: [MultipartFormData]) throws -> Data {
        var data = Data()
        
        for part in parts {
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            
            var disposition = "Content-Disposition: form-data; name=\"\(part.name)\""
            if let filename = part.filename {
                disposition += "; filename=\"\(filename)\""
            }
            disposition += "\r\n"
            data.append(disposition.data(using: .utf8)!)
            
            if let mimeType = part.mimeType {
                data.append("Content-Type: \(mimeType)\r\n".data(using: .utf8)!)
            }
            
            data.append("\r\n".data(using: .utf8)!)
            data.append(part.data)
            data.append("\r\n".data(using: .utf8)!)
        }
        
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return data
    }
}

// MARK: - String Extension

private extension String {
    var urlEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}

// MARK: - URL Extension

private extension URL {
    var mimeType: String {
        let pathExtension = self.pathExtension.lowercased()
        switch pathExtension {
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "gif": return "image/gif"
        case "pdf": return "application/pdf"
        case "json": return "application/json"
        case "xml": return "application/xml"
        case "txt": return "text/plain"
        case "html", "htm": return "text/html"
        case "mp4": return "video/mp4"
        case "mov": return "video/quicktime"
        case "mp3": return "audio/mpeg"
        default: return "application/octet-stream"
        }
    }
}

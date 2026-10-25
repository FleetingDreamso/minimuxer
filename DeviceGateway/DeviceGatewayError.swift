//
//  DeviceGatewayError.swift
//  Minimuxer
//
//  Created by Magesh K on 22/08/26.
//  Copyright © 2026 SideStore. All rights reserved.
//

import Foundation

open class DeviceGatewayError: LocalizedError, CustomStringConvertible, @unchecked Sendable {
    public struct Code: Equatable, Sendable, ExpressibleByStringLiteral {
        public let rawValue: String
        public init(_ rawValue: String) { self.rawValue = rawValue }
        public init(stringLiteral value: String) { self.rawValue = value }

        public static let invalidPairingFile = Code("invalidPairingFile")
        public static let connectionFailed = Code("connectionFailed")
        public static let serviceError = Code("serviceError")
        public static let noConnection = Code("noConnection")
        public static let notInitialized = Code("notInitialized")
        public static let deviceEndpointIpNotAvailable = Code("deviceEndpointIpNotAvailable")
        public static let invalidTargetEndpoint = Code("invalidTargetEndpoint")
        public static let unsupportedOperation = Code("unsupportedOperation")
    }

    public let code: Code
    public let reason: String

    public init(_ code: Code, reason: String = "") {
        self.code = code
        self.reason = reason
    }

    open var errorDescription: String? {
        switch code {
        case .invalidPairingFile:
            return "配对文件无效：\(reason)"
        case .connectionFailed:
            return "连接设备失败：\(reason)"
        case .serviceError:
            return "服务操作失败：\(reason)"
        case .noConnection:
            return reason.isEmpty ? "未连接到设备。" : reason
        case .notInitialized:
            return reason.isEmpty ? "DeviceGateway 尚未初始化，应先调用 start()。" : reason
        case .deviceEndpointIpNotAvailable:
            return reason.isEmpty ? "设备端点 IP 不可用。" : reason
        case .invalidTargetEndpoint:
            return reason.isEmpty ? "目标端点 IP 或端口无效。" : reason
        case .unsupportedOperation:
            return "不支持操作“\(reason)”。"
        default:
            return reason
        }
    }

    public var description: String {
        errorDescription ?? reason
    }
}

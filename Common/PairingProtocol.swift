//
//  PairingProtocol.swift
//  MinimuxerCommon
//
//  Created by Magesh K on 7/8/26.
//  Copyright © 2026 SideStore. All rights reserved.
//

import Foundation

public enum PairingError: LocalizedError, CustomStringConvertible, Sendable {
    case unreadable(String)
    case invalidPlist(String)
    case incomplete(protocolType: PairingProtocol, missingKeys: [String])
    case ambiguous(String)

    public var errorDescription: String? {
        switch self {
        case .unreadable(let reason):
            return "无法读取配对文件：\(reason)"
        case .invalidPlist(let reason):
            return "配对文件无法解析为属性列表（plist）：\(reason)"
        case .incomplete(let protocolType, let missingKeys):
            return "配对文件对 .\(protocolType) 而言不完整。缺少的键：\(missingKeys.joined(separator: "、"))。"
        case .ambiguous(let reason):
            return "配对文件格式存在歧义：\(reason)"
        }
    }

    public var description: String {
        errorDescription ?? "配对错误"
    }
}

public enum PairingProtocol: String, Codable, CustomStringConvertible, Sendable {
    case rppairing = "rppairing"
    case lockdown = "lockdown"
    case unknown = "unknown"
    
    public var description: String {
        return self.rawValue
    }

    public var defaultPort: UInt16 {
        switch self {
        case .rppairing:
            return MinimuxerConstants.remotePairingPort
        case .lockdown:
            return MinimuxerConstants.lockdowndPort
        case .unknown:
            if #available(iOS 17, tvOS 17, *) {
                return MinimuxerConstants.remotePairingPort
            } else {
                return MinimuxerConstants.lockdowndPort
            }
        }
    }
}

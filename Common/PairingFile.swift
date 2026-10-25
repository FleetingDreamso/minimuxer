//
//  PairingFile.swift
//  MinimuxerCommon
//
//  Created by Magesh K on 03/09/26.
//  Copyright © 2026 SideStore. All rights reserved.
//

import Foundation

public protocol PairingFile: Sendable {
    var rawContent: String { get }
    var rawData: Data { get }
    var mode: PairingProtocol { get }
    var plist: [String: any Sendable] { get }
}

public struct RPPairingFile: PairingFile {
    public let rawContent: String
    public let rawData: Data
    public let mode: PairingProtocol = .rppairing
    public let plist: [String: any Sendable]
    public let identifier: String
    public let publicKey: Data?
    public let privateKey: Data?

    fileprivate static func missingKeys(in plist: [String: any Sendable]) -> [String] {
        let requiredKeys = [
            "private_key",
            "public_key",
            "identifier"
        ]
        return requiredKeys.filter { plist[$0] == nil }
    }

    public init(content: String, plist: [String: any Sendable], data: Data) throws {
        let missing = Self.missingKeys(in: plist)
        guard missing.isEmpty else {
            throw PairingError.incomplete(protocolType: .rppairing, missingKeys: missing)
        }
        self.rawContent = content
        self.rawData = data
        self.plist = plist
        self.identifier = plist["identifier"] as? String ?? ""
        self.publicKey = plist["public_key"] as? Data
        self.privateKey = plist["private_key"] as? Data
    }
}

public struct LockdownPairingFile: PairingFile {
    public let rawContent: String
    public let rawData: Data
    public let mode: PairingProtocol = .lockdown
    public let plist: [String: any Sendable]
    public let udid: String
    public let systemBUID: String
    public let hostID: String?
    public let wifiMACAddress: String?
    public let hostCertificate: Data?
    public let rootCertificate: Data?
    public let deviceCertificate: Data?

    fileprivate static func missingKeys(in plist: [String: any Sendable]) -> [String] {
        let requiredKeys = [
            "WiFiMACAddress",
            "SystemBUID",
            "RootPrivateKey",
            "HostPrivateKey",
            "HostID",
            "RootCertificate",
            "UDID",
            "EscrowBag",
            "HostCertificate",
            "DeviceCertificate"
        ]
        return requiredKeys.filter { plist[$0] == nil }
    }

    public init(content: String, plist: [String: any Sendable], data: Data) throws {
        let missing = Self.missingKeys(in: plist)
        guard missing.isEmpty else {
            throw PairingError.incomplete(protocolType: .lockdown, missingKeys: missing)
        }
        self.rawContent = content
        self.rawData = data
        self.plist = plist
        self.udid = plist["UDID"] as? String ?? ""
        self.systemBUID = plist["SystemBUID"] as? String ?? ""
        self.hostID = plist["HostID"] as? String
        self.wifiMACAddress = plist["WiFiMACAddress"] as? String
        self.hostCertificate = plist["HostCertificate"] as? Data
        self.rootCertificate = plist["RootCertificate"] as? Data
        self.deviceCertificate = plist["DeviceCertificate"] as? Data
    }
}

public enum PairingFileParser {
    public static func validatePairingFile(from plist: [String: any Sendable]?, preferred: PairingProtocol? = nil) throws -> PairingProtocol {
        guard let plist = plist else {
            throw PairingError.invalidPlist("该文件无法解析为属性列表（plist）。")
        }

        if let preferred = preferred {
            switch preferred {
                case .rppairing:
                    let missingRemoteRP = RPPairingFile.missingKeys(in: plist)
                    guard missingRemoteRP.isEmpty else {
                        throw PairingError.incomplete(protocolType: .rppairing, missingKeys: missingRemoteRP)
                    }
                    return .rppairing
                case .lockdown:
                    let missingLockdown = LockdownPairingFile.missingKeys(in: plist)
                    guard missingLockdown.isEmpty else {
                        throw PairingError.incomplete(protocolType: .lockdown, missingKeys: missingLockdown)
                    }
                    return .lockdown
                case .unknown:
                    throw PairingError.invalidPlist("指定了未知的配对协议")
            }
        }

        let missingRemoteRP = RPPairingFile.missingKeys(in: plist)
        let missingLockdown = LockdownPairingFile.missingKeys(in: plist)

        let hasRemoteRP = missingRemoteRP.isEmpty
        let hasLockdown = missingLockdown.isEmpty

        if hasRemoteRP && hasLockdown {
            throw PairingError.ambiguous("该配对文件同时包含远程配对（Remote Pairing）与 Lockdown 协议的凭据。请指定首选协议以消除歧义。")
        }

        if hasRemoteRP {
            return .rppairing
        }

        if hasLockdown {
            return .lockdown
        }

        throw PairingError.invalidPlist(
            "无法识别的配对文件格式。" +
            "  • 缺少 .\(PairingProtocol.rppairing) 属性：\(missingRemoteRP)；" +
            "  • 缺少 .\(PairingProtocol.lockdown)  属性：\(missingLockdown)。"
        )
    }

    public static func parse(content: String, preferred: PairingProtocol? = nil) throws -> any PairingFile {
        guard let data = content.data(using: .utf8) else {
            throw PairingError.unreadable("UTF-8 编码失败")
        }
        guard let rawPlist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
            throw PairingError.invalidPlist("属性列表序列化失败")
        }
        let plist = ConcurrencyUtils.toSendableDictionary(rawPlist)
        let mode = try validatePairingFile(from: plist, preferred: preferred)
        switch mode {
            case .rppairing:
                return try RPPairingFile(content: content, plist: plist, data: data)
            case .lockdown:
                return try LockdownPairingFile(content: content, plist: plist, data: data)
            case .unknown:
                throw PairingError.invalidPlist("未知的配对文件格式")
        }
    }
}

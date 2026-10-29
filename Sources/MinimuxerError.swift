//
//  MinimuxerErrors.swift
//  Minimuxer
//
//  Created by Magesh K on 4/7/26.
//  Copyright © 2026 SideStore. All rights reserved.
//

import Foundation
import DeviceGatewayAPI
public import MinimuxerCommon

public struct MinimuxerServiceError: Error, CustomStringConvertible {
    public let component: MinimuxerComponent
    public let error: Error
    
    public var description: String {
        return "[\(component.rawValue)] \(error.localizedDescription)"
    }
}

public enum MinimuxerError: Error, Equatable, CustomStringConvertible, LocalizedError {
    case noDevice(String)
    case noConnection(String)
    case notReachable(String)
    case noVPN(String)
    case notStarted(String)
    case pairingNotLoaded(String)
    case connectionModeNotConfigured(String)
    case restartAlreadyInProgressError(String)
    case invalidVPN(String)
    case invalidPairing(protocol: PairingProtocol, reason: String)
    case muxerNotListening(String)

    case createDebug(String)
    case createInstproxy(String)
    case createLockdown(String)
    case createCoreDevice(String)
    case createSoftwareTunnel(String)
    case createRemoteServer(String)
    case createProcessControl(String)

    case getLockdownValue(String)
    case fetchUDID(String)
    case connect(String)
    case close(String)
    case xpcHandshake(String)
    case noService(String)
    case invalidProductVersion(String)
    case lookupApps(String)
    case findApp(String)
    case bundlePath(String)
    case maxPacket(String)
    case workingDirectory(String)
    case argv(String)
    case launchSuccess(String)
    case detach(String)
    case attach(String)

    case createAfc(String)
    case rwAfc(String)
    case installApp(String)
    case uninstallApp(String)

    case createMisagent(String)
    case profileInstall(String)
    case profileRemove(String)

    case createFolder(String)
    case downloadImage(String)
    case imageLookup(String)
    case imageRead(String)
    case mount(protocol: PairingProtocol, reason: String)

    public var description: String {
        switch self {
        case .noDevice(let r): return "设备不可用：\(r)"
        case .noConnection(let r): return "无网络连接：\(r)"
        case .notReachable(let r): return "无法连接：\(r)"
        case .noVPN(let r): return "VPN 隧道未建立：\(r)"
        case .notStarted(let r): return "未就绪：\(r)"
        case .pairingNotLoaded(let r): return "配对不可用：\(r)"
        case .restartAlreadyInProgressError(let r): return "重启已在进行中：\(r)"
        case .invalidVPN(let r): return "VPN 连接错误：\(r)"
        case .invalidPairing(let proto, let reason): return "配对无效（协议：\(proto)，原因：\(reason)）"
        case .muxerNotListening(let r): return "服务不可用：\(r)"
        case .createDebug(let r): return "创建调试服务失败：\(r)"
        case .createInstproxy(let r): return "创建 instproxy 服务失败：\(r)"
        case .createLockdown(let r): return "创建 lockdown 服务失败：\(r)"
        case .createCoreDevice(let r): return "创建 CoreDevice 服务失败：\(r)"
        case .createSoftwareTunnel(let r): return "创建软件隧道失败：\(r)"
        case .createRemoteServer(let r): return "创建远程服务失败：\(r)"
        case .createProcessControl(let r): return "创建进程控制服务失败：\(r)"
        case .getLockdownValue(let r): return "读取 lockdown 值失败：\(r)"
        case .fetchUDID(let r): return "获取 UDID 失败：\(r)"
        case .connect(let r): return "连接失败：\(r)"
        case .close(let r): return "关闭连接失败：\(r)"
        case .xpcHandshake(let r): return "XPC 握手失败：\(r)"
        case .noService(let r): return "服务不存在：\(r)"
        case .invalidProductVersion(let r): return "产品版本无效：\(r)"
        case .lookupApps(let r): return "查询应用列表失败：\(r)"
        case .findApp(let r): return "查找应用失败：\(r)"
        case .bundlePath(let r): return "获取应用包路径失败：\(r)"
        case .maxPacket(let r): return "数据包大小无效：\(r)"
        case .workingDirectory(let r): return "工作目录无效：\(r)"
        case .argv(let r): return "启动参数无效：\(r)"
        case .launchSuccess(let r): return "启动应用失败：\(r)"
        case .detach(let r): return "分离进程失败：\(r)"
        case .attach(let r): return "附加进程失败：\(r)"
        case .createAfc(let r): return "创建 AFC 服务失败：\(r)"
        case .rwAfc(let r): return "AFC 读写失败：\(r)"
        case .installApp(let msg): return "安装应用失败：\(msg)"
        case .uninstallApp(let r): return "卸载应用失败：\(r)"
        case .createMisagent(let r): return "创建 misagent 服务失败：\(r)"
        case .profileInstall(let r): return "安装描述文件失败：\(r)"
        case .profileRemove(let r): return "移除描述文件失败：\(r)"
        case .createFolder(let r): return "创建文件夹失败：\(r)"
        case .downloadImage(let r): return "下载磁盘映像失败：\(r)"
        case .imageLookup(let r): return "查询磁盘映像失败：\(r)"
        case .imageRead(let r): return "读取磁盘映像失败：\(r)"
        case .mount(let proto, let reason): return "挂载磁盘映像失败（协议：\(proto)，原因：\(reason)）"
        case .connectionModeNotConfigured(let r): return "连接配置有误：\(r)"
        }
    }

    public var errorDescription: String? {
        return self.description
    }
}

extension DeviceGatewayError {
    var isVPNDrop: Bool {
        guard code == .connectionFailed || code == .serviceError else { return false }
        let lower = reason.lowercased()
        return lower.contains("broken pipe")        || lower.contains("brokenpipe")         ||
               lower.contains("connection reset")   || lower.contains("connectionreset")    ||
               lower.contains("early eof")          || lower.contains("unexpectedeof")      ||
               lower.contains("no route to host")   || lower.contains("connection refused")
    }

    var isRetryable: Bool {
        (code == .connectionFailed || code == .noConnection) && !isVPNDrop
    }

    func asMinimuxerError(protocol activeProtocol: PairingProtocol, catchAll: (String) -> MinimuxerError) -> MinimuxerError {
        if code == .invalidPairingFile {
            return .invalidPairing(protocol: activeProtocol, reason: reason)
        }
        if isVPNDrop {
            return .invalidVPN(reason)
        }
        return catchAll(reason)
    }
}

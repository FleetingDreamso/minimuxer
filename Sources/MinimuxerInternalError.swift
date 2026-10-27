//
//  MinimuxerInternalError.swift
//  Minimuxer
//
//  Created by Magesh K on 4/7/26.
//  Copyright © 2026 SideStore. All rights reserved.
//

import Foundation

internal enum MinimuxerInternalError: Error, LocalizedError {
    case deviceEndpointNotInitialized
    case networkIfaceNotRefreshed
    case pairingFailed(String)

    var errorDescription: String? {
        switch self {
        case .deviceEndpointNotInitialized: return "设备端点未初始化"
        case .networkIfaceNotRefreshed: return "网络接口未刷新"
        case .pairingFailed(let msg): return "配对失败（\(msg)）"
        }
    }
}
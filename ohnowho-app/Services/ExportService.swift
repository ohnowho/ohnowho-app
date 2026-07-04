//
//  ExportService.swift
//  ohnowho-app
//
//  Created by konan on 7/4/26.
//

import Foundation

/// 数据导入导出服务
/// Phase 1 仅定义接口，Phase 6 完整实现
final class ExportService {

    /// 导出所有数据为 zip 包
    /// - Returns: 导出的 zip 文件 URL
    func exportToZip() async throws -> URL {
        fatalError("尚未实现 - Phase 6")
    }

    /// 从 zip 包导入数据
    /// - Parameter url: zip 文件 URL
    func importFromZip(_ url: URL) async throws {
        fatalError("尚未实现 - Phase 6")
    }
}

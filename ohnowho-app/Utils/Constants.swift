//
//  Constants.swift
//  ohnowho-app
//
//  Created by konan on 7/4/26.
//

import SwiftUI
import MapKit

enum Constants {
    // MARK: - 主题色
    static let accent = Color(hex: "#B22222")

    // MARK: - SF Symbols
    static let plusIcon = "plus.circle.fill"
    static let pinIcon = "mappin"
    static let searchIcon = "magnifyingglass"
    static let clearIcon = "xmark.circle.fill"
    static let locationIcon = "location"
    static let locationFillIcon = "location.fill"
    static let gearIcon = "gearshape"

    // MARK: - 存储路径
    static let mediaDirectory = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask).first!
        .appendingPathComponent("media")
    static let exportDirectory = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask).first!
        .appendingPathComponent("exports")

    // MARK: - 地图默认区域（中国范围）
    static let defaultLatitude: CLLocationDegrees = 35.0
    static let defaultLongitude: CLLocationDegrees = 105.0
    static let defaultZoom: CLLocationDistance = 5_000_000
}

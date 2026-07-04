//
//  LocationService.swift
//  ohnowho-app
//
//  Created by konan on 7/4/26.
//

import CoreLocation

@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var currentLocation: CLLocation?
    var currentAddress: String?

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    /// 请求"使用期间"定位权限
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    /// 开始更新位置
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }

    /// 停止更新位置（省电）
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }

    /// 反向地理编码
    func reverseGeocode(_ location: CLLocation) async -> String? {
        guard let placemark = try? await geocoder.reverseGeocodeLocation(location).first else {
            return nil
        }
        let address = [
            placemark.name,
            placemark.locality,
            placemark.administrativeArea,
            placemark.country
        ]
            .compactMap { $0 }
            .joined(separator: ", ")
        return address.isEmpty ? nil : address
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationService 定位失败: \(error.localizedDescription)")
    }
}

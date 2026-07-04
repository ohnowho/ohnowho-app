//
//  MapViewModel.swift
//  ohnowho-app
//
//  Created by konan on 7/4/26.
//

import MapKit
import SwiftUI

@Observable
final class MapViewModel {
    var cameraPosition: MapCameraPosition = .automatic
    var notes: [Note] = []
    var selectedNote: Note?
    var isShowingNoteCard = false

    private var dataService: DataService?
    private var locationService: LocationService?

    func setup(dataService: DataService, locationService: LocationService) {
        self.dataService = dataService
        self.locationService = locationService
        refreshNotes()
    }

    // MARK: - 笔记操作

    func refreshNotes() {
        notes = dataService?.fetchAllNotes() ?? []
    }

    func selectNote(_ note: Note) {
        selectedNote = note
        isShowingNoteCard = true
    }

    func dismissNoteCard() {
        isShowingNoteCard = false
        selectedNote = nil
    }

    // MARK: - 定位操作

    func centerOnUser() {
        guard let location = locationService?.currentLocation else {
            locationService?.startUpdatingLocation()
            return
        }
        let region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        cameraPosition = .region(region)
    }

    func setDefaultRegion() {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: Constants.defaultLatitude,
                longitude: Constants.defaultLongitude
            ),
            span: MKCoordinateSpan(
                latitudeDelta: Constants.defaultZoom / 111_000,
                longitudeDelta: Constants.defaultZoom / 111_000
            )
        )
        cameraPosition = .region(region)
    }
}

//
//  MapView.swift
//  ohnowho-app
//
//  Created by konan on 7/4/26.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        Map(initialPosition: position)
            .ignoresSafeArea()
    }
}

#Preview {
    MapView()
}

//
//  MapView.swift
//  ohnowho-app
//
//  Created by konan on 7/4/26.
//

import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @Environment(DataService.self) private var dataService
    @State private var viewModel = MapViewModel()
    @State private var locationService = LocationService()
    @State private var selectedNoteId: UUID?
    @State private var showNewNoteSheet = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // MARK: - 地图
            Map(position: $viewModel.cameraPosition, selection: $selectedNoteId) {
                // 用户位置（蓝点）
                UserAnnotation()

                // 笔记 Pin
                ForEach(viewModel.notes) { note in
                    Marker(
                        note.title ?? "笔记",
                        systemImage: "mappin",
                        coordinate: CLLocationCoordinate2D(
                            latitude: note.latitude,
                            longitude: note.longitude
                        )
                    )
                    .tint(Constants.accent)
                    .tag(note.id)
                }
            }
            .mapStyle(.standard)
                        .ignoresSafeArea()
            .onChange(of: selectedNoteId) { _, newId in
                if let id = newId,
                   let note = viewModel.notes.first(where: { $0.id == id }) {
                    viewModel.selectNote(note)
                }
            }
            .onAppear {
                viewModel.setup(dataService: dataService, locationService: locationService)
                locationService.requestPermission()
                locationService.startUpdatingLocation()
            }

            // MARK: - 悬浮按钮组
            VStack(spacing: 16) {
                // 回到当前位置
                Button {
                    viewModel.centerOnUser()
                } label: {
                    Image(systemName: Constants.locationFillIcon)
                        .font(.title3)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }

                // 新建笔记
                Button {
                    showNewNoteSheet = true
                } label: {
                    Image(systemName: Constants.plusIcon)
                        .font(.title)
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(Constants.accent)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
            }
            .padding(.trailing, 20)
            .padding(.bottom, 30)

            // MARK: - 笔记卡片
            if viewModel.isShowingNoteCard, let note = viewModel.selectedNote {
                VStack {
                    Spacer()
                    NoteCardView(
                        note: note,
                        onDismiss: { viewModel.dismissNoteCard() },
                        onViewDetail: { _ in }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: viewModel.isShowingNoteCard)
        .sheet(isPresented: $showNewNoteSheet) {
            // Phase 3 占位：新建笔记 Sheet
            Text("新建笔记（Phase 3 实现）")
                .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Note.self, MediaAsset.self, configurations: config)
    let dataService = DataService(context: container.mainContext)

    return MapView()
        .environment(dataService)
}

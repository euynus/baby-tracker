//
//  PhotoGalleryView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI
import SwiftData
import PhotosUI

struct PhotoGalleryView: View {
    let baby: Baby

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PhotoRecord.timestamp, order: .reverse) private var allPhotos: [PhotoRecord]

    @State private var selectedItem: PhotosPickerItem?
    @State private var showingImagePicker = false

    private var photos: [PhotoRecord] {
        allPhotos.filter { $0.babyId == baby.id }
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        GeometryReader { geometry in
            let size = (geometry.size.width - 4) / 3

            if photos.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 56))
                        .foregroundStyle(.secondary.opacity(0.5))
                    Text("还没有照片")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("点击右上角添加")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .fadeIn()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(photos) { photo in
                            if let uiImage = UIImage(data: photo.imageData) {
                                NavigationLink {
                                    PhotoDetailView(photo: photo)
                                } label: {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: size, height: size)
                                        .clipped()
                                }
                                .fadeIn()
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("照片")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Image(systemName: "plus")
                }
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    addPhoto(data: data)
                }
            }
        }
    }

    private func addPhoto(data: Data) {
        let photo = PhotoRecord(babyId: baby.id, timestamp: Date(), imageData: data)
        modelContext.insert(photo)
    }
}

struct PhotoDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let photo: PhotoRecord

    @State private var caption: String
    @State private var showingDeleteAlert = false

    init(photo: PhotoRecord) {
        self.photo = photo
        _caption = State(initialValue: photo.caption ?? "")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let uiImage = UIImage(data: photo.imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(AppTheme.cornerRadiusMedium)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("说明")
                        .font(.headline)

                    TextEditor(text: $caption)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(AppTheme.cornerRadiusSmall)

                    Button("保存说明") {
                        saveCaption()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                }
                .padding()

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("拍摄时间")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(photo.timestamp, style: .date)
                        Text(photo.timestamp, style: .time)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(AppTheme.cornerRadiusMedium)
                .padding(.horizontal)

                Button(role: .destructive, action: { showingDeleteAlert = true }) {
                    Label("删除照片", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("照片详情")
        .navigationBarTitleDisplayMode(.inline)
        .alert("删除照片", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                deletePhoto()
            }
        } message: {
            Text("确定要删除这张照片吗？此操作无法撤销。")
        }
    }

    private func saveCaption() {
        photo.caption = caption.isEmpty ? nil : caption
    }

    private func deletePhoto() {
        modelContext.delete(photo)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        PhotoGalleryView(baby: Baby(name: "小宝", birthday: Date(), gender: .male))
    }
    .modelContainer(for: [PhotoRecord.self])
}

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
    @Query private var photos: [PhotoRecord]

    @State private var selectedItem: PhotosPickerItem?
    @State private var showingSaveError = false
    @State private var saveErrorMessage = ""

    init(baby: Baby) {
        self.baby = baby
        let babyId = baby.id
        _photos = Query(
            filter: #Predicate<PhotoRecord> { $0.babyId == babyId },
            sort: \PhotoRecord.timestamp,
            order: .reverse
        )
    }

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                heroCard

                if photos.isEmpty {
                    emptyStateCard
                } else {
                    photoGrid
                }
            }
            .padding(.horizontal, AppTheme.paddingMedium)
            .padding(.vertical, 12)
        }
        .navigationTitle("照片")
        .navigationBarTitleDisplayMode(.inline)
        .appPageBackground()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("添加", systemImage: "plus")
                        .labelStyle(.iconOnly)
                }
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            guard let newItem else { return }
            Task { @MainActor in
                do {
                    if let data = try await newItem.loadTransferable(type: Data.self) {
                        addPhoto(data: data)
                    } else {
                        saveErrorMessage = "无法读取所选照片，请重试。"
                        showingSaveError = true
                    }
                } catch {
                    saveErrorMessage = "读取照片失败：\(error.localizedDescription)"
                    showingSaveError = true
                }
                selectedItem = nil
            }
        }
        .alert("保存失败", isPresented: $showingSaveError) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(saveErrorMessage)
        }
    }

    private var heroCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "photo.stack")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(Color.white.opacity(0.22))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text("\(baby.name) 的成长相册")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("共 \(photos.count) 张照片")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
            }

            Spacer()
        }
        .padding(16)
        .gradientCard([AppTheme.secondary, AppTheme.accent])
    }

    private var emptyStateCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 50))
                .foregroundStyle(.secondary.opacity(0.55))
            Text("还没有照片")
                .font(.headline)
            Text("点击右上角添加第一张成长照片")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .cardStyle()
    }

    private var photoGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(photos) { photo in
                if let uiImage = UIImage(data: photo.imageData) {
                    NavigationLink {
                        PhotoDetailView(photo: photo)
                    } label: {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 110)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .fadeIn()
                }
            }
        }
        .padding(12)
        .cardStyle()
    }

    private func addPhoto(data: Data) {
        let photo = PhotoRecord(babyId: baby.id, timestamp: Date(), imageData: data)
        do {
            try modelContext.insertAndSave(photo)
        } catch {
            saveErrorMessage = error.localizedDescription
            showingSaveError = true
        }
    }
}

struct PhotoDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let photo: PhotoRecord

    @State private var caption: String
    @State private var showingDeleteAlert = false
    @State private var showingSaveError = false
    @State private var saveErrorMessage = ""

    init(photo: PhotoRecord) {
        self.photo = photo
        _caption = State(initialValue: photo.caption ?? "")
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                imageCard
                captionCard
                metaCard
                deleteButton
            }
            .padding(.horizontal, AppTheme.paddingMedium)
            .padding(.vertical, 12)
        }
        .navigationTitle("照片详情")
        .navigationBarTitleDisplayMode(.inline)
        .appPageBackground()
        .confirmationDialog(
            "确定要删除这张照片吗？此操作无法撤销。",
            isPresented: $showingDeleteAlert,
            titleVisibility: .visible
        ) {
            Button("删除", role: .destructive) {
                deletePhoto()
            }
            Button("取消", role: .cancel) { }
        }
        .alert("保存失败", isPresented: $showingSaveError) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(saveErrorMessage)
        }
    }

    private var imageCard: some View {
        Group {
            if let uiImage = UIImage(data: photo.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(12)
        .cardStyle()
    }

    private var captionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("说明")
                .font(.headline)

            TextEditor(text: $caption)
                .frame(height: 100)
                .padding(6)
                .background(AppTheme.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Button("保存说明") {
                saveCaption()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [AppTheme.secondary, AppTheme.brand],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
            .scaleButton()
        }
        .padding(14)
        .cardStyle()
    }

    private var metaCard: some View {
        VStack(spacing: 10) {
            row(symbol: "calendar", title: "拍摄日期", value: photo.timestamp.formatted(date: .abbreviated, time: .omitted))
            row(symbol: "clock", title: "拍摄时间", value: photo.timestamp.formatted(date: .omitted, time: .shortened))
        }
        .padding(14)
        .cardStyle()
    }

    private var deleteButton: some View {
        Button(role: .destructive, action: { showingDeleteAlert = true }) {
            Label("删除照片", systemImage: "trash")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
        }
        .background(Color.red.opacity(0.16))
        .foregroundStyle(.red)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
    }

    private func row(symbol: String, title: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.secondary)
                .frame(width: 28, height: 28)
                .background(AppTheme.secondary.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.semibold))
        }
    }

    private func saveCaption() {
        photo.caption = caption.isEmpty ? nil : caption
        do {
            try modelContext.saveIfNeeded()
        } catch {
            saveErrorMessage = error.localizedDescription
            showingSaveError = true
        }
    }

    private func deletePhoto() {
        modelContext.delete(photo)
        do {
            try modelContext.saveIfNeeded()
            dismiss()
        } catch {
            saveErrorMessage = error.localizedDescription
            showingSaveError = true
        }
    }
}

#Preview {
    NavigationStack {
        PhotoGalleryView(baby: Baby(name: "小宝", birthday: Date(), gender: .male))
    }
    .modelContainer(for: [PhotoRecord.self])
}

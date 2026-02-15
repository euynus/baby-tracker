import XCTest
import SwiftData
@testable import BabyTracker

@MainActor
final class CorePersistenceRegressionTests: XCTestCase {

    private func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: Baby.self,
            FeedingRecord.self,
            SleepRecord.self,
            DiaperRecord.self,
            GrowthRecord.self,
            PhotoRecord.self,
            configurations: config
        )
    }

    func testModelContainerInitializationSucceeds() throws {
        XCTAssertNoThrow(try makeContainer())
    }

    func testCreateBabyAndPersist() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let birthday = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let baby = Baby(name: "回归测试宝宝", birthday: birthday, gender: .female)

        context.insert(baby)
        try context.save()

        let babies = try context.fetch(FetchDescriptor<Baby>())
        XCTAssertEqual(babies.count, 1)
        XCTAssertEqual(babies.first?.name, "回归测试宝宝")
        XCTAssertEqual(babies.first?.gender, .female)
    }

    func testPersistAllRecordTypesForBaby() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let baby = Baby(name: "记录测试宝宝", birthday: Date(), gender: .male)
        context.insert(baby)

        let feeding = FeedingRecord(babyId: baby.id, timestamp: Date(), method: .bottle)
        feeding.amount = 120

        let sleep = SleepRecord(babyId: baby.id, startTime: Date().addingTimeInterval(-1800))
        sleep.endTime = Date()

        let diaper = DiaperRecord(babyId: baby.id, timestamp: Date(), hasWet: true, hasDirty: true)

        let growth = GrowthRecord(babyId: baby.id, timestamp: Date())
        growth.weight = 5800
        growth.height = 61.2

        let photo = PhotoRecord(babyId: baby.id, timestamp: Date(), imageData: Data([0x01, 0x02]))

        context.insert(feeding)
        context.insert(sleep)
        context.insert(diaper)
        context.insert(growth)
        context.insert(photo)
        try context.save()

        let feedingCount = try context.fetchCount(FetchDescriptor<FeedingRecord>())
        let sleepCount = try context.fetchCount(FetchDescriptor<SleepRecord>())
        let diaperCount = try context.fetchCount(FetchDescriptor<DiaperRecord>())
        let growthCount = try context.fetchCount(FetchDescriptor<GrowthRecord>())
        let photoCount = try context.fetchCount(FetchDescriptor<PhotoRecord>())

        XCTAssertEqual(feedingCount, 1)
        XCTAssertEqual(sleepCount, 1)
        XCTAssertEqual(diaperCount, 1)
        XCTAssertEqual(growthCount, 1)
        XCTAssertEqual(photoCount, 1)
    }

    func testUpdateBabyProfileAndPersist() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let baby = Baby(name: "旧名字", birthday: Date(), gender: .male)
        context.insert(baby)
        try context.save()

        baby.name = "新名字"
        baby.latestWeight = 6200
        baby.latestHeight = 63.1
        baby.latestHeadCircumference = 40.2
        try context.save()

        let babies = try context.fetch(FetchDescriptor<Baby>())
        let persisted = babies.first(where: { $0.id == baby.id })

        XCTAssertEqual(persisted?.name, "新名字")
        XCTAssertEqual(persisted?.latestWeight, 6200)
        XCTAssertEqual(persisted?.latestHeight, 63.1)
        XCTAssertEqual(persisted?.latestHeadCircumference, 40.2)
    }
}

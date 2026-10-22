import Foundation

// The production observers call this spy by their unchanged UserDefaults name.
// No standard preferences, timers, or app services are touched by this fixture.
enum UserDefaults {
    static let standard = TestDefaults()
}

final class TestDefaults {
    var values: [String: Int] = [:]
    var writes: [(String, Int)] = []

    func set(_ value: Int, forKey key: String) {
        values[key] = value
        writes.append((key, value))
    }
}

@main
enum BackgroundIntervalObserverTests {
    @MainActor
    static func main() {
        let cases: [(String, ReferenceWritableKeyPath<BackgroundIntervalHarness, Int>, Int)] = [
            ("scheduledRestoreInterval", \.scheduledRestoreInterval, 8_760),
            ("customScheduledRestoreInterval", \.customScheduledRestoreInterval, 8_760),
            ("autoRestoreCheckInterval", \.autoRestoreCheckInterval, 525_600),
        ]

        for (key, property, maximum) in cases {
            let harness = BackgroundIntervalHarness()
            for (input, expected) in [(Int.max, maximum), (0, 1), (17, 17)] {
                UserDefaults.standard.values.removeAll()
                UserDefaults.standard.writes.removeAll()
                harness.rescheduleRequests.removeAll()

                harness[keyPath: property] = input

                guard harness[keyPath: property] == expected else {
                    fail("\(key) did not normalize \(input) to \(expected)")
                }
                guard UserDefaults.standard.values[key] == expected,
                      UserDefaults.standard.writes.count == 1,
                      UserDefaults.standard.writes.first?.0 == key,
                      UserDefaults.standard.writes.first?.1 == expected else {
                    fail("\(key) must save the normalized value exactly once for input \(input)")
                }
                guard harness.rescheduleRequests == [true] else {
                    fail("\(key) must reschedule exactly once for input \(input), got \(harness.rescheduleRequests)")
                }
                print("PASS: \(key) input=\(input) value=\(expected) writes=1 reschedules=1")
            }
        }
    }

    private static func fail(_ message: String) -> Never {
        fputs("FAIL: \(message)\n", stderr)
        exit(1)
    }
}

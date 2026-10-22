import Foundation

@main enum FilePathTests {
    static func main() {
        for path in ["/tmp/100%20real.app", "/tmp/100 real.app", "/tmp/100%2Freal", "/tmp/中文 %25", "/tmp/100%ZZ"] {
            let url = URL(fileURLWithPath: path)
            precondition(url.universalPath() == path, "File names must not be percent decoded twice")
            precondition(URL(string: url.absoluteString)!.universalPath() == path, "Encoded file URLs must decode exactly once")
        }
        print("PASS: literal percent names and encoded URLs preserve the exact target path")
    }
}

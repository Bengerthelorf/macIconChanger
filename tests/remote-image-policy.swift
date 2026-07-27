import Foundation

@main
struct RemoteImagePolicyTests {
    static func main() {
        precondition(
            RemoteImagePolicy.acceptsRemoteURL(URL(string: "https://cdn.example.com/icon.png")!)
        )
        precondition(
            !RemoteImagePolicy.acceptsRemoteURL(URL(string: "http://cdn.example.com/icon.png")!)
        )
        precondition(
            !RemoteImagePolicy.acceptsRemoteURL(URL(string: "https://user:secret@cdn.example.com/icon.png")!)
        )
        precondition(
            RemoteImagePolicy.acceptsContentLength(Int64(RemoteImagePolicy.maxResponseBytes))
        )
        precondition(
            !RemoteImagePolicy.acceptsContentLength(
                Int64(RemoteImagePolicy.maxResponseBytes + 1)
            )
        )
        precondition(RemoteImagePolicy.acceptsContentLength(-1))

        print("PASS: remote images require credential-free HTTPS and bounded responses")
    }
}

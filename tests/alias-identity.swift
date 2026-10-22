import Foundation

@main
enum AliasIdentityTests {
    static func main() {

        let first = AliasName(appName: "", aliasName: "")
        var second = AliasName(appName: "", aliasName: "")
        precondition(first.id != second.id, "new alias rows need distinct identities")
        let identity = second.id
        second.appName = "Renamed App"
        precondition(second.id == identity, "editing a name must preserve row selection identity")
        print("PASS: alias rows have stable unique identities while adding and editing")
    }
}

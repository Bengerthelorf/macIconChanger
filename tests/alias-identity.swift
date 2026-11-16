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
        let folder = URL(fileURLWithPath: "/fixtures/Projects.v2")
        let app = URL(fileURLWithPath: "/fixtures/Editor.app")
        precondition(AliasName.key(for: folder) == "Projects.v2")
        precondition(AliasName.key(for: app) == "Editor")
        precondition(AliasName.getName(for: folder, aliases: ["Projects.v2": "folder", "Projects": "legacy"]) == "folder")
        precondition(AliasName.getName(for: folder, aliases: ["Projects": "legacy"]) == "legacy")
        precondition(AliasName.getName(for: app, aliases: ["Editor": "  Code \n"]) == "Code")
        precondition(AliasName.getName(for: folder, aliases: ["Projects.v2": " ", "Projects": "legacy"]) == nil)
        precondition(AliasName.getName(for: folder, aliases: ["Projects": "legacy"], removedAliases: ["Projects.v2"]) == nil)
        precondition(AliasName.getName(for: folder, aliases: ["Projects.v2": "folder"], removedAliases: ["Projects.v2"]) == "folder")
        print("PASS: alias rows have stable unique identities while adding and editing")
    }
}

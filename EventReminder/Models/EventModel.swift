import Foundation

struct Event: Identifiable, Equatable {
    let id = UUID()
    var dateString: String
    var name: String
    var description: String
    var date: Date
}

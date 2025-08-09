import Combine
import SwiftUI

class EventsViewModel: ObservableObject {
    @Published var events: [Event] = [
        Event(dateString: "12 декабря", name: "Мероприятие 1", description: "Описание 1", date: Date(), details: "Детали 1"),
        Event(dateString: "15 декабря", name: "Мероприятие 2", description: "Описание 2", date: Date(), details: "Детали 2")
    ]
    
    @Published var openedEventID: UUID? = nil
    @Published var currentDate = Date()
    @Published var selectedEvent: Event? = nil
    
    func addEvent() {
        let newEvent = Event(
            dateString: "Новая дата",
            name: "Новое событие \(events.count + 1)",
            description: "",
            date: Date(),
            details: ""
        )
        withAnimation {
            events.append(newEvent)
        }
    }
    
    func deleteEvent(_ event: Event) {
        if let index = events.firstIndex(of: event) {
            events.remove(at: index)
        }
    }
    
    func updateEvent(_ event: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
        }
    }
}

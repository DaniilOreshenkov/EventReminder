import SwiftUI

struct Event: Identifiable, Equatable {
    let id = UUID()
    var dateString: String
    var name: String
    var description: String
    var date: Date
    var details: String
}

struct ContentView: View {
    @State private var events: [Event] = [
        Event(dateString: "12 декабря", name: "Мероприятие 1", description: "Описание 1", date: Date(), details: "Детали 1"),
        Event(dateString: "15 декабря", name: "Мероприятие 2", description: "Описание 2", date: Date(), details: "Детали 2")
    ]
    @State private var openedEventID: UUID? = nil
    @State private var editingEvent: Event? = nil
    @State private var currentDate = Date()
    @State private var titleDisplayMode: NavigationBarItem.TitleDisplayMode = .large
    @State private var scrollOffset: CGFloat = 0
    
    @State private var selectedEvent: Event? = nil
    @State private var isShowingDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Основной скролл
                ScrollView {
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: OffsetPreferenceKey.self, value: geo.frame(in: .named("scroll")).minY)
                    }
                    .frame(height: 0)
                    
                    LazyVStack(spacing: 8) {
                        ForEach(events) { event in
                            SwipeableEventRow(
                                event: event,
                                openedEventID: $openedEventID,
                                onEdit: {
                                    editingEvent = event
                                },
                                onDelete: {
                                    if let index = events.firstIndex(of: event) {
                                        events.remove(at: index)
                                    }
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                    .padding(.bottom, 80)
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(OffsetPreferenceKey.self) { value in
                    self.scrollOffset = value
                    withAnimation {
                        if value < -50 {
                            self.titleDisplayMode = .inline
                        } else {
                            self.titleDisplayMode = .large
                        }
                    }
                }
                
                // Кнопка + внизу
                VStack {
                    Spacer()
                    Button(action: {
                        let newEvent = Event(
                            dateString: "Новая дата",
                            name: "Новое событие \(events.count + 1)",
                            description: "",
                            date: Date(),
                            details: ""
                        )
                        withAnimation(.easeInOut(duration: 0.3)) {
                            events.append(newEvent)
                        }
                    }) {
                        Text("Добавить")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .sheet(item: $editingEvent) { event in
                AddEditEventView(existingEvent: event) { updatedEvent in
                    if let index = events.firstIndex(where: { $0.id == event.id }) {
                        events[index] = updatedEvent
                    }
                }
            }
            .navigationBarTitle("Мой дневник", displayMode: titleDisplayMode)
            .toolbar {
                if titleDisplayMode == .inline {
                    //                    VStack {
                    //                        Text("Сегодня, \(formattedDate)")
                    //                            .font(.subheadline)
                    //                            .foregroundColor(.gray)
                    //                    }
                    //                    .hidden()
                    //                    .transition(.opacity.combined(with: .move(edge: .top)))
                    //                    .animation(.easeInOut, value: titleDisplayMode)
                }
            }
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                    self.currentDate = Date()
                }
            }
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: currentDate)
    }
}

// Определение PreferenceKey для отслеживания прокрутки
struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


struct EventCard: View {
    let event: Event
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.name)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            Text(event.description)
                .font(.subheadline)
            Divider()
            
            HStack {
                Text("Дата: \(event.dateString)")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                Spacer()
                Menu {
                    Button(action: {
                        onEdit()
                    }) {
                        Label("Редактировать", systemImage: "pencil")
                    }
                    Button(action: {
                        onDelete()
                    }) {
                        Label("Удалить", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                        .padding(10)
                }
            }
        }
        .padding(.leading)
        .padding(.top)
        .padding(.bottom, 8)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

struct AddEditEventView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var name: String
    @State private var description: String
    @State private var details: String
    @State private var date: Date
    let existingEvent: Event
    var onSave: (Event) -> Void
    
    init(existingEvent: Event, onSave: @escaping (Event) -> Void) {
        self.existingEvent = existingEvent
        _name = State(initialValue: existingEvent.name)
        _description = State(initialValue: existingEvent.description)
        _details = State(initialValue: existingEvent.details)
        _date = State(initialValue: existingEvent.date)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Основные данные")) {
                    TextField("Название", text: $name)
                        .font(.system(size: 16))
                    TextField("Описание", text: $description)
                        .font(.system(size: 16))
                    TextField("Дополнительные детали", text: $details)
                        .font(.system(size: 16))
                }
                Section(header: Text("Дата")) {
                    DatePicker("Выберите дату", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
            }
            .navigationTitle("Редактировать событие")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "d MMMM"
                        formatter.locale = Locale(identifier: "ru_RU")
                        let dateString = formatter.string(from: date)
                        let updatedEvent = Event(
                            dateString: dateString,
                            name: name,
                            description: description,
                            date: date,
                            details: details
                        )
                        onSave(updatedEvent)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct SwipeableEventRow: View {
    let event: Event
    @Binding var openedEventID: UUID?
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var offsetX: CGFloat = 0
    @State private var isDragging = false
    
    // Размер кнопки
    private let buttonSize: CGFloat = 50
    
    var body: some View {
        ZStack {
            // Фон с кнопками
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        resetOffset()
                        onEdit()
                        // Закрываем текущий
                        openedEventID = nil
                    }
                }) {
                    Image(systemName: "pencil")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: buttonSize * 0.4, height: buttonSize * 0.4)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                        .frame(width: buttonSize, height: buttonSize)
                }
                Button(action: {
                    withAnimation {
                        resetOffset()
                        onDelete()
                        // Закрываем текущий
                        openedEventID = nil
                    }
                }) {
                    Image(systemName: "trash")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: buttonSize * 0.4, height: buttonSize * 0.4)
                        .padding()
                        .background(Color.red)
                        .clipShape(Circle())
                        .frame(width: buttonSize, height: buttonSize)
                }
            }
            .padding(.trailing, 16)
            .opacity(offsetX < -50 ? 1 : 0)
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            // Карточк
            
            EventCard(event: event) {
                // Если этот элемент уже открыт, закрываем его
                if openedEventID == event.id {
                    withAnimation {
                        resetOffset()
                        openedEventID = nil
                    }
                } else {
                    // Иначе открываем этот и закрываем остальные
                    withAnimation {
                        resetOffset()
                        offsetX = -150
                        openedEventID = event.id
                    }
                }
            } onDelete: {
                onDelete()
            }
            .offset(x: offsetX)
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        offsetX = value.translation.width
                        // Если есть другой открытый элемент и он не этот, закрываем его
                        if let openedID = openedEventID, openedID != event.id {
                            // Закрываем его
                            // Можно через глобальную функцию или через состояние
                            // Тут проще: при движении закрываем его
                            // Но так как это внутри одного элемента, делаем так:
                            // В основном, управлять этим лучше из ContentView
                        }
                    }
                    .onEnded { _ in
                        isDragging = false
                        if offsetX < -100 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                offsetX = -150
                                openedEventID = event.id
                            }
                        } else if offsetX > 50 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                resetOffset()
                                if openedEventID == event.id {
                                    openedEventID = nil
                                }
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                resetOffset()
                                if openedEventID == event.id {
                                    openedEventID = nil
                                }
                            }
                        }
                    }
            )
            .onChange(of: openedEventID) { newID in
                if newID != event.id && offsetX != 0 {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        resetOffset()
                    }
                }
            }
        }
        .clipped()
        .animation(.easeInOut, value: offsetX)
        
        
    }
    
    private func resetOffset() {
        withAnimation(.easeInOut(duration: 0.3)) {
            offsetX = 0
        }
    }
}
//#Preview {
//    ContentView()
//}
//.font(.custom("Bradley Hand", size: 16))

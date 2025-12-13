//
//  HistoryViewModel.swift
//  ChatGPTmacAR
//
//  Created by Macbook Pro on 19/05/2025.
//

import Foundation

class HistoryViewModel {
    
    let repository: MathRepository = MathRepository.shared
    @Published var chats: [CDMath] = []
    var sections: [ChatSection] = []
    @Published var currentChat: CDMath?
    @Published var filteredSections: [ChatSection] = []
    
    init() {
        fetchChats()
    }
    
    func chat(at indexPath: IndexPath) -> CDMath {
        filteredSections[indexPath.section].chats[indexPath.last!]
    }
    
    func section(at indexPath: IndexPath) -> ChatSection {
        filteredSections[indexPath.section]
    }
    
    func selectChat(at indexPath: IndexPath) {
        if let currentChat, currentChat.objectID.isTemporaryID {
            deleteChat(currentChat)
        }
        currentChat = chat(at: indexPath)
    }
    
    func messages(forChat chat: CDMath) -> [Message] {
        let messages = try? decodeJsonToMessages(from: chat.solution ?? "[]")
        return messages ?? []
    }
    
    func indexOfCurrentChat() -> IndexPath? {
        guard let currentChat else { return nil }
        guard let sectionIndex = filteredSections.firstIndex(where: { section in
                section.chats.contains(where: { chat in
                    chat.id == currentChat.id
                })
            }),
            let chatIndex = filteredSections[sectionIndex].chats.firstIndex(where: { chat in
                chat.id == currentChat.id
            }) else {
                return nil
            }
        
        return IndexPath(item: chatIndex, section: sectionIndex)
    }
    
    func filterChats(withName name: String) {
        let filteredChats = chats.filter {
            $0.problemText?.localizedCaseInsensitiveContains(name) ?? false
        }
        
        filteredSections = groupChatsByDate(filteredChats)
    }
    
    func resetFilteredSections() {
        filteredSections = sections
    }
    
    func saveChat(_ messages: [Message], chat: CDMath) {
        let chatJson = encodeMessagesToJSON(messages: messages)
        chat.solution = chatJson
        guard !isTemporaryChat(chat) else {
            chat.problemText = messages.first?.content ?? "New Chat"
            saveTemporaryChat(chat)
            return
        }
        
        if chats.first(where: { $0 == chat }) == nil { return }
        updateChat()
    }
    
    func updateChat() {
        do {
            try repository.updateChat()
            fetchChats()
        } catch {
            print("Error: Failed to update chat.")
        }
    }
    
    func fetchChats() {
        do {
            chats = try repository.fetchAllChats()
            sections = groupChatsByDate(chats)
            filteredSections = sections
        } catch {
            print("Error: Failed to fetch chats.")
        }
    }
    
    func createTemporaryChat(id: String, problemText: String?, problemImage: Data?, solution: String, date: Date) {
        do {
            let chat = try repository.createTemporaryChat(id: id, problemText: problemText ?? "", problemImage: problemImage ?? Data(), solution: solution, date: date)
            currentChat = chat
        } catch {
            print("Failed to create temporary chat.")
        }
    }
    
    func createNewChat(id: String, problemText: String?, problemImage: Data?, solution: String, date: Date) {
        do {
            let chat = try repository.createNewChat(id: id, problemText: problemText ?? "", problemImage: problemImage ?? Data(), solution: solution, date: date)
            fetchChats()
            currentChat = chat
        } catch {
            print("Failed to create new chat.")
        }
    }
    
    func deleteChat(_ chat: CDMath) {
        do {
            try repository.deleteChat(chat)
            fetchChats()
//            if chat == currentChat {
//                createTemporaryChat()
//            }
        } catch {
            print("Error: Failure deleting chat.")
        }
    }
    
    func deleteAllChats() {
        do {
            try repository.deleteAllChats()
            fetchChats()
            //createTemporaryChat()
        } catch {
            print("Eror: Failed to delete all chats.")
        }
    }
    
    func renameChat(name: String, chat: CDMath) {
        chat.problemText = name
        do {
            try repository.updateChat()
            fetchChats()
            if currentChat == nil {
                currentChat = chat
            }
        } catch {
            print("Failed to Rename chat.")
        }
    }
    
    func isTemporaryChat(_ chat: CDMath) -> Bool {
        return repository.isTemporary(chat)
    }
    
    func saveTemporaryChat(_ chat: CDMath) {
        do {
            try repository.saveTemporaryChat(chat)
            fetchChats()
            currentChat = chat
            
        } catch {
            print("Failed to save temporary chat.")
        }
    }
    
    func groupChatsByDate(_ chats: [CDMath]) -> [ChatSection] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        var groupedDict: [String: [CDMath]] = [:]
        
        for chat in chats {
            let chatDay = calendar.startOfDay(for: chat.date!)
            let header: String
            if chatDay == today {
                header = "Today".localized()
            } else if chatDay == yesterday {
                header = "Yesterday".localized()
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "d MMM"
                header = formatter.string(from: chatDay)
            }
            
            groupedDict[header, default: []].append(chat)
        }
        
        let sortedSections = groupedDict.sorted { lhs, rhs in
            let lhsDate = parseHeaderDate(lhs.key, calendar: calendar)
            let rhsDate = parseHeaderDate(rhs.key, calendar: calendar)
            return lhsDate > rhsDate
        }
        
        return sortedSections.map { ChatSection(header: $0.key, chats: $0.value) }
    }
    
    private func parseHeaderDate(_ header: String, calendar: Calendar) -> Date {
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        if header == "Today".localized() {
            return today
        } else if header == "Yesterday".localized() {
            return yesterday
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            return formatter.date(from: header) ?? Date.distantPast
        }
    }
}

private extension HistoryViewModel {
    func encodeMessagesToJSON(messages: [Message]) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let jsonData = try encoder.encode(messages)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString as String
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func decodeJsonToMessages(from jsonString: String) throws -> [Message] {
        let jsonData = Data(jsonString.utf8)
        let decoder = JSONDecoder()
        return try decoder.decode([Message].self, from: jsonData)
    }
}

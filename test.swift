//
//  test.swift
//  Quiz
//
//  Created by Robert Wiebe on 21.05.21.
//

import SwiftUI

class library: ObservableObject {
    @Published var pmusic: [String] = ["Early in the morning", "This one's for you", "Wellerman"]
    @Published var psingers: [String] = ["Pirate", "David Guetta", "Sea Shanty"]
}

struct test: View {
    @StateObject var observer = library()
    var body: some View {
        secondView(observer: observer)
    }
    
}

struct secondView: View {
    
    @ObservedObject var observer: library
    
    var body: some View {
        List {
            ForEach(0...observer.pmusic.count-1, id: \.self) { i in
                GroupBox {
                    TextField("Songname", text: $observer.pmusic[i])
                    Text(observer.psingers[i])
                }
            }.onDelete(perform: removeRows)
        }
    }
    func removeRows(at offsets: IndexSet) {
        observer.pmusic.remove(atOffsets: offsets)
        observer.psingers.remove(atOffsets: offsets)
    }
}

struct test_Previews: PreviewProvider {
    static var previews: some View {
        test()
    }
}

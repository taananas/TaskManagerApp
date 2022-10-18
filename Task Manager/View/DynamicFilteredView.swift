//
//  DynamicFilteredView.swift
//  Task Manager
//
//  Created by Богдан Зыков on 12.05.2022.
//

import SwiftUI
import CoreData


struct DynamicFilteredView<Content: View,T>: View where T: NSManagedObject{
    @FetchRequest var request: FetchedResults<T>
    let content: (T)->Content
    
    init(currentTab: String, @ViewBuilder content: @escaping (T) -> Content){
        
        let calendar = Calendar.current
        var predicate: NSPredicate
        
        if currentTab == "Today"{
            
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
            let filterKey = "deadline"
            predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i", argumentArray: [today, tomorrow, 0])
            
        }else if currentTab == "Upcoming"{
            
            let today = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
            let filterKey = "deadline"
            predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i", argumentArray: [today, tomorrow, 0])
            
        }else if currentTab == "Failed"{
            let today = calendar.startOfDay(for: Date())
            let past = Date.distantPast
            let filterKey = "deadline"
            predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i", argumentArray: [today, past, 0])
        }else{
            predicate = NSPredicate(format: "isCompleted == %i", [1])
        }
        _request = FetchRequest(entity: T.entity(), sortDescriptors: [.init(keyPath: \Task.deadline, ascending: false)], predicate: predicate)
        self.content = content

    }
    var body: some View{
        Group{
            if request.isEmpty{
                Text("Not tasks found!")
                    .font(.system(size: 16))
                    .fontWeight(.light)
                    .offset(y: 100)
            }
        }
    }
}

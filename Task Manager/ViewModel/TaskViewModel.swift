//
//  TaskViewModel.swift
//  Task Manager
//
//  Created by Богдан Зыков on 11.05.2022.
//

import SwiftUI
import CoreData


class TaskViewModel: ObservableObject{
    
    

    
    
    @Published var currentTab: Tabs = .today
    @Published var showDatePicker: Bool = false
    @Published var showEditTask: Bool = false
    @Published var task = MyTask(title: "",
                                 color: "Yelloy",
                                 deadline: Date(),
                                 type: "Basic")
    
    @Published var editTack: Task?
    let calendar = Calendar.current
   // let today = Date.now
    
    
    func addTask(context: NSManagedObjectContext) -> Bool{
        var task: Task!
        if let editTack = editTack {
            task = editTack
        }else{
            task = Task(context: context)
        }
        task.title = self.task.title
        task.color = self.task.color
        task.deadline = self.task.deadline
        task.type = self.task.type
        task.isCompleted = false
        if let _ = try? context.save(){
            return true
        }
        return false
    }
    
    func resetTaskData(){
        editTack = nil
        task.type = AppConstant.types.first!
        task.color = AppConstant.colors.first!
        task.deadline = Date()
        task.title = ""
    }
    func setupTask(){
        if let editTack = editTack {
            task.title = editTack.title ?? ""
            task.color = editTack.color ?? AppConstant.colors.first!
            task.deadline = editTack.deadline ?? Date()
            task.type = editTack.type ?? AppConstant.types.first!
        }
    }
    
    func filterTasks(_ task: FetchedResults<Task>.Element) -> Bool{
        switch currentTab{
        case .failed:
            return failed(task)
        case .today:
           return today(task)
        case .done:
            return task.isCompleted
        case .upcoming:
            return upcoming(task)
        }
   

    }
    private func failed(_ task: FetchedResults<Task>.Element) -> Bool{
        guard let deadline = task.deadline else {return false}
        let today = calendar.startOfDay(for: Date())
        return deadline < today  && !task.isCompleted
    }
    
    private func upcoming(_ task: FetchedResults<Task>.Element) -> Bool {
        guard let deadline = task.deadline else {return false}
        let today = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
        let tomorrow = calendar.date(byAdding: .day, value: 60, to: today)!
        return deadline >= today && deadline < tomorrow && !task.isCompleted
    }
    
    private func today(_ task: FetchedResults<Task>.Element) -> Bool{
        guard let deadline = task.deadline else {return false}
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        return deadline >= today && deadline < tomorrow && !task.isCompleted
    }
}

//
//  HomeView.swift
//  Task Manager
//
//  Created by Богдан Зыков on 11.05.2022.
//

import SwiftUI

struct HomeView: View {
    @StateObject var taskVM = TaskViewModel()
    @Namespace var animation
    @FetchRequest(entity: Task.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Task.deadline, ascending: false)], predicate: nil, animation: .easeInOut) var tasks: FetchedResults<Task>
    
    @Environment(\.self) var env
    
    
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack{
                headerSectionView
                customSegmentedBar
                tasksSectionView
            }
            .padding()
        }
        .overlay(alignment: .bottom) {
            addTackButton
        }
        .fullScreenCover(isPresented: $taskVM.showEditTask, onDismiss: taskVM.resetTaskData, content: {
            AddNewTaskView()
                .environmentObject(taskVM)
        })
        
         .background{
             Color("bg")
                 .ignoresSafeArea()
         }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}

extension HomeView{
    
    private var headerSectionView: some View{
        VStack(alignment: .leading, spacing: 10) {
            Text("Welcome Back!")
                .font(.callout)
            Text("Here's Update Today.")
                .font(.title2.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical)
    }
    
    private var customSegmentedBar: some View{
        
        HStack(spacing: 10) {
            ForEach(Tabs.allCases, id: \.self) { tab in
                Text(tab.rawValue)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .scaleEffect(0.9)
                    .foregroundColor(taskVM.currentTab == tab ? Color("textColor") : Color("bgElement").opacity(0.6))
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .background{
                        if taskVM.currentTab == tab{
                            Capsule()
                                .fill(Color("bgElement"))
                                .matchedGeometryEffect(id: "Tab", in: animation)
                        }
                    }
                    .clipShape(Capsule())
                    .onTapGesture {
                        withAnimation {taskVM.currentTab = tab}
                    }
            }
        }
        .padding(.top, 5)
    }
    private var addTackButton: some View{
        Button {
            taskVM.showEditTask.toggle()
        } label: {
            Label {
                Text("Add Task")
                    .font(.callout)
                    .fontWeight(.semibold)
                    
            } icon: {
                Image(systemName: "plus.app.fill")
            }
            .foregroundColor(Color("textColor"))
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .background(Color("bgElement"), in: Capsule())
            .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity)
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
    }
    private var tasksSectionView: some View{
        LazyVStack(spacing: 20) {
            ForEach(tasks.filter({taskVM.filterTasks($0)}), id: \.id) { task in
                taskRow(task)
            }
        }
        .padding(.top, 20)
    }
    private func taskRow(_ task: Task) -> some View{
        VStack(alignment: .leading, spacing: 10) {
            HStack{
                Text(task.type ?? "")
                    .font(.callout)
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    .background{
                        Capsule()
                            .fill(Material.ultraThinMaterial)
                    }
                Spacer()
                if !task.isCompleted && taskVM.currentTab != .failed{
                    Button {
                        taskVM.editTack = task
                        taskVM.showEditTask = true
                        taskVM.setupTask()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.black)
                    }
                }
            }
            Text(task.title ?? "")
                .font(.title2.bold())
                .foregroundColor(.black)
                .padding(.vertical, 10)
            HStack(alignment: .bottom, spacing: 0){
                VStack(alignment: .leading, spacing: 10) {
                    Label {
                        Text((task.deadline ?? Date()).formatted(date: .long, time: .omitted))
                            .foregroundColor(.black)
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundColor(.black)
                    }
                    
                    Label {
                        Text((task.deadline ?? Date()).formatted(date: .omitted, time: .shortened))
                            .foregroundColor(.black)
                    } icon: {
                        Image(systemName: "clock")
                            .foregroundColor(.black)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if !task.isCompleted && taskVM.currentTab != .failed{
                    Button {
                        task.isCompleted.toggle()
                        try? env.managedObjectContext.save()
                    } label: {
                        Circle()
                            .strokeBorder(.black, lineWidth: 1.5)
                            .frame(width: 25, height: 25)
                            .contentShape(Circle())
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background{
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(task.color ?? AppConstant.colors.first!))
        }
    }
}

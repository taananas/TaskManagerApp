//
//  AddNewTaskView.swift
//  Task Manager
//
//  Created by Богдан Зыков on 11.05.2022.
//

import SwiftUI

struct AddNewTaskView: View {
    @EnvironmentObject var taskVM: TaskViewModel
    @Environment (\.self) var env
    @Namespace var animation
    var body: some View {
        VStack(spacing: 12){
            Text(taskVM.editTack !== nil ? "Edit Task" : "Add Task")
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    backButton
                }
                .overlay(alignment: .trailing){
                    removeButton
                }
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("Task Color")
                colorsPickerSection
                Divider().padding(.vertical, 10)
                taskDeadlineSectionView
                Divider()
                    .padding(.vertical, 10)
                taskTitleSectionView
                Divider()
                taskTypeSection
                Divider()
                saveButton
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 30)
          
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
        .overlay {
            datePickerModalView
        }
        .background(Color("bg"))
    }
}

struct AddNewTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewTaskView()
            .environmentObject(TaskViewModel())
            .preferredColorScheme(.dark)
    }
}

extension AddNewTaskView{
    
    private var removeButton: some View{
        Button {
            if let editTask = taskVM.editTack{
                env.managedObjectContext.delete(editTask)
                try? env.managedObjectContext.save()
                env.dismiss()
            }
            
        } label: {
            Image(systemName: "trash")
                .font(.title3)
                .foregroundColor(.red)
        }
        .opacity(taskVM.editTack == nil ? 0 : 1) 
    }
    private var backButton: some View{
        Button {
            env.dismiss()
        } label: {
            Image(systemName: "arrow.left")
                .font(.title3)
                .foregroundColor(Color("bgElement"))
            
        }
    }
    private var colorsPickerSection: some View{
        
        HStack(spacing: 16) {
            ForEach(AppConstant.colors, id: \.self) { color in
                Circle()
                    .fill(Color(color))
                    .frame(width: 25, height: 25)
                    .background{
                        if taskVM.task.color == color{
                            Circle()
                                .strokeBorder(.gray)
                                .padding(-3)
                        }
                    }
                    .contentShape(Circle())
                    .onTapGesture {
                        taskVM.task.color = color
                    }
            }
            
        }
        .padding(.top, 10)
    }
    private func sectionTitle(_ title: String) -> some View{
        Text(title)
            .font(.caption)
            .foregroundColor(.gray)
    }
    private var taskDeadlineSectionView: some View{
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Task Deadline")
            Text(taskVM.task.deadline.formatted(date: .abbreviated, time: .omitted) + ", " + taskVM.task.deadline.formatted(date: .omitted, time: .shortened))
                .font(.callout)
                .fontWeight(.semibold)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottomTrailing) {
            Button {
                taskVM.showDatePicker = true
            } label: {
                Image(systemName: "calendar")
                    .foregroundColor(Color("bgElement"))
            }
        }
    }
    private var taskTitleSectionView: some View{
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Task Title")
            TextField("", text: $taskVM.task.title)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
        }
        .padding(.top, 10)
    }
    private var taskTypeSection: some View{
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Task Type")
            HStack(spacing: 12) {
                ForEach(AppConstant.types, id: \.self) { type in
                    Text(type)
                        .font(.callout)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(taskVM.task.type == type ? Color("textColor") : Color("bgElement"))
                        .background{
                            if taskVM.task.type == type{
                                Capsule()
                                    .fill(Color("bgElement"))
                                    .matchedGeometryEffect(id: "TYPE", in: animation)
                            }else{
                                Capsule()
                                    .strokeBorder(Color("bgElement"))
                            }
                        }
                        .contentShape(Capsule())
                        .onTapGesture {
                            withAnimation {
                                taskVM.task.type = type
                            }
                        }
                }
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 10)
    }
    private var saveButton: some View{
        Button {
            if taskVM.addTask(context: env.managedObjectContext){
                env.dismiss()
            }
        } label: {
            Text("Save Task")
                .font(.callout)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundColor(Color("textColor"))
                .background{
                    Capsule()
                        .fill(Color("bgElement"))
                }
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .disabled(taskVM.task.title == "")
        .opacity(taskVM.task.title == "" ? 0.6 : 1)
        .padding(.bottom, 25)
    }
    
    private var datePickerModalView: some View{
        ZStack{
            if taskVM.showDatePicker{
               Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .onTapGesture {
                        taskVM.showDatePicker = false
                    }
                DatePicker.init("", selection: $taskVM.task.deadline, in: Date.now...Date.distantFuture)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .padding()
                    .background(.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding()
            }
        }
        .animation(.easeIn, value: taskVM.showDatePicker)
    }
}

//
//  AppConstant.swift
//  Task Manager
//
//  Created by Богдан Зыков on 12.05.2022.
//

import Foundation

class AppConstant{
    
    static let colors: [String] = ["Yelloy", "Green", "Blue", "Purple", "Red", "Orange"]
    static let types: [String] = ["Basic", "Urgent", "Important"]
}

enum Tabs: String, CaseIterable{
    case today = "Today"
    case upcoming = "Upcoming"
    case done = "Task Done"
    case failed = "Failed"
}

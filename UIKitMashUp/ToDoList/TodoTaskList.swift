
import Foundation
import UIKit

struct TodoTaskItem {
    var description: String
    var deadline: NSDate
    var UUID: String
    
    init(deadline: NSDate, description: String, UUID: String) {
        self.description = description
        self.deadline = deadline
        self.UUID = UUID
    }
    
    var isOverdue: Bool {
        return (NSDate().compare(self.deadline) == NSComparisonResult.OrderedDescending)
    }
}

class TodoTaskList {
    private let DefaultsKey = "ToDoListTableViewController.TodoTaskList"
    
    // There will be only one todo list, so a singleton will be used.
    class var sharedInstance : TodoTaskList {
        struct Singleton {
            static let instance : TodoTaskList = TodoTaskList()
        }
        
        return Singleton.instance
    }
    
    // Retruns list of tasks in chronological order
    func getTaskItemsList() -> [TodoTaskItem] {
        let taskListDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(DefaultsKey) ?? [:]
        let taskListArray = Array(taskListDictionary.values)
        
        func createTaskObject(taskData2: AnyObject) -> TodoTaskItem {
            let taskData = taskData2 as! [String:AnyObject]
            let deadline = taskData["deadline"] as! NSDate
            let description = taskData["description"] as! String
            let UUID = taskData["UUID"] as! String
            
            return TodoTaskItem(deadline: deadline, description: description, UUID: UUID)
        }
        
        // Sort the task chronologically
        var todoTaskList = taskListArray.map(createTaskObject).sorted {$0.deadline.compare($1.deadline) == .OrderedAscending}
        return todoTaskList
    }
    
    // Set the badge number as the number of overdue tasks
    func setBadgeNumbers() {
        let toDoTasks = TodoTaskList.sharedInstance.getTaskItemsList()
        let overdueTasks = toDoTasks.filter {$0.deadline.compare(NSDate()) != .OrderedDescending}
        UIApplication.sharedApplication().applicationIconBadgeNumber = overdueTasks.count
    }
    
    func addTask(task: TodoTaskItem) {
        // Get list of tasks and add the new task to the list. Task list is saved in dictionary form.
        var taskListDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(DefaultsKey) ?? [:]
        taskListDictionary[task.UUID] = ["deadline": task.deadline, "description": task.description, "UUID": task.UUID]
        NSUserDefaults.standardUserDefaults().setObject(taskListDictionary, forKey: DefaultsKey)
        
        // Create notification for the new task
        let notification = UILocalNotification()
        notification.alertBody = "Todo task \"\(task.description)\" is overdue"
        notification.alertAction = "open"
        notification.fireDate = task.deadline
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["description": task.description, "UUID": task.UUID] // Unique identifier to the notification for later retrieval
        notification.category = GlobalConstants.ToDoList.NotificationCategory
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        setBadgeNumbers()
    }
    
    func removeTask(task: TodoTaskItem) {
        // Find the notification of the item selected and cancel it.
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification] {
            if (notification.userInfo!["UUID"] as! String == task.UUID) {
                UIApplication.sharedApplication().cancelLocalNotification(notification)
                break
            }
        }
        
        // Delete the task from NSUserDefaults
        if var newTodoItems = NSUserDefaults.standardUserDefaults().dictionaryForKey(DefaultsKey) {
            newTodoItems.removeValueForKey(task.UUID)
            NSUserDefaults.standardUserDefaults().setObject(newTodoItems, forKey: DefaultsKey)
        }
        
        setBadgeNumbers()
    }
    
    func scheduleReminderForTask(task: TodoTaskItem) {
        var notification = UILocalNotification()
        notification.alertBody = "Reminder: Todo Item \"\(task.description)\" is overdue"
        notification.alertAction = "open"
        notification.fireDate = NSDate().dateByAddingTimeInterval(30 * 60)
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["description": task.description, "UUID": task.UUID]
        notification.category = GlobalConstants.ToDoList.NotificationCategory
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}
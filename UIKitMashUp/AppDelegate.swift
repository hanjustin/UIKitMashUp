
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        TodoTaskList.sharedInstance.setBadgeNumbers()
    }

    func applicationDidEnterBackground(application: UIApplication) {

    }

    func applicationWillEnterForeground(application: UIApplication) {

    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        // To refresh ToDoListTable when a task becomes overdue.
        if notification.category == GlobalConstants.ToDoList.NotificationCategory {
            NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.ToDoList.RefreshNotificationName, object: self)
            TodoTaskList.sharedInstance.setBadgeNumbers()
        }
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // To refresh ToDoListTable when the app is resumed.
        NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.ToDoList.RefreshNotificationName, object: self)
    }

    func applicationWillTerminate(application: UIApplication) {

    }

    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        // Complete or remind a todo task item
        if notification.category == GlobalConstants.ToDoList.NotificationCategory {
            let deadline = notification.fireDate!
            let description = notification.userInfo!["description"] as! String
            let UUID = notification.userInfo!["UUID"] as! String!
            let notifiedTaskItem = TodoTaskItem(deadline: deadline, description: description, UUID: UUID)
            
            switch identifier! {
            case GlobalConstants.ToDoList.NotificationCompleteActionID:
                TodoTaskList.sharedInstance.removeTask(notifiedTaskItem)
            case GlobalConstants.ToDoList.NotificationRemindActionID:
                TodoTaskList.sharedInstance.scheduleReminderForTask(notifiedTaskItem)
            default:
                println("Notification identifier expected")
            }
        }

        completionHandler()
    }

}


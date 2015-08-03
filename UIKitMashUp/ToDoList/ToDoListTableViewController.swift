
import UIKit

class ToDoListTableViewController: UITableViewController {
    
    private var todoTaskItems: [TodoTaskItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationConfiguration()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshList", name: GlobalConstants.ToDoList.RefreshNotificationName, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshList()
    }
    
    func refreshList() {
        todoTaskItems = TodoTaskList.sharedInstance.getTaskItemsList()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoTaskItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        let todoItem = todoTaskItems[indexPath.row] as TodoTaskItem
        
        cell.textLabel?.text = todoItem.description as String!
        if (todoItem.isOverdue) {
            cell.detailTextLabel?.textColor = UIColor.redColor()
        } else {
            cell.detailTextLabel?.textColor = UIColor.blackColor()
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "'Due' MMM dd 'at' h:mm a" // example: "Due Jan 01 at 12:00 PM"
        cell.detailTextLabel?.text = dateFormatter.stringFromDate(todoItem.deadline)
        
        return cell
    }
    
    // MARK: - Table view editing
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return "Complete"
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let selectedTask = todoTaskItems.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            TodoTaskList.sharedInstance.removeTask(selectedTask)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("OpenTaskEditor", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // The user is editing a task if the sender is NSIndexPath
        if let indexPath = sender as? NSIndexPath where segue.identifier == "OpenTaskEditor" {
            let editorPageVC = segue.destinationViewController as! ToDoTaskEditorViewController
            let selectedTask = todoTaskItems[indexPath.row]
            editorPageVC.taskToEdit = selectedTask
        }
    }
    
    private func notificationConfiguration() {
        let completeAction = UIMutableUserNotificationAction()
        completeAction.identifier = GlobalConstants.ToDoList.NotificationCompleteActionID
        completeAction.title = "Complete"
        completeAction.activationMode = .Background
        completeAction.authenticationRequired = false
        completeAction.destructive = true
        
        let remindAction = UIMutableUserNotificationAction()
        remindAction.identifier = GlobalConstants.ToDoList.NotificationRemindActionID
        remindAction.title = "Remind in 30 minutes"
        remindAction.activationMode = .Background
        remindAction.destructive = false
        
        let todoCategory = UIMutableUserNotificationCategory()
        todoCategory.identifier = GlobalConstants.ToDoList.NotificationCategory
        todoCategory.setActions([remindAction, completeAction], forContext: .Default)
        todoCategory.setActions([completeAction, remindAction], forContext: .Minimal)
        
        // Ask permission to show notification
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: [todoCategory]))
    }
}

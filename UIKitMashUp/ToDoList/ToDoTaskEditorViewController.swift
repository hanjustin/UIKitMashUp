
import UIKit

class ToDoTaskEditorViewController: UIViewController {
    
    @IBOutlet weak var taskInputField: UITextField!
    @IBOutlet weak var deadlinePicker: UIDatePicker!
    @IBOutlet weak var submitButton: UIButton!
    
    var taskToEdit: TodoTaskItem?
    
    @IBAction func submitTask(sender: UIButton) {
        let newTaskItem = TodoTaskItem(deadline: deadlinePicker.date, description: taskInputField.text, UUID: NSUUID().UUIDString)
        
        // If the user is updating a task, remove the old task
        if let oldTaskItem = taskToEdit {
            TodoTaskList.sharedInstance.removeTask(oldTaskItem)
        }
        
        TodoTaskList.sharedInstance.addTask(newTaskItem)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTabRecognizerToDismissKeyboard()
        
        // If the user is editing a task instead of adding, update UI
        if let taskData = taskToEdit {
            submitButton.setTitle("Edit task", forState: .Normal)
            taskInputField.text = taskData.description
            deadlinePicker.date = taskData.deadline
        }
    }
    
    // Mark: - Text field keyboard management
    
    func addTabRecognizerToDismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}


import UIKit

class UIKitPickerTableViewController: UITableViewController {
    
    private struct StoryBoardIDs {
        static let ToDoListVCID = "ToDoListNavigationController"
        static let PhotoAlbumVCID = "PhotoAlbumNavigationController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            // Show master view on the side
            self.splitViewController?.preferredDisplayMode = .AllVisible
        } else {
            // Show master view on load
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.row
        
        if index == 0 {
            let toDoListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryBoardIDs.ToDoListVCID) as! UINavigationController
            splitViewController?.showDetailViewController(toDoListVC, sender: nil)
        } else if index == 1 {
            let photoAlbumVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryBoardIDs.PhotoAlbumVCID) as! UINavigationController
            splitViewController?.showDetailViewController(photoAlbumVC, sender: nil)
        }
        
        let animations: () -> Void = {
            self.splitViewController?.preferredDisplayMode = .PrimaryHidden
        }
        
        // Hide the master view when clicked.
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            UIView.animateWithDuration(0.4, animations: animations, completion: nil)
        }
    }
}
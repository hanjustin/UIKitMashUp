
import UIKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var photoAlbum = PhotoAlbum()
    private var filteredPhotos = [Photo]()
    private var filterSearch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setNavigationBarButtons
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addNewPhoto")
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search photo summary"
        navigationItem.titleView = searchBar
        
        // addTabRecognizerToDismissKeyboard
        let tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        navigationController?.hidesBarsOnTap = false
        navigationController?.toolbarHidden = true
    }
    
    func dismissKeyboard(){
        navigationItem.titleView?.resignFirstResponder()
    }
    
    // MARK: - Collection view data source
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return !filterSearch ? photoAlbum.numberOfPhotos : filteredPhotos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PhotoViewCell
        let photo = !filterSearch ? photoAlbum.getPhotoAtIndex(indexPath.item) : filteredPhotos[indexPath.item]
        
        let path = getDocumentsDirectory().stringByAppendingPathComponent(photo.imageUUID)
        cell.imageView.image = UIImage(contentsOfFile: path)
        
        cell.photoSummary.text = photo.summary
        
        cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).CGColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    // MARK: - Segue to photo editor
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Set up the detail view that shows a larger image
        let photo = !filterSearch ? photoAlbum.getPhotoAtIndex(indexPath.item) : filteredPhotos[indexPath.item]
        let imagePath = getDocumentsDirectory().stringByAppendingPathComponent(photo.imageUUID)
        let imageView = UIImageView(image: UIImage(contentsOfFile: imagePath))
        let photoDetailVC = UIViewController()
        photoDetailVC.view.backgroundColor = UIColor.blackColor()
        
        let edit = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editPhotoSummary:")
        let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let delete = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "deletePhoto:")
        edit.tag = indexPath.row
        delete.tag = indexPath.row
        photoDetailVC.toolbarItems = [edit, spacer, delete]
        
        imageView.frame = photoDetailVC.view.bounds
        imageView.contentMode = .ScaleAspectFit
        photoDetailVC.view.addSubview(imageView)
        
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let viewsDictionary = ["imageView":imageView]
        let width_constraint:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|-1-[imageView]-1-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        let height_constraint:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[imageView]-|", options: NSLayoutFormatOptions.AlignAllLeading, metrics: nil, views: viewsDictionary)
        photoDetailVC.view.addConstraints(width_constraint)
        photoDetailVC.view.addConstraints(height_constraint)
        
        navigationController?.pushViewController(photoDetailVC, animated: true)
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.toolbarHidden = false
        navigationController?.setToolbarHidden(true, animated: false)
        navigationController?.hidesBarsOnTap = true
    }
    
    // Mark: - Photo management
    
    func addNewPhoto() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func showPhotoSummaryEditor(photo: Photo) {
        let actionSheetController: UIAlertController = UIAlertController(title: "Alert", message: "Please add a summary to the image.", preferredStyle: .Alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let updateAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) {
            _ -> () in
            let newSummary = (actionSheetController.textFields?.first as! UITextField).text
            self.photoAlbum.updatePhotoSummary(photo, newSummary: newSummary)
            self.collectionView.reloadData()
        }
        
        actionSheetController.addTextFieldWithConfigurationHandler(nil)
        actionSheetController.addAction(cancelAction)
        actionSheetController.addAction(updateAction)
        parentViewController?.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    func editPhotoSummary(sender: UIBarButtonItem) {
        let photoIndex = sender.tag
        let photo = !filterSearch ? photoAlbum.getPhotoAtIndex(photoIndex) : filteredPhotos[photoIndex]
        showPhotoSummaryEditor(photo)
    }
    
    func deletePhoto(sender: UIBarButtonItem) {
        let photoIndex = sender.tag
        let photo = !filterSearch ? photoAlbum.getPhotoAtIndex(photoIndex) : filteredPhotos[photoIndex]
        
        let actionSheetController: UIAlertController = UIAlertController(title: "Alert", message: "Do you want to delete this photo?", preferredStyle: .Alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let updateAction: UIAlertAction = UIAlertAction(title: "YES", style: .Default) {
            _ -> () in
            self.photoAlbum.deletePhoto(photo)
            if self.filterSearch {
                self.filteredPhotos.removeAtIndex(photoIndex)
            }
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        actionSheetController.addAction(cancelAction)
        actionSheetController.addAction(updateAction)
        parentViewController?.presentViewController(actionSheetController, animated: true, completion: nil)
    }
}

// Mark: - UITextFieldDelegate - To be implemented

extension PhotoAlbumViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// Mark: - UIImagePickerControllerDelegate

extension PhotoAlbumViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var newImage: UIImage
        
        // Get edited or original image
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        let newPhoto = photoAlbum.createPhotoWithImage(newImage)
        dismissViewControllerAnimated(true, completion: {self.showPhotoSummaryEditor(newPhoto)})
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// Mark: - Search related

extension PhotoAlbumViewController: UISearchBarDelegate, UISearchDisplayDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        dismissKeyboard()
    }
    
    func filterPhotosWithSummary(searchText: String) {
        filteredPhotos = photoAlbum.photos.filter { $0.summary.lowercaseString.rangeOfString(searchText.lowercaseString) != nil }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if count(searchText) > 0 {
            filterSearch = true
            filterPhotosWithSummary(searchText)
            collectionView.reloadData()
        } else {
            filterSearch = false
            collectionView.reloadData()
        }
    }
}
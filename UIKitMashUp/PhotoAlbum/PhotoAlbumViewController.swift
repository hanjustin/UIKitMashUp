
import UIKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var collectionView: UICollectionView!

    private var photoAlbum = PhotoAlbum()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addNewPhoto")
    }

    // MARK: - Collection view data source

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoAlbum.numberOfPhotos
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PhotoViewCell
        let photo = photoAlbum.getPhotoAtIndex(indexPath.item)

        let path = getDocumentsDirectory().stringByAppendingPathComponent(photo.imageUUID)
        cell.imageView.image = UIImage(contentsOfFile: path)

        cell.photoSummary.text = photo.summary

        cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).CGColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7

        return cell
    }

    // Mark: - ImagePickerController

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
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
}


import Foundation
import UIKit

func getDocumentsDirectory() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as! [String]
    let documentsDirectory = paths[0]
    return documentsDirectory
}

class PhotoAlbum {
    
    private let DefaultsKey = "PhotoAlbum.photos"
    private(set) var photos = [Photo]()
    
    init() {
        // Get saved photos if they exist
        if let savedPhotos = NSUserDefaults.standardUserDefaults().objectForKey(DefaultsKey) as? NSData {
            photos = NSKeyedUnarchiver.unarchiveObjectWithData(savedPhotos) as! [Photo]
        }
    }
    
    var numberOfPhotos: Int {
        return photos.count
    }
    
    func getPhotoAtIndex(index: Int) -> Photo {
        return photos[index]
    }
    
    func createPhotoWithImage(newImage: UIImage) -> Photo {
        // Save the image in documents directory with a unique name
        let imageUUID = NSUUID().UUIDString
        let imagePath = getDocumentsDirectory().stringByAppendingPathComponent(imageUUID)
        let jpegData = UIImageJPEGRepresentation(newImage, 100)
        jpegData.writeToFile(imagePath, atomically: true)
        
        var photo = Photo(summary: "", imageUUID: imageUUID)
        photos.append(photo)
        
        saveCurrentPhotos()
        
        return photos.last!
    }
    
    func updatePhotoSummary(photo: Photo, newSummary: String) {
        photo.summary = newSummary
        saveCurrentPhotos()
    }
    
    func deletePhoto(photo: Photo) {
        // This if statement might not work for Swift 2.0 as the global find function is getting replaced
        // Replace to photos.indexOf(photo) in Swift 2.0
        if let index = find(photos, photo) {
            let imagePath = getDocumentsDirectory().stringByAppendingPathComponent(photo.imageUUID)
            
            photos.removeAtIndex(index)
            NSFileManager.defaultManager().removeItemAtPath(imagePath, error: nil)
            
            saveCurrentPhotos()
        }
    }
    
    func saveCurrentPhotos() {
        let savedData = NSKeyedArchiver.archivedDataWithRootObject(photos)
        NSUserDefaults.standardUserDefaults().setObject(savedData, forKey: DefaultsKey)
    }
}
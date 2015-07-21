
import Foundation
import UIKit

func getDocumentsDirectory() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as! [String]
    let documentsDirectory = paths[0]
    return documentsDirectory
}

class PhotoAlbum {
    
    private let DefaultsKey = "PhotoAlbum.photos"
    private var photos = [Photo]()
    
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
        
        savePhotos()
        
        return photos.last!
    }
    
    func updatePhotoSummary(photo: Photo, newSummary: String) {
        photo.summary = newSummary
        savePhotos()
    }
    
    func savePhotos() {
        let savedData = NSKeyedArchiver.archivedDataWithRootObject(photos)
        NSUserDefaults.standardUserDefaults().setObject(savedData, forKey: DefaultsKey)
    }
    
    // To be implemented
    func deletePhoto() {
        
    }
    
}
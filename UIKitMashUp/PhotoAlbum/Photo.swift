
import Foundation

class Photo: NSObject, NSCoding {
    var summary: String
    var imageUUID: String
    
    init(summary: String, imageUUID: String) {
        self.summary = summary
        self.imageUUID = imageUUID
    }
    
    // Mark: - NSCoding functions
    
    required init(coder aDecoder: NSCoder) {
        summary = aDecoder.decodeObjectForKey("summary") as! String
        imageUUID = aDecoder.decodeObjectForKey("imageUUID") as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.summary, forKey: "summary")
        aCoder.encodeObject(self.imageUUID, forKey: "imageUUID")
    }
}
import Foundation

class Episode
{
    var video: String?
    var url: String?
    var description: String?
}

class Show
{
    var show: String?
    var image: String?
    var description: String?
    var episodes = [Episode]()
}

class Genre
{
    var list: String?
    var image: String? //URL
    var shows = [Show]()
    
    static var mainURL = ""
    static var finished = false
    static var updatedThisRun = false
    static var genres: [Genre]?
    
}

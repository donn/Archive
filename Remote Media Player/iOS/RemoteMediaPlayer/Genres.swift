import UIKit
import Alamofire
import AlamofireImage

class Genres: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if (!Genre.updatedThisRun)
        {
            update()
        }
    }
    
    @IBAction func onClick_Overflow(sender: AnyObject)
    {
        let actionSheet = UIAlertController(title: "", message: "Options", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Update", style: .Default, handler: { (UIAlertAction) in
            self.update()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "About", style: .Default, handler: { (UIAlertAction) in
            self.performSegueWithIdentifier("genresgotoabout", sender: self)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (UIAlertAction) in
            //Nothing here
        }))
        
        actionSheet.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        
        self.presentViewController(actionSheet, animated: true) { 
            //Nothing here either. Thanks, Obama
        }
    }
    
    internal func update()
    {
        
        Genre.finished = false
        
        NSNotificationCenter.defaultCenter().postNotificationName("skyus.potato.remotemediaplayer:CLEAR EPISODES", object: nil)
        
        Alamofire.request(.GET, Genre.mainURL, parameters: [:])
            .responseData
            {
                response in
                Genre.genres = [Genre]()
                
                let json = JSON(data: response.data!)
                
                for (_, genreJson):(String, JSON) in json
                {
                    let genre = Genre()
                    genre.list = genreJson["category"].string
                    genre.image = genreJson["image"].string!
                    
                    let showsJson = genreJson["shows"]
                    for (_, showJson):(String, JSON) in showsJson
                    {
                        let show = Show()
                        show.show = showJson["title"].string
                        show.image = showJson["image"].string
                        show.description = showJson["description"].string
                        
                        let episodesJson = showJson["episodes"]
                        for (_, episodeJson):(String, JSON) in episodesJson
                        {
                            let episode = Episode()
                            episode.video = episodeJson["video"].string
                            episode.url = episodeJson["url"].string
                            episode.description = episodeJson["description"].string
                            
                            show.episodes.append(episode)
                        }
                        
                        genre.shows.append(show)
                    }
                    
                    Genre.genres!.append(genre)
                }
                
                Genre.finished = true
                NSLog("Serialization done.")
                
                self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if (Genre.finished)
        {
            Shows.currentGenre = indexPath.row
            Episodes.currentShow = nil
            NSNotificationCenter.defaultCenter().postNotificationName("skyus.potato.remotemediaplayer:UPDATE SHOWS", object: nil)
            NSNotificationCenter.defaultCenter().postNotificationName("skyus.potato.remotemediaplayer:CLEAR EPISODES", object: nil)
            
            if (UIDevice.currentDevice().userInterfaceIdiom != .Pad)
            {
                performSegueWithIdentifier("genresgotoshows", sender: self)
            }
        }
        else
        {
            let dialog = UIAlertController(title: "", message: "Options", preferredStyle: .Alert)
            
            dialog.message = "Please wait for the update to finish."
            dialog.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (UIAlertAction) in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            self.presentViewController(dialog, animated: true, completion: nil)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let count = Genre.genres?.count
        {
            return count
        }
        return 0;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("ListCell") as! ListCell
        let row = indexPath.row
        
        if let title = Genre.genres?[row].list
        {
            cell.itemLabel.text = title
        }
        else
        {
            cell.itemLabel.text = "Untitled Genre"
        }
        
        if let url = Genre.genres![row].image
        {
            Alamofire.request(.GET, url)
                .responseImage { response in
                    debugPrint(response)
                    
                    print(response.request)
                    print(response.response)
                    debugPrint(response.result)
                    
                    if let image = response.result.value {
                        cell.itemImage.image = image
                    }
            }
        }
        
        return cell        
        
    }

}


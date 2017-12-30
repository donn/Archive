import UIKit
import Alamofire
import AlamofireImage

class Shows: UITableViewController
{
    static var currentGenre: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        navigationItem.leftItemsSupplementBackButton = true
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(reload),
            name: "skyus.potato.remotemediaplayer:UPDATE SHOWS",
            object: nil
        )
        
        reload()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func reload()
    {
        self.tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        Episodes.currentShow = indexPath.row
        NSNotificationCenter.defaultCenter().postNotificationName("skyus.potato.remotemediaplayer:UPDATE EPISODES", object: nil)
        if (UIDevice.currentDevice().userInterfaceIdiom != .Pad)
        {
            performSegueWithIdentifier("showsgotoepisodes", sender: self)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let genre = Shows.currentGenre
        {
            if let count = Genre.genres?[genre].shows.count
            {
                return count
            }
        }
        
        return 0;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("ListCell") as! ListCell
        let row = indexPath.row
        
        if let title = Genre.genres?[Shows.currentGenre!].shows[row].show
        {
            cell.itemLabel.text = title
        }
        else
        {
            cell.itemLabel.text = "Untitled Show"
        }
        
        if let url = Genre.genres?[Shows.currentGenre!].shows[row].image
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


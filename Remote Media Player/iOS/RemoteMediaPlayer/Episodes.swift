import UIKit
import AVKit
import AVFoundation
import Alamofire
import AlamofireImage

class Episodes: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showDescription: UITextView!
    @IBOutlet weak var TableView: UITableView!
    private var rowForSegue: Int?
    
    static var currentShow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        navigationItem.leftItemsSupplementBackButton = true
        
        TableView.delegate = self
        TableView.dataSource = self
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(reload),
            name: "skyus.potato.remotemediaplayer:UPDATE EPISODES",
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(clear),
            name: "skyus.potato.remotemediaplayer:CLEAR EPISODES",
            object: nil
        )
        reload()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func clear()
    {
        self.navigationItem.title = "Episodes"
        self.showImage.image = UIImage()
        self.showDescription.text = ""
        self.TableView.reloadData()
    }
    
    @objc func reload()
    {
       
        guard let genre = Shows.currentGenre
        else
        {
            clear();
            return;
        }
        guard let show = Episodes.currentShow
        else
        {
            clear();
            return;
        }
        
        if let title = Genre.genres?[genre].shows[show].show
        {
            self.navigationItem.title = title
            
        }
        else
        {
            self.navigationItem.title = "Episodes"
        }
        
        if let url = Genre.genres?[genre].shows[show].image
        {
            Alamofire.request(.GET, url)
                .responseImage { response in
                    debugPrint(response)
                    
                    print(response.request)
                    print(response.response)
                    debugPrint(response.result)
                    
                    if let image = response.result.value {
                        self.showImage.image = image
                    }
            }
        }
        else
        {
            self.showImage.image = UIImage()
        }
        
        if let description = Genre.genres?[Shows.currentGenre!].shows[Episodes.currentShow!].description
        {
            self.showDescription.text = description
            
        }
        else
        {
            self.showDescription.text = "No description available."
        }
        
        TableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        rowForSegue = indexPath.row
        performSegueWithIdentifier("episodesgotoplayer", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == "episodesgotoplayer")
        {
            let avplayer = segue.destinationViewController as! AVPlayerViewController
            if let episodeurlstr = (Genre.genres?[Shows.currentGenre!].shows[Episodes.currentShow!].episodes[rowForSegue!].url)
            {
                if let episodeurl = NSURL(string: episodeurlstr)
                {
                    avplayer.player = AVPlayer(URL: episodeurl)
                }
            }
        }
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let genre = Shows.currentGenre
        {
            if let show = Episodes.currentShow
            {
                if let count = Genre.genres?[genre].shows[show].episodes.count
                {
                    return count
                }
            }
        }
        
        return 0;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "episodecell")
        let row = indexPath.row
        
        if let title = Genre.genres?[Shows.currentGenre!].shows[Episodes.currentShow!].episodes[row].video
        {
            cell.textLabel!.text = title
        }
        else
        {
            cell.textLabel!.text  = "Untitled Episode"
        }
        
        if let description = Genre.genres?[Shows.currentGenre!].shows[Episodes.currentShow!].episodes[row].description
        {
            cell.detailTextLabel!.text = description
        }
        else
        {
            cell.detailTextLabel!.text = ""
        }
        
        return cell
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
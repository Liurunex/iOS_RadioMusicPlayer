//
//  VolumeDetailController.swift
//  FinalProject
//
//  Created by Runex on 7/30/15.
//
//
protocol VolumeProtocol {
    func volumeChannel(volumeID: Int )
}
import UIKit
import CoreData

class VolumeDetailController:UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var volumeImage: UIImageView!
    @IBOutlet weak var volumeList: UITableView!
    @IBOutlet weak var volumeTitle: UILabel!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var addVolume: UIButton!
    @IBOutlet weak var playVolume: UIButton!
    @IBOutlet weak var toolVolume: UIBarButtonItem!
    @IBOutlet weak var toolPlay: UIBarButtonItem!
    var tableData: NSArray = NSArray()
    var imageData = Dictionary<String, UIImage>()
    var volumeID: String = ""
    //var delegate: VolumeProtocol?
    var test_id: Int = 0
    var song_id: Int = 0
    var mark_visitFromplay: Bool = false
    let urlArray: Array<String> = VolumeService.volumeService.urlForCategory()!
    var mark_visitFromVolume: Bool = false
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var loveVolume: Volume? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imagedata: Array<String> = VolumeService.volumeService.imageNamesForCategory()!
        self.volumeImage.image = UIImage(named:  imagedata[self.test_id])
        //self.backImage.image = UIImage(named: imagedata[self.test_id])
        let titledata: Array<String> = VolumeService.volumeService.titleNamesForCategory()!
        self.volumeTitle.text = titledata[self.test_id]
        insertBlurView(blurView,style: UIBlurEffectStyle.Light)
        self.volumeList.reloadData()
        addVolume.addTarget(self, action: "AddLike:", forControlEvents: UIControlEvents.TouchUpInside)
        self.ButtonIcon()
        
        if mark_visitFromplay {
            self.playVolume.hidden = true
            self.toolPlay.enabled = false
            self.mark_visitFromplay = false
        }
        if mark_visitFromVolume {
            self.toolVolume.enabled = false
            self.mark_visitFromVolume = false
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func ButtonIcon() {
        let context = self.context
        let fetchRequest = NSFetchRequest(entityName: "Volume")
        fetchRequest.predicate = NSPredicate(format: "address = %@", self.urlArray[self.test_id])
        if context?.countForFetchRequest(fetchRequest, error: nil) == 0 {
            let image = UIImage(named: "like") as UIImage!
            self.addVolume.setImage(image, forState: .Normal)
        }
        else {
            let image = UIImage(named: "liked") as UIImage!
            self.addVolume.setImage(image, forState: .Normal)
        }
    }
    
    func AddLike(sender: UIButton!) {
        let context = self.context
        let fetchRequest = NSFetchRequest(entityName: "Volume")
    
        fetchRequest.predicate = NSPredicate(format: "address = %@", self.urlArray[self.test_id])
        
        if context?.countForFetchRequest(fetchRequest, error: nil) == 0 {
            let NewVolume = NSEntityDescription.entityForName("Volume", inManagedObjectContext: context!)
            let vItem: Volume = Volume(entity: NewVolume!, insertIntoManagedObjectContext: context)
            vItem.id = (self.test_id)
            vItem.address = self.urlArray[self.test_id]
            do {
                try context?.save()
            } catch _ {
            }
        }
        else {
            var fetcharray: Array<Volume>!
            fetcharray = (try! context?.executeFetchRequest(fetchRequest)) as! Array<Volume>
            
            for item in fetcharray {
                if item.address == self.urlArray[self.test_id] {
                    context!.deleteObject(item)
                    do {
                        try context?.save()
                    } catch _ {
                    }
                }
            }
        }
        
        self.ButtonIcon()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*func didRecieveResults(results: NSDictionary) {
    if (results["song"] != nil) {
    self.tableData = results["song"] as! NSArray
    self.volumeList.reloadData()
    //setImage()
    }
    }*/
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "VolumeListCell")
        cell.backgroundColor = UIColor.clearColor()
        
        cell.textLabel?.font = UIFont.systemFontOfSize(15.0)
        cell.detailTextLabel?.font = UIFont.systemFontOfSize(12.0)
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
        
        let celldata: NSDictionary = self.tableData[indexPath.row] as! NSDictionary
        cell.textLabel?.text = celldata["title"] as? String
        cell.detailTextLabel?.text = celldata["artist"] as? String
        cell.imageView?.image = UIImage(named: "music")
        
        let url = celldata["picture"] as! String
        if let image = self.imageData[url] {
            cell.imageView?.image = image
        } else {
            let imageUrl: NSURL = NSURL(string: url)!
            let request: NSURLRequest = NSURLRequest(URL: imageUrl)
            cell.imageView?.image = UIImage(named: "music")
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                let Img = UIImage(data: data!)
                cell.imageView?.image = Img
                self.imageData[url] = Img
                cell.setNeedsDisplay()
            })
        }
        // cell.image = UIImage(named: "")
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.song_id = indexPath.row
        self.performSegueWithIdentifier("volumedetail2songdetail", sender: nil)
    }
    
    func insertBlurView (view: UIView,  style: UIBlurEffectStyle) {
        view.backgroundColor = UIColor.clearColor()
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        view.insertSubview(blurEffectView, atIndex: 0)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "volumeDetail2play" {
            let playView: PlayViewController = segue.destinationViewController as! PlayViewController
            playView.tableData = self.tableData
            playView.volume_id = self.test_id
            MusicService.sharedMusicService.havePlayed = false
            MusicService.sharedMusicService.setMusicService(self.tableData)
            MusicService.sharedMusicService.id = 0
            playView.mark_FromDetail = true
        }
        if segue.identifier == "volumedetail2songdetail" {
            let songDetail: SongDetail = segue.destinationViewController as! SongDetail
            songDetail.tableData = self.tableData
            songDetail.SongData = self.tableData[self.song_id] as! NSDictionary
            //MusicService.sharedMusicService.havePlayed = false
        }
        if segue.identifier == "volumedetail2user" {
            let userController: UserController = segue.destinationViewController as! UserController
            userController.tableData = self.tableData
        }
        if segue.identifier == "volumeDetail2playing" {
            let playView: PlayViewController = segue.destinationViewController as! PlayViewController
            playView.tableData = MusicService.sharedMusicService.tableData
            playView.volume_id = MusicService.sharedMusicService.vid
            playView.mark_FromDetail = true
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        var result: Bool = true
        switch identifier {
        case "volumeDetail2play":
            fallthrough
        case "volumedetail2songdetail":
            do {
                let reachabilityUtility = try Reachability.reachabilityForInternetConnection()
                if reachabilityUtility.isReachable() {
                    result = true
                }
                else {
                    result = false
                    UIAlertView(title: "No Internet Connection", message: "Please check your connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
                }
            }
            catch _{
                print("some thing happened")
            }
            
        case "volumeDetail2volumeList":
            return true
        case "volumeDetail2playing":
            if MusicService.sharedMusicService.havePlayed == false {
                let alert = UIAlertView()
                alert.title = "No PlayList Slected"
                alert.message = "Please Select a Volume in Volume List"
                alert.addButtonWithTitle("Ok")
                alert.show()
                return false
            }
            else {
                return true
            }
        default:
            result = super.shouldPerformSegueWithIdentifier(identifier, sender: sender)
        }
        
        return result
    }
    
}
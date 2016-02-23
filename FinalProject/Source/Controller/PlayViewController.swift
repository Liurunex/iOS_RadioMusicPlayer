//
//  PlayViewController.swift
//  FinalProject
//
//  Created by Runex on 7/30/15.
//
//

import UIKit
import CoreData

class PlayViewController: UIViewController{
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var playimage: UIImageView!
    @IBOutlet weak var playname: UILabel!
    @IBOutlet weak var nextPlay: UIButton!
    @IBOutlet weak var previousPlay: UIButton!
    @IBOutlet weak var playprogress: UIProgressView!
    @IBOutlet weak var playtime: UILabel!
    @IBOutlet weak var AddSong: UIButton!
    @IBOutlet weak var pauseplay: UIButton!
    @IBOutlet weak var addLike: UIButton!
    @IBOutlet weak var toolDetail: UIBarButtonItem!
    
    
    //var urldata: String = "http://douban.fm/j/mine/playlist?channel=14"
    //var eHttp: HttpControl = HttpControl()
    var tableData: NSArray = NSArray()
    var imageData = Dictionary<String, UIImage>()
    var TimeProgress: NSTimer?
    var pause: Bool = true
    var volume_id: Int = 0
    var mark_FromDetail: Bool = false
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var loveVolume: Volume? = nil
    //let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    override func viewDidLoad() {
        super.viewDidLoad()
        if mark_FromDetail {
            self.toolDetail.enabled = false
            self.mark_FromDetail = false
        }
        self.ButtonIcon()
        playprogress.progress = 0.0
        pauseplay.addTarget(self, action: "pauseActions:", forControlEvents: UIControlEvents.TouchUpInside)
        nextPlay.addTarget(self, action: "nextActions:", forControlEvents: UIControlEvents.TouchUpInside)
        previousPlay.addTarget(self, action: "previousActions:", forControlEvents: UIControlEvents.TouchUpInside)
        AddSong.addTarget(self, action: "AddLike:", forControlEvents: UIControlEvents.TouchUpInside)
        
        if MusicService.sharedMusicService.havePlayed == false {
            MusicService.sharedMusicService.id = 0
            self.didRecieveResults()
        }
 
        if MusicService.sharedMusicService.pause {
            let image = UIImage(named: "player_2") as UIImage!
            self.pauseplay.setImage(image, forState: .Normal)
        }
        else {
            let image = UIImage(named: "pause_2") as UIImage!
            self.pauseplay.setImage(image, forState: .Normal)
        }
        /*let viewRefresh = MusicService.sharedMusicService.tableData[MusicService.sharedMusicService.id] as! NSDictionary
        self.setImage(viewRefresh["picture"] as! String)
        self.setMusicTitle(viewRefresh)*/
        self.refreshView()
    }
    
    func refreshView() {
        dispatch_async(dispatch_get_main_queue(), {
            () ->Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            let song = MusicService.sharedMusicService.tableData[MusicService.sharedMusicService.id] as! NSDictionary
            let imageUrl = song["picture"] as! String
            self.setImage(imageUrl)
            self.setMusicTitle(song)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.ButtonIcon()
        self.refreshView()
        if MusicService.sharedMusicService.pause {
            let image = UIImage(named: "player_2") as UIImage!
            self.pauseplay.setImage(image, forState: .Normal)
        }
        else {
            let image = UIImage(named: "pause_2") as UIImage!
            self.pauseplay.setImage(image, forState: .Normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func didRecieveResults() {
        let FirstData: NSDictionary = self.tableData[0] as! NSDictionary
        let musicUrl: String = FirstData["url"] as! String
        let song = self.tableData[0] as! NSDictionary
        let ImageUrl: String = FirstData["picture"] as! String
        MusicService.sharedMusicService.havePlayed = true
        dispatch_async(dispatch_get_main_queue(), {
            () ->Void in
            
            self.setMusic(musicUrl)
            self.setMusicTitle(song)
            self.setImage(ImageUrl)

            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    func setMusicTitle(song : NSDictionary) {
        self.playname.text = MusicService.sharedMusicService.setMusicTitle(song)
    }
    
    func setMusic(url: String) {
        TimeProgress?.invalidate()
        playtime.text = "00:00"
        MusicService.sharedMusicService.setMusic(url)
        TimeProgress = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "TimeUpdate", userInfo: nil, repeats: true)
    }
    
    func TimeUpdate() {
        let songlength: NSDictionary = MusicService.sharedMusicService.tableData[MusicService.sharedMusicService.id] as! NSDictionary
        let length: Double = songlength["length"] as! Double
        let modifiedlength = length - 3.0
        let pastTime = MusicService.sharedMusicService.musicPlyaer.currentPlaybackTime
        
        if pastTime > modifiedlength {
            playerDidFinishPlaying()
        }
        else {
            if pastTime > 0.0 {
                let time = MusicService.sharedMusicService.musicPlyaer.duration
                let rate: CFloat = CFloat(pastTime/time)
                playprogress.setProgress(rate, animated: true)
                //label time display
                let totalTime: Int = Int(pastTime)
                let second: Int = totalTime % 60
                let minute: Int = Int(totalTime/60)
                var displayTime: String = ""
                if minute < 10 {
                    displayTime = "0\(minute):"
                }
                else {
                    displayTime = "\(minute):"
                }
                if second < 10 {
                    displayTime += "0\(second)"
                }
                else {
                    displayTime += "\(second)"
                }
                playtime.text = displayTime
            }
        }
        
    }
    
    func setImage(url: String) {
        //self.playimage.image = MusicService.sharedMusicService.setImage(url)
        if let image = MusicService.sharedMusicService.imageData[url] {
            self.playimage.image = image
        }
        else {
            //var rImg: UIImage = UIImage()
            let imageUrl: NSURL = NSURL(string: url)!
            let request: NSURLRequest = NSURLRequest(URL: imageUrl)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                let Img = UIImage(data: data!)
                MusicService.sharedMusicService.imageData[url] = Img
                self.playimage.image = Img
            })
        }

    }
    
    func pauseActions(sender: UIButton!) {
        if MusicService.sharedMusicService.pause {
            MusicService.sharedMusicService.musicPlyaer.play()
            let image = UIImage(named: "pause_2") as UIImage!
            self.pauseplay.setImage(image, forState: .Normal)
            MusicService.sharedMusicService.pause = false
        }
        else {
            MusicService.sharedMusicService.musicPlyaer.pause()
            let image = UIImage(named: "player_2") as UIImage!
            self.pauseplay.setImage(image, forState: .Normal)
            MusicService.sharedMusicService.pause = true
        }
        self.ButtonIcon()
    }
    
    func previousActions(sender: UIButton!) {
        var cid = MusicService.sharedMusicService.id
        do {
            let reachabilityUtility = try Reachability.reachabilityForInternetConnection()
            if reachabilityUtility.isReachable() {
                if cid > 0 {
                    cid = cid-1
                    self.updataPlaying(cid)
                }
                else {
                    cid = MusicService.sharedMusicService.tableData.count-1
                    self.updataPlaying(cid)
                }
            }
            else {
                UIAlertView(title: "No Internet Connection", message: "Please check your connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
            }
        }
        catch _{
            print("something wrong")
        }
       
        MusicService.sharedMusicService.id = cid
        //self.id = MusicService.sharedMusicService.id
        self.ButtonIcon()
        let image = UIImage(named: "pause_2") as UIImage!
        self.pauseplay.setImage(image, forState: .Normal)
        MusicService.sharedMusicService.pause = false
    }
    
    func nextActions(sender: UIButton!) {
        var cid = MusicService.sharedMusicService.id
        do {
            let reachabilityUtility = try Reachability.reachabilityForInternetConnection()
            if reachabilityUtility.isReachable() {
                if cid < MusicService.sharedMusicService.tableData.count-1 {
                    cid += 1
                    self.updataPlaying(cid)
                }
                else {
                    cid = 0
                    self.updataPlaying(cid)
                }
            }
            else {
                UIAlertView(title: "No Internet Connection", message: "Please check your connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
            }

        }
        catch _{
            print("something wrong")
        }
        MusicService.sharedMusicService.id = cid
        //self.id = MusicService.sharedMusicService.id
        self.ButtonIcon()
        let image = UIImage(named: "pause_2") as UIImage!
        self.pauseplay.setImage(image, forState: .Normal)
        MusicService.sharedMusicService.pause = false
    }
    
    func playerDidFinishPlaying() {
        do{
            let reachabilityUtility = try Reachability.reachabilityForInternetConnection()
            if reachabilityUtility.isReachable() {
                if MusicService.sharedMusicService.id < tableData.count-1 {
                    MusicService.sharedMusicService.id += 1
                    self.updataPlaying(MusicService.sharedMusicService.id)
                }
                else {
                    MusicService.sharedMusicService.id = 0
                    self.updataPlaying(MusicService.sharedMusicService.id)
                }
            }
            else {
                UIAlertView(title: "No Internet Connection", message: "Please check your connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
            }
        }
        catch _{
            print("something wrong")
        }
        
        self.ButtonIcon()
    }
    
    func AddLike(sender: UIButton!) {
        let context = self.context
        let song =  self.tableData[MusicService.sharedMusicService.id] as! NSDictionary
        
        let fetchRequest = NSFetchRequest(entityName: "Song")
        fetchRequest.predicate = NSPredicate(format: "title = %@", song["title"] as! String)
        
        if context?.countForFetchRequest(fetchRequest, error: nil) == 0 {
            let NewSong = NSEntityDescription.entityForName("Song", inManagedObjectContext: context!)
            let sItem = Song(entity: NewSong!, insertIntoManagedObjectContext: context)
            sItem.url = song["url"] as! String
            sItem.image = song["picture"] as! String
            sItem.title = song["title"] as! String
            sItem.artist = song["artist"] as! String
            sItem.company = song["company"] as! String
            sItem.albumtitle = song["albumtitle"] as! String
            sItem.public_time = song["public_time"] as! String
            do {
                try context?.save()
            } catch _ {
            }
        }
        else {
            var fetcharray: Array<Song>!
            fetcharray = (try! context?.executeFetchRequest(fetchRequest)) as! Array<Song>
            
            for item in fetcharray {
                if item.title == song["title"] as! String {
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
    
    func ButtonIcon() {
        let context = self.context
        let song =  MusicService.sharedMusicService.tableData[MusicService.sharedMusicService.id] as! NSDictionary
        let fetchRequest = NSFetchRequest(entityName: "Song")
        fetchRequest.predicate = NSPredicate(format: "title = %@", song["title"] as! String)
        if context?.countForFetchRequest(fetchRequest, error: nil) == 0 {
            let image = UIImage(named: "like") as UIImage!
            self.addLike.setImage(image, forState: .Normal)
        }
        else {
            let image = UIImage(named: "liked") as UIImage!
            self.addLike.setImage(image, forState: .Normal)
        }
    }
    
    func updataPlaying(id: Int) {
        dispatch_async(dispatch_get_main_queue(), {
            () ->Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            let song = MusicService.sharedMusicService.tableData[MusicService.sharedMusicService.id] as! NSDictionary
            let songURL = song["url"] as! String
            let imageUrl = song["picture"] as! String
            self.setMusic(songURL)
            self.setImage(imageUrl)
            self.setMusicTitle(song)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier{
        case .Some("play2volumeDetail"):
            let volumeDetail: VolumeDetailController = segue.destinationViewController as! VolumeDetailController
            volumeDetail.test_id = self.volume_id
            volumeDetail.tableData = self.tableData
            volumeDetail.mark_visitFromplay = true
        case .Some("play2songdetail"):
            let songDetail: SongDetail = segue.destinationViewController as! SongDetail
            //songDetail.id = MusicService.sharedMusicService.id
            songDetail.SongData = MusicService.sharedMusicService.tableData[MusicService.sharedMusicService.id] as! NSDictionary
            songDetail.tableData = self.tableData
        case .Some("play2user"):
            let userController: UserController = segue.destinationViewController as! UserController
            userController.tableData = self.tableData
            userController.mark_visitFromplay = true
        default:
            super.prepareForSegue(segue, sender: sender)
        }
    }
}

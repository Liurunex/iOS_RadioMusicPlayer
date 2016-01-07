//
//  SongDetailController.swift
//  FinalProject
//
//  Created by Runex on 7/30/15.
//
//

import UIKit
import MediaPlayer

class SongDetail: UIViewController, HttpProtocol{
    
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songLimage: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nextbutton: UIButton!
    @IBOutlet weak var LyricLabel: UITextView!
    
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var company: UILabel!
    @IBOutlet weak var publish: UILabel!
    @IBOutlet weak var ifo_title: UILabel!
    @IBOutlet weak var source: UILabel!
    @IBOutlet weak var albuumtitle: UILabel!
    
    @IBOutlet weak var PlayCurrent: UIButton!
    
    var musicUrl: String = "http://geci.me/api/lyric/"
    var lyricUrl: String = ""
    var pause: Bool = true
    var SongData: NSDictionary = NSDictionary()
    var tableData: NSArray = NSArray()
    var preLyricData: NSArray = NSArray()
    var LyricData = Dictionary<String, String>()
    var imageData = Dictionary<String, UIImage>()
    var eHttp: HttpControl = HttpControl()
    var TimeProgress: NSTimer?
    //special for song data from UserView
    var userUrl: String = ""
    var userImage: String = ""
    var userTitle: String = ""
    var usrArtist: String = ""
    var userCompany: String = ""
    var userPublic_time: String = ""
    var userAlbumtitle: String = ""
    var markForUserSegue: String = ""
    var currentMusicUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var searchTitle: String = ""
        var ImageUrl: String = ""
        
        if markForUserSegue == "" {
            searchTitle = self.SongData["title"] as! String
            ImageUrl = SongData["picture"] as! String
        }
        else {
            searchTitle = self.userTitle
            ImageUrl = self.userImage
        }
        musicUrl += "海阔天空"
        eHttp.delegate = self
        eHttp.onSearch(musicUrl)
    
        if MusicService.sharedMusicService.havePlayed {
            let song = MusicService.sharedMusicService.tableData[MusicService.sharedMusicService.id] as! NSDictionary
            self.setMusicTitle(song)
            self.setPlayImage(song["picture"] as! String)
            if MusicService.sharedMusicService.pause {
                let image = UIImage(named: "player_2") as UIImage!
                self.playButton.setImage(image, forState: .Normal)
            }
            else {
                let image = UIImage(named: "pause_2") as UIImage!
                self.playButton.setImage(image, forState: .Normal)
            }
        }
        else {
            let image = UIImage(named: "player_2") as UIImage!
            self.playButton.setImage(image, forState: .Normal)
        }
        
        playButton.addTarget(self, action: "playActions:", forControlEvents: UIControlEvents.TouchUpInside)
        nextbutton.addTarget(self, action: "nextActions:", forControlEvents: UIControlEvents.TouchUpInside)
        PlayCurrent.addTarget(self, action: "playCurrent", forControlEvents: UIControlEvents.TouchUpInside)
        self.LyricLabel.editable = false
        dispatch_async(dispatch_get_main_queue(), {
            () ->Void in
            self.setImage(ImageUrl)
            if self.markForUserSegue == "user" {
                self.artist.text = self.usrArtist
                self.albuumtitle.text = self.userAlbumtitle
                self.source.text = self.userUrl
                self.company.text = self.userCompany
                self.ifo_title.text = self.userTitle
                self.publish.text = self.userPublic_time
                self.markForUserSegue = ""
                self.currentMusicUrl = self.userUrl
            } else {
                self.artist.text = self.SongData["artist"] as? String
                self.albuumtitle.text = self.SongData["albumtitle"] as? String
                self.source.text = self.SongData["url"] as? String
                self.company.text = self.SongData["company"] as? String
                self.ifo_title.text = self.SongData["title"] as? String
                self.publish.text = self.SongData["public_time"] as? String
                self.currentMusicUrl = self.SongData["url"] as! String
            }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
        print(self.userTitle)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if MusicService.sharedMusicService.havePlayed {
            if MusicService.sharedMusicService.pause {
                let image = UIImage(named: "player_2") as UIImage!
                self.playButton.setImage(image, forState: .Normal)
            }
            else {
                let image = UIImage(named: "pause_2") as UIImage!
                self.playButton.setImage(image, forState: .Normal)
            }
        }
    }
    
    func setLyric(url: String) {
        if url == "Opps, No Result Found" {
           self.LyricLabel.text = url
            //println(url)
        }
        else {
            if let lyric = self.LyricData[url] {
               self.LyricLabel.text = lyric
                //println(lyric)
            }
            else {
                let thisUrl: NSURL = NSURL(string: url)!
                let request: NSURLRequest = NSURLRequest(URL: thisUrl)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                    let lyrics = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                    self.LyricLabel.text = lyrics as String
                    self.LyricData[url] = lyrics as String
                    //println(lyrics)
                })
            }
            
        }
    }
    
    func RecievePlayerResults() {
        MusicService.sharedMusicService.setMusicService(self.tableData)
        let FirstData: NSDictionary = MusicService.sharedMusicService.tableData[0] as! NSDictionary
        let musicUrl: String = FirstData["url"] as! String
        let song = self.tableData[0] as! NSDictionary
        let ImageUrl: String = FirstData["picture"] as! String
        MusicService.sharedMusicService.havePlayed = true
        dispatch_async(dispatch_get_main_queue(), {
            () ->Void in
            
            MusicService.sharedMusicService.setMusic(musicUrl)
            self.setMusicTitle(song)
            self.setPlayImage(ImageUrl)
        
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    func setMusicTitle(song : NSDictionary) {
        self.songTitle.text = MusicService.sharedMusicService.setMusicTitle(song)
    }
    
    func setImage(url: String) {
        if let image = self.imageData[url] {
            self.songImage.image = image
        }
        else {
            let imageUrl: NSURL = NSURL(string: url)!
            let request: NSURLRequest = NSURLRequest(URL: imageUrl)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                let Img = UIImage(data: data!)
                self.songImage.image = Img
                self.imageData[url] = Img
            })
        }
    }
    
    func setPlayImage(url: String) {
        if let image = MusicService.sharedMusicService.imageData[url] {
            self.songLimage.image = image
        }
        else {
            let imageUrl: NSURL = NSURL(string: url)!
            let request: NSURLRequest = NSURLRequest(URL: imageUrl)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                let Img = UIImage(data: data!)
                self.songLimage.image = Img
                MusicService.sharedMusicService.imageData[url] = Img
            })
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playActions(sender: UIButton!) {
        if MusicService.sharedMusicService.havePlayed == false {
            /*MusicService.sharedMusicService.id = 0
            let image = UIImage(named: "pause_2") as UIImage!
            self.playButton.setImage(image, forState: .Normal)
            self.RecievePlayerResults()*/
            let alert = UIAlertView()
            alert.title = "No PlayList Slected"
            alert.message = "Please Select a Volume in Volume List"
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
        else {
            if MusicService.sharedMusicService.pause {
                MusicService.sharedMusicService.musicPlyaer.play()
                let image = UIImage(named: "pause_2") as UIImage!
                self.playButton.setImage(image, forState: .Normal)
                MusicService.sharedMusicService.pause = false
            }
            else {
                MusicService.sharedMusicService.musicPlyaer.pause()
                let image = UIImage(named: "player_2") as UIImage!
                //PlayViewController.playController.pauseplay.setImage(image, forState: .Normal)
                self.playButton.setImage(image, forState: .Normal)
                MusicService.sharedMusicService.pause = true
            }
        }
    }
    
    func nextActions(sender: UIButton!) {
        if MusicService.sharedMusicService.havePlayed == false {
            /*MusicService.sharedMusicService.id = 0
            let image = UIImage(named: "pause_2") as UIImage!
            self.playButton.setImage(image, forState: .Normal)
            self.RecievePlayerResults()*/
            let alert = UIAlertView()
            alert.title = "No PlayList Slected"
            alert.message = "Please Select a Volume in Volume List"
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
        else {
            var cid = MusicService.sharedMusicService.id
            let reachabilityUtility = Reachability.reachabilityForInternetConnection()
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
            
            MusicService.sharedMusicService.id = cid
            //self.id = MusicService.sharedMusicService.id
        }
        //PlayViewController.playController.nextActions(nextbutton)
    }
    
    func playCurrent(sender: UIButton!) {
        MusicService.sharedMusicService.musicPlyaer.pause()
        dispatch_async(dispatch_get_main_queue(), {
            () ->Void in
                MusicService.sharedMusicService.setMusic(self.currentMusicUrl)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    func updataPlaying(id: Int) {
        dispatch_async(dispatch_get_main_queue(), {
            () ->Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            let song = MusicService.sharedMusicService.tableData[MusicService.sharedMusicService.id] as! NSDictionary
            let songURL = song["url"] as! String
            let imageUrl = song["picture"] as! String
            
            MusicService.sharedMusicService.setMusic(songURL)
            self.setPlayImage(imageUrl)
            self.setMusicTitle(song)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
        
    }
    
    func didRecieveResults(results: NSDictionary) {
        if (results["result"] != nil) {
            self.preLyricData = results["result"] as! NSArray
            let ChooseData = self.preLyricData[0] as! NSDictionary
            self.lyricUrl = ChooseData["lrc"] as! String
            //println(self.lyricUrl)
            dispatch_async(dispatch_get_main_queue(), {
            () ->Void in
            self.setLyric(self.lyricUrl)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
        }
        else {
           self.LyricLabel.text = "Opps, No Result Found"
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "songdetail2user" {
            let userController: UserController = segue.destinationViewController as! UserController
            userController.tableData = self.tableData
        }
    }

}



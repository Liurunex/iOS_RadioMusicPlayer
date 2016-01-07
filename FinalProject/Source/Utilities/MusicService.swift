//
//  MusicService.swift
//  FinalProject
//
//  Created by Runex on 8/7/15.
//
//

import Foundation
import MediaPlayer

class MusicService {
    var musicPlyaer: MPMoviePlayerController = MPMoviePlayerController()
    var tableData: NSArray = NSArray()
    var imageData = Dictionary<String, UIImage>()
    var pause: Bool = false
    var id: Int = 0
    var vid: Int = 0
    var havePlayed: Bool = false
    var TimeProgress: NSTimer?
    //var vid: Int = 0
    
    private init() {
        // Intentionally left blank
    }
    
    func setMusicService(TableDate: NSArray) {
        self.tableData = TableDate
    }
    
    func didRecieveResults() {
        let FirstData: NSDictionary = self.tableData[0] as! NSDictionary
        let musicUrl: String = FirstData["url"] as! String
        let song = self.tableData[0] as! NSDictionary
        let ImageUrl: String = FirstData["picture"] as! String
        
        dispatch_async(dispatch_get_main_queue(), {
            () ->Void in
            
            self.setMusic(musicUrl)
            //self.setMusicTitle(song)
            //self.setImage(ImageUrl)
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    func setMusicTitle(song : NSDictionary) -> String?{
        let rtitle = song["title"] as? String
        return rtitle
    }
    
    func setMusic(url: String) {
        //TimeProgress?.invalidate()
        self.musicPlyaer.stop()
        self.musicPlyaer.contentURL = NSURL(string: url)
        self.musicPlyaer.play()
    }
    
    /*func TimeUpdate() {
        let pastTime = musicPlyaer.currentPlaybackTime
        if pastTime > 0.0 {
            let time = musicPlyaer.duration
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
        
    }*/
    func setImage(url: String) -> UIImage{
        if let image = self.imageData[url] {
            return image
        }
        else {
            var rImg: UIImage = UIImage()
            let imageUrl: NSURL = NSURL(string: url)!
            let request: NSURLRequest = NSURLRequest(URL: imageUrl)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                let Img = UIImage(data: data)
                self.imageData[url] = Img
                rImg = Img!
            })
            return rImg
        }
    }
    
    func pauseActions() {
        if pause {
            self.musicPlyaer.pause()
            let image = UIImage(named: "player_2") as UIImage!
            //self.pauseplay.setImage(image, forState: .Normal)
            pause = false
        }
        else {
            self.musicPlyaer.play()
            let image = UIImage(named: "pause_2") as UIImage!
            //self.pauseplay.setImage(image, forState: .Normal)
            pause = true
        }
    }
    func previousActions() {
        let reachabilityUtility = Reachability.reachabilityForInternetConnection()
        if reachabilityUtility.isReachable() {
            if self.id > 0 {
                self.id = self.id-1
                self.updataPlaying(id)
            }
            else {
                self.id = tableData.count-1
                self.updataPlaying(id)
            }
        }
        else {
            UIAlertView(title: "No Internet Connection", message: "Please check your connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    func nextActions() {
        let reachabilityUtility = Reachability.reachabilityForInternetConnection()
        if reachabilityUtility.isReachable() {
            if self.id < tableData.count-1 {
                self.id += 1
                self.updataPlaying(id)
            }
            else {
                self.id = 0
                self.updataPlaying(id)
            }
        }
        else {
            UIAlertView(title: "No Internet Connection", message: "Please check your connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    
    func playerDidFinishPlaying() {
        let reachabilityUtility = Reachability.reachabilityForInternetConnection()
        if reachabilityUtility.isReachable() {
            if self.id < tableData.count-1 {
                self.id += 1
                self.updataPlaying(id)
            }
            else {
                self.id = 0
                self.updataPlaying(id)
            }
        }
        else {
            UIAlertView(title: "No Internet Connection", message: "Please check your connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    
    func updataPlaying(id: Int) {
        dispatch_async(dispatch_get_main_queue(), {
            () ->Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            let song = self.tableData[self.id] as! NSDictionary
            let songURL = song["url"] as! String
            let imageUrl = song["picture"] as! String
            self.setMusic(songURL)
            self.setImage(imageUrl)
            self.setMusicTitle(song)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
        
    }
    static var sharedMusicService = MusicService()
}
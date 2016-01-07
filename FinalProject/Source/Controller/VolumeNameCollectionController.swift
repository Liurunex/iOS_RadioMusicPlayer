//
//  VolumeNameCollectionController.swift
//  FinalProject
//
//  Created by Runex on 7/30/15.
//
//

import UIKit
//import CoreData

class VolumeNameCollectionController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, HttpProtocol, VolumeNameCellDelegate, UIAlertViewDelegate{
    
    @IBOutlet weak var cv: UICollectionView!
    
    var id: Int = 0
    var volumeData: NSArray = NSArray()
    var musicList = NSMutableArray()
    var eHttp: HttpControl = HttpControl()
    
    func volumeNameCellDidSelectPlay(cell: VolumeNameCell) {
        let indexPath = cv.indexPathForCell(cell)!
        self.id = indexPath.row
        performSegueWithIdentifier("volumelist2play", sender: self)
    }
    
    func volumeNameCellDidSelectDetails(cell: VolumeNameCell) {
        let indexPath = cv.indexPathForCell(cell)!
        self.id = indexPath.row
        performSegueWithIdentifier("volumelist2volumedetail", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let urlArray: Array<String> = VolumeService.volumeService.urlForCategory()!
        var index: Int
        eHttp.delegate = self
        for index = 0; index < urlArray.count; ++index {
            //println(urlArray[index])
            eHttp.onSearch(urlArray[index])
            //firstList[index] = self.firstData
            //musicList[index] = self.musicUrl
            //imageList[index] = self.imageUrl
        }
        cv.dataSource = self
        cv.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func didRecieveResults(results: NSDictionary) {
        //self.volumeData.removeAll()
        if (results["song"] != nil) {
            self.volumeData = results["song"] as! NSArray
            self.musicList.addObject(self.volumeData)
            //println(musicList.count)
            //self.firstData = self.volumeData[0] as! NSDictionary
            //self.musicUrl = firstData["url"] as! String
            //self.imageUrl = firstData["picture"] as! String
        }
        else {
            let title: String = "Error"
            let message: String = "No Data Return"
            let alertView = UIAlertView(title:title, message: message, delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Done")
            alertView.alertViewStyle = .Default
            alertView.show()

        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return VolumeService.volumeService.imageNamesForCategory()!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: VolumeNameCell = cv.dequeueReusableCellWithReuseIdentifier("VolumeName", forIndexPath: indexPath) as! VolumeNameCell
        let imagedata: Array<String> = VolumeService.volumeService.imageNamesForCategory()!
        let titledata: Array<String> = VolumeService.volumeService.titleNamesForCategory()!
        let urldata: Array<String> = VolumeService.volumeService.urlForCategory()!
        cell.title.text = titledata[indexPath.row]
        cell.volumeImage.image = UIImage(named: imagedata[indexPath.row])
        cell.channelID = indexPath.row
        cell.urldata = urldata[indexPath.row]
        cell.delegate = self
        return cell
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier{
        case .Some("volumelist2volumedetail"):
            let volumeDetail: VolumeDetailController = segue.destinationViewController as! VolumeDetailController
                volumeDetail.test_id = self.id
                volumeDetail.tableData = self.musicList[self.id] as! NSArray
                volumeDetail.mark_visitFromVolume = true
                //MusicService.sharedMusicService.setMusicService(self.musicList[self.id] as! NSArray)
            if  MusicService.sharedMusicService.havePlayed == false{
                MusicService.sharedMusicService.havePlayed = false
            }
        case .Some("volumelist2play"):
            let playView: PlayViewController = segue.destinationViewController as! PlayViewController
                playView.tableData = self.musicList[self.id] as! NSArray
                playView.volume_id = self.id
                MusicService.sharedMusicService.setMusicService(self.musicList[self.id] as! NSArray)
                MusicService.sharedMusicService.havePlayed = false
                MusicService.sharedMusicService.id = 0
                MusicService.sharedMusicService.vid = self.id
        case .Some("volumelist2playing"):
            let playView: PlayViewController = segue.destinationViewController as! PlayViewController
            playView.tableData = MusicService.sharedMusicService.tableData
            playView.volume_id = MusicService.sharedMusicService.vid
        case .Some("volumename2user"):
            let userController: UserController = segue.destinationViewController as! UserController
            userController.tableData = self.musicList[self.id] as! NSArray
            userController.mark_visitFromVolume = true
            //MusicService.sharedMusicService.setMusicService(self.musicList[self.id] as! NSArray)
            //MusicService.sharedMusicService.havePlayed = false
        default:
            super.prepareForSegue(segue, sender: sender)
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        let result: Bool
        switch identifier {
        case .Some("volumelist2volumedetail"):
            fallthrough
        case .Some("volumelist2play"):
            let reachabilityUtility = Reachability.reachabilityForInternetConnection()
            if reachabilityUtility.isReachable() {
                result = true
            }
            else {
                result = false
                UIAlertView(title: "No Internet Connection", message: "Please check your connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
            }
        case .Some("volumelist2playing"):
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
//
//  UserController.swift
//  FinalProject
//
//  Created by Runex on 8/5/15.
//
//

import UIKit
import CoreData

class UserController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var changeImage: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var EditButton: UIBarButtonItem!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var userimage: UIImageView!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var toolPlay: UIBarButtonItem!
    @IBOutlet weak var toolVolume: UIBarButtonItem!
    
    let context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    var frc: NSFetchedResultsController =  NSFetchedResultsController()
    var ffrrcc: NSFetchedResultsController =  NSFetchedResultsController()
    var ufrc: NSFetchedResultsController = NSFetchedResultsController()
    
    var tableData: NSArray = NSArray()
    var imageData = Dictionary<String, UIImage>()
    var Uimage = UIImage()
    var idList = [Int]()
    var pass_id: Int = 0
    var pass_id_songdetail: NSIndexPath = NSIndexPath()
    private var ignoreUpdates: Bool = false
    private var userNameTem: String = "Neo"
    var tField: UITextField!
    var mark_visitFromplay: Bool = false
    var mark_visitFromVolume: Bool = false
    func configurationTextField(textField: UITextField!)
    {
        textField.placeholder = "Enter User Name"
        tField = textField
    }
    func handleCancel(alertView: UIAlertAction!)
    {
        print("Cancell editing")
    }

    @IBAction private func showEdit(sender: AnyObject) {

        let alert = UIAlertController(title: "Edit User Name", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
            self.userNameTem = self.tField.text!
            let fetchRequest = NSFetchRequest(entityName: "User")
            if let fetchResults = (try? self.context.executeFetchRequest(fetchRequest)) as? [User] {
                fetchResults[0].name = self.userNameTem
                self.userName.text = fetchResults[0].name
                do {
                    try self.context.save()
                } catch _ {
                }
            }
            do {
                try self.context.save()
            } catch _ {
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    func getSongListResult() -> NSFetchedResultsController {
        frc = NSFetchedResultsController(fetchRequest: SongListFetchRequest(), managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }
    
    func getVolumeListResult() -> NSFetchedResultsController {
        ffrrcc = NSFetchedResultsController(fetchRequest: VolumeListFetchRequest(), managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return ffrrcc
    }
    
    func getUserResult() -> NSFetchedResultsController {
        ufrc = NSFetchedResultsController(fetchRequest: UserFetchRequest(), managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return ufrc
    }
    
    func SongListFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Song")
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    func VolumeListFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Volume")
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    func UserFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "User")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if mark_visitFromplay {
            self.toolPlay.enabled = false
            self.mark_visitFromplay = false
        }
        if mark_visitFromVolume {
            self.toolVolume.enabled = false
            self.mark_visitFromVolume = false
        }
        cv.dataSource = self
        cv.delegate = self
        //insertBlurView(blurView,style: UIBlurEffectStyle.Light)
        frc = getSongListResult()
        frc.delegate = self
        do {
            try frc.performFetch()
        } catch _ {
        }
        
        ffrrcc = getVolumeListResult()
        ffrrcc.delegate = self
        do {
            try ffrrcc.performFetch()
        } catch _ {
        }
        
        ufrc = getUserResult()
        ufrc.delegate = self
        do {
            try ufrc.performFetch()
        } catch _ {
        }
        
        userimage.layer.borderWidth = 1.0
        userimage.layer.masksToBounds = false
        userimage.layer.borderColor = UIColor.whiteColor().CGColor
        userimage.layer.cornerRadius = userimage.frame.size.width/2
        userimage.clipsToBounds = true
        
        let context = self.context
        let fetchRequest = NSFetchRequest(entityName: "User")
        fetchRequest.returnsObjectsAsFaults = false
        
        var results = try? context.executeFetchRequest(fetchRequest)
        if let resultsArray = results {
            if resultsArray.count <= 0 {
                // resultsArray is empty, so insert a new object
                let NewUser = NSEntityDescription.entityForName("User", inManagedObjectContext: context)
                let newUser: User = User(entity: NewUser!, insertIntoManagedObjectContext: context)
                newUser.name = "Neo"
                let image = UIImage(named: "Person")
                newUser.photo = UIImageJPEGRepresentation(image!, 1)!
                userimage.image = UIImage(data: newUser.photo)
                do {
                    try context.save()
                } catch _ {
                }
            }
            else {
                if let fetchResults = (try? context.executeFetchRequest(fetchRequest)) as? [User] {
                    userName.text = fetchResults[0].name
                    userimage.image =  UIImage(data: fetchResults[0].photo)
                }
            }
        }
        else {
            print("Nil returned by fetch")
        }
        changeImage.addTarget(self, action: "UimageChange:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func UimageChange(sender: UIButton!) {
        let photolibrary = UIImagePickerController()
        photolibrary.delegate = self
        photolibrary.sourceType = .PhotoLibrary
        self.presentViewController(photolibrary, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.Uimage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        self.dismissViewControllerAnimated(false, completion: nil)
        
        let fetchRequest = NSFetchRequest(entityName: "User")
        if let fetchResults = (try? self.context.executeFetchRequest(fetchRequest)) as? [User] {
            fetchResults[0].photo = UIImageJPEGRepresentation(self.Uimage, 1)!
            userimage.image = UIImage(data: fetchResults[0].photo)
            do {
                try self.context.save()
            } catch _ {
            }
        }
        do {
            try self.context.save()
        } catch _ {
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let fetchRequest = NSFetchRequest(entityName: "User")
        if let fetchResults = (try? context.executeFetchRequest(fetchRequest)) as? [User] {
            userName.text = fetchResults[0].name
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if !ignoreUpdates {
            table.reloadData()
            cv.reloadData()
        }
    }
    
    //collection delegate
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        let section = ffrrcc.sections?.count
        return section!
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let row = ffrrcc.sections?[section].numberOfObjects
        return row!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: UserVolumeCell = cv.dequeueReusableCellWithReuseIdentifier("LikedVolumeList", forIndexPath: indexPath) as! UserVolumeCell
        
        let volumeList = ffrrcc.objectAtIndexPath(indexPath) as! Volume
        let imagedata: Array<String> = VolumeService.volumeService.imageNamesForCategory()!
        let titledata: Array<String> = VolumeService.volumeService.titleNamesForCategory()!
        let urldata: Array<String> = VolumeService.volumeService.urlForCategory()!
        let CellID: Int = Int(volumeList.id)
        self.idList.append(CellID)
        cell.image.image = UIImage(named: imagedata[CellID])
        cell.title.text = titledata[CellID]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.pass_id = self.idList[indexPath.row]
        //cv.reloadData()
        self.performSegueWithIdentifier("user2volumedetail", sender: nil)
    }
    
    //table delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let section = frc.sections?.count
        return section!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let row = frc.sections?[section].numberOfObjects
        return row!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "LikeSongList")
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.font = UIFont.systemFontOfSize(15.0)
        cell.detailTextLabel?.font = UIFont.systemFontOfSize(12.0)
        cell.detailTextLabel?.textColor = UIColor.grayColor()
        let songlist = frc.objectAtIndexPath(indexPath) as! Song
        cell.textLabel?.text = songlist.title
        cell.detailTextLabel?.text = songlist.artist
        cell.imageView?.image = UIImage(named: "music")
        let url = songlist.image
    
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
   
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        ignoreUpdates = true
        let object: NSManagedObject = frc.objectAtIndexPath(indexPath) as! NSManagedObject
        context.deleteObject(object)
        do {
            try context.save()
        } catch _ {
        }

        table.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        ignoreUpdates = false
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.pass_id_songdetail = indexPath
        self.performSegueWithIdentifier("user2songdetail", sender: nil)
    }
    
    func insertBlurView (view: UIView,  style: UIBlurEffectStyle) {
        view.backgroundColor = UIColor.clearColor()
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        view.insertSubview(blurEffectView, atIndex: 0)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "user2volumedetail" {
            let volumeDetail: VolumeDetailController = segue.destinationViewController as! VolumeDetailController
            volumeDetail.test_id = self.pass_id
            volumeDetail.tableData = self.tableData
            volumeDetail.mark_visitFromplay = false
        }
        if segue.identifier == "user2playing" {
            let playView: PlayViewController = segue.destinationViewController as! PlayViewController
            playView.tableData = MusicService.sharedMusicService.tableData
            playView.volume_id = MusicService.sharedMusicService.vid
            print("User to Playing")
        }
        if segue.identifier == "user2songdetail" {
            let songDetail: SongDetail = segue.destinationViewController as! SongDetail
            let songlist = frc.objectAtIndexPath(self.pass_id_songdetail) as! Song

            songDetail.usrArtist = songlist.artist
            songDetail.userAlbumtitle = songlist.albumtitle
            songDetail.userCompany = songlist.company
            songDetail.userImage = songlist.image
            songDetail.userPublic_time = songlist.public_time
            songDetail.userTitle = songlist.title
            songDetail.userUrl = songlist.url
            songDetail.markForUserSegue = "user"
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        if identifier == "user2playing" {
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
        }
        return true
    }

}

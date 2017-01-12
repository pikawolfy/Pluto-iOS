//
//  DetailsVC.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 10/16/16.
//  Copyright © 2016 Faisal M. Lalani. All rights reserved.
//

import Firebase
import UIKit

class DetailController: UIViewController {

    // MARK: - OUTLETS
    
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var eventImageView: RoundImageView!
    
    @IBOutlet weak var detailsView: UIView!
    
//    @IBOutlet weak var eventTitleLabel: UILabel!
//    @IBOutlet weak var eventLocationLabel: UILabel!
//    @IBOutlet weak var eventTimeLabel: UILabel!
//    @IBOutlet weak var eventDescriptionTextView: UITextView!
    
//    @IBOutlet weak var friendsView: UICollectionView!
    
    // MARK: - VARIABLES
    
    private var headerMaskLayer = CAShapeLayer()
    
    /// Holds the key of the event passed from the main board screen.
    var event = Event(board: String(), count: Int(), creator: String(), description: String(), imageURL: String(), location: String(), time: String(), title: String())
    
    /// Holds all the friends of the current user.
    var friends = [User]()
    
    // MARK: - VIEW
    
    override func viewWillAppear(_ animated: Bool) {
        
        /* Navigation bar customization. */
        self.navigationController?.setNavigationBarHidden(false, animated: true) // Keeps the navigation bar unhidden.
        self.navigationItem.title = "Event Details" // Sets the title of the navigation bar.
        self.navigationController?.navigationBar.backItem?.title = "" // Keeps the back button a simple "<".
        self.navigationController?.navigationBar.tintColor = UIColor.white // Turns the contents of the navigation bar white.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateHeaderView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateHeaderView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerMaskLayer = CAShapeLayer()
        headerMaskLayer.fillColor = UIColor.black.cgColor
        headerView.layer.mask = headerMaskLayer
        
        updateHeaderView()
        
        /* Initialization of the friends collection view. */
//        friendsView.dataSource = self
//        friendsView.delegate = self
        
        self.setEventDetails()
        //self.setFriends()
    }
    
    func updateHeaderView() {
        
        let effectiveHeight = headerView.bounds.height - 25.0
        
        var headerRect = CGRect(x: 0, y: -effectiveHeight, width: detailsView.bounds.width, height: headerView.bounds.height)
        headerRect.size.height = 100.0
        
        headerRect.origin.y = effectiveHeight - 50.0
        headerRect.size.height = -effectiveHeight + 50.0
        
        headerView.frame = headerRect
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: headerRect.width, y: 0))
        path.addLine(to: CGPoint(x: headerRect.width, y: headerRect.height))
        path.addLine(to: CGPoint(x: 0, y: headerRect.height - 50.0))
        headerMaskLayer.path = path.cgPath
    }
    
    // MARK: - HELPERS
    
    /**
     *  Grabs the event image from the cache.
     */
    func downloadEventImage(imageURL: String) {
        
        /* We know the image is in the cache because the main board page handles caching. But for safety, we should check. */
        
        /// Holds the event image grabbed from the cache.
        if let img = BoardController.imageCache.object(forKey: imageURL as NSString) {
        
            /* SUCCESS: Loaded image from the cache. */
            
            self.eventImageView.image = img // Sets the event image to the one grabbed from the cache.
            
        } else {
            
            /* ERROR: Could not load the event image. */
            
            SCLAlertView().showError("Oh no!", subTitle: "Pluto had an internal error and couldn't load the event's image.")
        }
    }
    
    /**
     *
     *  Uses the event passed in from the main board screen to load the event details.
     */
    func setEventDetails() {
        
        self.downloadEventImage(imageURL: event.imageURL)
        
//        self.eventTitleLabel.text = event.title
//        self.eventLocationLabel.text = event.location
//        self.eventTimeLabel.text = event.time
//        self.eventDescriptionTextView.text = event.description
    }
    
    // MARK: - FIREBASE
    
    func setFriends() {
        
        DataService.ds.REF_CURRENT_USER.child("friends").observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.friends = []
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshot {
                    
                    if let friendDict = snap.value as? Dictionary<String, AnyObject> {
                        
                        let key = snap.key
                        let friend = User(friendKey: key, friendData: friendDict)
                        
                        if friend.connected == true {
                            
                            self.checkFriendEvent(friend: friend)
                        }
                    }
                }
            }            
        })
    }
    
    func checkFriendEvent(friend: User) {
        
        DataService.ds.REF_USERS.child(friend.friendKey).child("events").observeSingleEvent(of: .value, with: { (snapshot) in
         
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshot {
                    
                    if snap.key == self.event.title {
                        
                        self.friends.append(friend)
                    }
                }
            }
            
//            self.friendsView.reloadData()
        })
    }
    
    // MARK: - Helpers
    
    /**
     Switches to the view controller specified by the parameter.
     
     - Parameter controllerID: The ID of the controller to switch to.
     */
    func switchController(controllerID: String) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: controllerID) as UIViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showProfile" {
            
            
        }
    }
}

extension DetailController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return friends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let friendKey = friends[indexPath.row].friendKey
        
        self.performSegue(withIdentifier: "showProfile", sender: friendKey)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let friend = friends[indexPath.row]
        
        if let friendCell = collectionView.dequeueReusableCell(withReuseIdentifier: "friend", for: indexPath) as? FriendCell {
            
            friendCell.configureCell(friend: friend)
            return friendCell
            
        } else {
            
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 120, height: 120)
    }
}
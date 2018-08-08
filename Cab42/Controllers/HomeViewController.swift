//
//  HomeViewController
//  Cab42
//
//  Created by Andres Margendie on 23/07/2018.
//  Copyright © 2018 Margendie Consulting LDT. All rights reserved.
//
import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit
import MapKit
import CoreLocation
import FirebaseFirestore

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var trailingC: NSLayoutConstraint!
    @IBOutlet weak var leadingC: NSLayoutConstraint!
    
    @IBOutlet weak var profileButton: UIButton!
    
    @IBOutlet weak var ubeView: UIView!
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var tableView: UITableView!
    
    let cellIdentifier = "cellIdentifier"
    
    let db = Firestore.firestore()
    var listener : ListenerRegistration!
    
    var documents: [DocumentSnapshot] = []
    
    var groups = [Group]()
    var selectedGroup: Group?
    var user: User?
    
    var originPostalCode: String?
    var destinyPostalCode: String?

    var menuIsVisible = false
    let locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    
    var selectedPin:MKPlacemark? = nil
    
    let kHeaderSectionTag: Int = 6900;
    var expandedSectionHeaderNumber: Int = -1
    var expandedSectionHeader: UITableViewHeaderFooterView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingUpUserLocation()
        
        settingUpSearchBar()
        
        self.query = baseQuery()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.listener =  query?.addSnapshotListener { (documents, error) in
            guard let snapshot = documents else {
                print("Error fetching documents results: \(error!)")
                return
            }
            
            let results = snapshot.documents.map { (document) -> Group in
                if let group = Group(dictionary: document.data(), groupId: document.documentID) {
                    return group
                } else {
                    fatalError("Unable to initialize type \(Group.self) with dictionary \(document.data())")
                }
            }
            
            self.groups = results
            self.documents = snapshot.documents
            self.tableView.reloadData()
            
        }   }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func settingUpUserLocation(){
        self.map.showsUserLocation = true
        self.map.showsScale = true
        self.map.showsCompass = true
        map.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    private func settingUpSearchBar(){
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Ex: MK9 2FG"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = map
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    private func showMenu(){
        leadingC.constant = 250
        trailingC.constant = -250
        menuIsVisible = true
    }
    
    private func hideMenu(){
        leadingC.constant = 0
        trailingC.constant = 0
        menuIsVisible = false
    }
    
    @IBAction func mainMenuPressed(_ sender: Any) {
        if !menuIsVisible {
            self.showMenu()
        } else {
            self.hideMenu()
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }) { (animationComplete) in
            print("The animation is complete!")
        }
    }
    
    @IBAction func profileButtonPressed(_ sender: Any) {
        self.hideMenu()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is UserProfileViewController
        {
            let vc = segue.destination as? UserProfileViewController
            vc?.user = user
        }
    }
    
    @IBAction func changeMapType(_ sender: Any) {
        if map.mapType == MKMapType.standard {
            map.mapType = MKMapType.satellite
        } else {
            map.mapType = MKMapType.standard
        }
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            do {
                FBSDKAccessToken.setCurrent(nil)
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
                
                GIDSignIn.sharedInstance().signOut()
                
                try Auth.auth().signOut()
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login")
                present(vc, animated: true, completion: nil)
                
            } catch let error as NSError {
                print ("Error signing out: %@", error.localizedDescription)
            }
        }
    }
    
    @IBAction func refLocation(_ sender: Any) {
        locationManager.startUpdatingLocation()
    }
    
    @objc func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    fileprivate func baseQuery() -> Query {
        return Firestore.firestore().collection("groups").limit(to: 50)
    }
    
    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
            }
        }
    }
    
 
    
}

extension HomeViewController : CLLocationManagerDelegate {
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse || status == .authorizedAlways ){
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            return
            
        }
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {
            (placemarks, error) -> Void in
            
            if error != nil {
                print("Location Error!")
                return
            }
            
            if let pm = placemarks?.first {
                self.originPostalCode = pm.postalCode
                print("postalCode:::"+self.originPostalCode!)

            } else {
                print("error with data")
            }
        })
        
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        let location = locations.last! as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.map.setRegion(region, animated: true)
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("Error \(error)")
    }
}

extension HomeViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark

        print("placemark.addressDictionary:::: " + (placemark.addressDictionary?.description)!)
        
        self.destinyPostalCode = placemark.postalCode
        // clear existing pins
        var locality = ""
        if let _ = placemark.locality,
            let _ = placemark.administrativeArea {
            locality = "(" + placemark.locality! + "-" + placemark.administrativeArea! + ")"
        }
        let group = Group(destination:placemark.name!, locality: locality)
        group.location = placemark.coordinate
        let annotation = CreateGroupAnnotation(group: group)
        map.removeAnnotations(map.annotations)
        map.addAnnotation(annotation)
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        map.setRegion(region, animated: true)
    }
}

extension HomeViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }
        let reuseId = "CreateGroupAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? CreateGroupAnnotationView
        if pinView == nil {
            pinView = CreateGroupAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.groupDetailDelegate = self
            
        }
        return pinView
        
    }
    
    
    func mapView1(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        guard !(annotation is MKUserLocation) else { return nil }
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: [])
        button.addTarget(self, action: #selector(HomeViewController.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        
        //configureDetailView(annotationView: pinView!)
        
        return pinView
    }
    
}

extension HomeViewController : CreateGroupViewDelegate {
    func detailsRequestedForPerson(group: Group) {
        self.selectedGroup = group
        getDirections()
        //self.performSegue(withIdentifier: "Home", sender: nil)
        self.loadGroups()
    }
    
    func loadGroups(destiny: String = "") {
        self.db.collection("groups").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
}


extension HomeViewController : UITableViewDataSource, UITableViewDelegate {
    
    
    //Loads groups
    func numberOfSections(in tableView: UITableView) -> Int {
        if groups.count > 0 {
            tableView.backgroundView = nil
            return groups.count
        } else {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
            messageLabel.text = "Retrieving groups.\nPlease wait."
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .center;
            messageLabel.font = UIFont(name: "HelveticaNeue", size: 20.0)!
            messageLabel.sizeToFit()
            self.tableView.backgroundView = messageLabel;
        }
        return 0
        
        // return groups.count + 1
    }
    
    //Loads members by groups
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if (self.expandedSectionHeaderNumber == section) {
            return groups[section].members.count
        } else {
            return 0;
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            let group = groups[indexPath.section]
            
            let member = group.members[indexPath.row]
            
            cell.textLabel?.text = member.memberName
            cell.detailTextLabel?.text = String(member.passengers)
        return cell
    }
    
    
/*    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "headeCellIdentifier") as! CustomHeader
        
        if (section == 0){
            headerCell.textLabel?.text = "Groups"
            headerCell.detailTextLabel?.text = "Passengers"
            headerCell.backgroundColor =  UIColor(red:36/255,green:70/255,blue:100/255,alpha:0.9)
        }else{
            headerCell.textLabel?.text = groups[section-1].destination
            headerCell.detailTextLabel?.text = groups[section-1].maxPassengers
            headerCell.backgroundColor =  UIColor(red:72/255,green:141/255,blue:200/255,alpha:0.9)
            
        }
        
        return headerCell
        
    }*/
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (self.groups.count != 0) {
            return self.groups[section].destination
        }
        return ""
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0;
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0;
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        //recast your view as a UITableViewHeaderFooterView
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.colorWithHexString(hexStr: "#408000")
        header.textLabel?.textColor = UIColor.white
        
        if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
            viewWithTag.removeFromSuperview()
        }
        let headerFrame = self.view.frame.size
        let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 13, width: 18, height: 18));
        theImageView.image = UIImage(named: "Chevron-Dn-Wht")
        theImageView.tag = kHeaderSectionTag + section
        header.addSubview(theImageView)
        
        // make headers touchable
        header.tag = section
        let headerTapGesture = UITapGestureRecognizer()
        headerTapGesture.addTarget(self, action: #selector(HomeViewController.sectionHeaderWasTouched(_:)))
        header.addGestureRecognizer(headerTapGesture)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableViewExpandSection(_ section: Int, imageView: UIImageView) {
        let sectionData = self.groups[section]
        
        if (sectionData.members.count == 0) {
            self.expandedSectionHeaderNumber = -1;
            return;
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                imageView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.members.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.expandedSectionHeaderNumber = section
            self.tableView!.beginUpdates()
            self.tableView!.insertRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.tableView!.endUpdates()
        }
    }
    
    func tableViewCollapeSection(_ section: Int, imageView: UIImageView) {
        let sectionData = self.groups[section]
        
        self.expandedSectionHeaderNumber = -1;
        if (sectionData.members.count == 0) {
            return;
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                imageView.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.members.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.tableView!.beginUpdates()
            self.tableView!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.tableView!.endUpdates()
        }
    }
    
    @objc func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer) {
        let headerView = sender.view as! UITableViewHeaderFooterView
        let section    = headerView.tag
        let eImageView = headerView.viewWithTag(kHeaderSectionTag + section) as? UIImageView
        
        if (self.expandedSectionHeaderNumber == -1) {
            self.expandedSectionHeaderNumber = section
            tableViewExpandSection(section, imageView: eImageView!)
        } else {
            if (self.expandedSectionHeaderNumber == section) {
                tableViewCollapeSection(section, imageView: eImageView!)
            } else {
                let cImageView = self.view.viewWithTag(kHeaderSectionTag + self.expandedSectionHeaderNumber) as? UIImageView
                tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: cImageView!)
                tableViewExpandSection(section, imageView: eImageView!)
            }
        }
    }
}



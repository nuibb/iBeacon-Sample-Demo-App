/*
 * Copyright (c) 2017 Razeware LLC
 */

import UIKit
import CoreLocation
import Foundation
import AVFoundation
import CoreData



class ItemsViewController: UIViewController,AddBeacon,CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource{
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var alarmButton: UIButton!
    
    var timer : Timer!
    var flag = false
    var unknownFlag = false
    
    var status = 1
    var idKey = 0
    var idKey1 = 0
    var idKey2 = 0
    var idKey3 = 0
    
    var dist1 = Float()
    var dist2 = Float()
    var dist3 = Float()
    
    var uuidKey = 0
    var dataDictionary = [String : String]()
    var distance : [String] = [""]
    let storedItemsKey = "storedItems"
    var alrmOffFlag = true
    var showAlartFlag = true
    var hideAlartFlag =  true
    let systemSoundID: SystemSoundID = 4095
    var unknownCount = 0
    var documentURLtoShowPDF : URL?
    var pdfDownloader = FileDownloader()
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView()
    var customAlertController = AlertController.sharedInstance
    let locationManager = CLLocationManager()
    var items = [Item]()
    
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        loadItems()
        setupActivityIndicator()
        alarmButton.isHidden = true
        
          //  save()
         //  fetch()
    }
    
    
    func save() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "BeaconInfo", in: managedContext)
        let users = NSManagedObject(entity: entity!, insertInto: managedContext)
        users.setValue("sdfgdgertygre", forKey: "uuid")
        users.setValue("10m", forKey: "distance")
        users.setValue("1", forKey: "idKey")
        do {
            try managedContext.save()
        } catch let error as NSError{
            print("\(error) : save failed")
        }
    }
    
    func fetch() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSManagedObject>(entityName : "BeaconInfo")
        do {
            let results = try managedContext.fetch(request)
            print("result \(results)")
        } catch let error as NSError{
            print("\(error) : save failed")
        }
        
    }
    
    func setupActivityIndicator() {
        
        activityIndicator.center = self.view.center
        activityIndicator.frame.size = CGSize(width:80,height:80)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center =  CGPoint(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height/2)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.backgroundColor = UIColor.gray
        view.addSubview(activityIndicator)
    }
    
    func addBeacon(item: Item) {
        
        items.append(item)
        tableView.beginUpdates()
        let newIndexPath = IndexPath(row: items.count - 1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
        tableView.endUpdates()
        startMonitoringItem(item)
        persistItems()
    }
    
    func loadItems() {
        
        guard let storedItems = UserDefaults.standard.array(forKey: storedItemsKey) as? [Data] else { return }
        for itemData in storedItems {
            guard let item = NSKeyedUnarchiver.unarchiveObject(with: itemData) as? Item else { continue }
            items.append(item)
            startMonitoringItem(item)
            
        }
    }
    
    func persistItems() {
        
        var itemsData = [Data]()
        for item in items {
            let itemData = NSKeyedArchiver.archivedData(withRootObject: item)
            itemsData.append(itemData)
        }
        UserDefaults.standard.set(itemsData, forKey: storedItemsKey)
        UserDefaults.standard.synchronize()
    }
    
    
    func startMonitoringItem(_ item: Item) {
        
        let beaconRegion = item.asBeaconRegion()
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
        
    }
    
    func stopMonitoringItem(_ item: Item) {
        
        let beaconRegion = item.asBeaconRegion()
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(in: beaconRegion)
    }
    
    
    func downloadFile(){
        
        if (currentReachabilityStatus != .reachableViaWiFi) //not connected
        {
            self.present(self.customAlertController.getCustomAlertWithOkayButton(title: "Alert!", msg: "Please connect to your Wifi ", handler: {
            }), animated: true, completion: nil)
            
        } else {
            // Create destination URL
            let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
            let destinationFileUrl = documentsUrl.appendingPathComponent("downloadedFile.pdf") as URL?
            // check if file is exist or not in destination url.
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let url = URL(fileURLWithPath: path)
            let filePath = url.appendingPathComponent("downloadedFile.pdf").path
            let fileManager = FileManager.default
            // check file in file path
            if fileManager.fileExists(atPath: filePath) {
                
                documentURLtoShowPDF = destinationFileUrl //append content url to pass url for load in webview
                //  print("file saved in : \(filePath)")
                let detailMessage = "File Already Downloaded."
                let fileExistAlart = UIAlertController(title: "Details", message: detailMessage, preferredStyle: .alert)
                fileExistAlart.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action) in
                    self.performSegue(withIdentifier: "epubVC", sender: nil)
                }))
                self.present(fileExistAlart, animated: true, completion: nil)
                
            } else {
                //print("FILE NOT AVAILABLE")
                // download file from server.
                activityIndicator.startAnimating()
                self.view.isUserInteractionEnabled = false
                let fileRUL = "http://unec.edu.az/application/uploads/2014/12/pdf-sample.pdf"
                pdfDownloader.downloadFileFromServer(url:fileRUL , parameter: "") { (responseURL) in
                    //print("temp url is : \(responseURL)")
                    
                    do {
                        try FileManager.default.copyItem(at: responseURL, to: destinationFileUrl!)
                        self.documentURLtoShowPDF = destinationFileUrl
                        DispatchQueue.main.sync {
                            self.activityIndicator.stopAnimating()
                            self.view.isUserInteractionEnabled = true
                        }
                        self.performSegue(withIdentifier: "epubVC", sender: nil)
                       // print("file location : \(String(describing: self.documentURLtoShowPDF!))")
                    } catch (let writeError) {
                        print("Error creating a file \(String(describing: destinationFileUrl)) : \(writeError)")
                    }
                }
            }
        }
    }
    
    
    
    @IBAction func alarmButtonPressed(_ sender: Any) {
          //alrmOffFlag = false
          // AudioServicesDisposeSystemSoundID(systemSoundID)
          //alarmButton.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueAdd", let viewController = segue.destination as? AddItemViewController {
            viewController.delegate = self
        } else if segue.identifier == "epubVC" {
            let epubVC = segue.destination as? EpubViewController
            epubVC?.fileLocation = documentURLtoShowPDF
            
        }
    }
    
    


// MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // print("items count :\(items.count)")
        return items.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath) as! ItemCell
        cell.statusIconButton.setBackgroundImage(UIImage(named:"button_04.png"), for: .normal)
        cell.item = items[indexPath.row]
        let item = items[indexPath.row]
        let itemLocation = item.locationString()
        let locationName    = itemLocation.components(separatedBy:" ")
        let name = locationName[1].lowercased()
        let _ = "uuid is \(items[indexPath.row].uuid)MA\(items[indexPath.row].majorValue)"
       // print(description1)
        if name == "unknown"{
            unknownCount += 1
            if unknownCount == items.count {
                UserDefaults.standard.set(0, forKey: "unknownStateTrack")  //Integer
                //UserDefaults.setValue(1, forKey: "unknownStateTrack")
                //()
            }
        }

        
         return cell
    }
   
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x:0 ,y: 0, width :self.view.layer.bounds.size.width - 50 , height :50))
        let label = UILabel(frame: CGRect(x:20 ,y: 0, width :self.view.layer.bounds.size.width - 50 , height :50))
        label.font = UIFont.systemFont(ofSize: 24)
        label.text = "Beacons around you"
        label.textAlignment = .center
        label.textColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        view.backgroundColor = UIColor.init(red: 81/255, green: 195/255, blue: 179/255, alpha: 1)
        view.addSubview(label)
        return view
        
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Beacons around you"
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 50
        
    }
    

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            tableView.beginUpdates()
            items.remove(at: indexPath.row)
            //print("index for delete : \(indexPath.row)")
           // stopMonitoringItem(items[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            persistItems()
        }
    }

// MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = items[indexPath.row]
        let itemName = item.name
        let itemLocation = item.locationString()
        let fullName    = itemLocation
        let fullNameArr = fullName.components(separatedBy: ":")
        let name    = fullNameArr[1]
        let detailMessage = "\(itemName) is \(name) away from you.Do you want to download Content for this ?"
        let detailAlert = UIAlertController(title: "Details", message: detailMessage, preferredStyle: .alert)
        detailAlert.addAction(UIAlertAction(title: "Download", style: .default, handler:
            {(ACTION) in
                self.downloadFile()
        }
        ))
        detailAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(detailAlert, animated: true, completion: nil)
        
        
    }
    

// MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        
        print("Failed monitoring region: \(error.localizedDescription)")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Location manager failed: \(error.localizedDescription)")
    }
    
 
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard region is CLBeaconRegion else { return }
        
     //   let img = UIImage(named: "alarmON")
   //     alarmButton.setImage(img , for: .normal)
    //    alarmButton.isHidden = false
    //    AudioServicesPlaySystemSound (systemSoundID)
    //    alrmOffFlag = false
       
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        // Find the same beacons in the table.
        var indexPaths = [IndexPath]()
        for beacon in beacons {
            
            var count = 0
            status = 1
            for row in 0..<items.count {
               // print("item array loc str :\(items[row].locationString())")
                let locationName = items[row].locationString().components(separatedBy:" ")
                if String(describing: locationName[1]) != "Unknown" {
                    //print("loc name \(locationName[3])")
                   distance = locationName[3].components(separatedBy: "m)")
                   // print("distance is \(distance[0])")
                  //  let description = "uuid is \(items[row].uuid) major \(items[row].majorValue) and minor \(items[row].minorValue)  and distance \(distance[0])"
                    let identificationKey = "\(items[row].uuid)MA\(items[row].majorValue)"
                    
                    print("items name = \(identificationKey)")
                    
                        if identificationKey == "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0M10" {//MOBIO TV
                        idKey1 = 1
                        uuidKey = idKey
                        dist1 = Float(distance[0])!

                   } else if identificationKey == "E3726B6E-E198-4869-9329-765A368CF074MA10"{ // 6 plus
                        idKey2 = 2
                        uuidKey = idKey
                        dist2 = Float(distance[0])!
                    }
                    else if identificationKey == "3913C10E-AFAB-4F44-B50F-84E8B02F13C0MA10"{ // 7 plus
                        idKey3 = 3
                        uuidKey = idKey
                        dist3 = Float(distance[0])!
                    }
                    _ = Float(distance[0])!
                    // dataDictionary[identificationKey] = beaconDistance
                    // print("key : \(uuidKey),distance : \(beaconDistance)\n\n")
                    
                    if flag == false {
                        flag = true
                        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(sendDataIntoWeb), userInfo: nil, repeats: true)
                        // sendDataIntoWeb()
                    }
                    
                    
                }
                
                let newName  = locationName[1].lowercased()
                if newName == "unknown" {
                    count += 1
                    //
                }
                if (UserDefaults.standard.integer(forKey:"unknownStateTrack") == 0) && count == items.count{
                    //print(" 0 checked ")
                    alarmButton.isHidden = true
                    AudioServicesDisposeSystemSoundID(systemSoundID)
                    alrmOffFlag = true
                    
                } else if (UserDefaults.standard.integer(forKey:"unknownStateTrack") == 1) && count == items.count {
                     //print(" 1 checked ")
                    if alrmOffFlag {
                        timer.invalidate()
                        status = 0
                        flag = false
                        sendDataIntoWeb()
                      //  print(" 1 checked flag ")
                        let img = UIImage(named: "alarmON")
                        alarmButton.setImage(img , for: .normal)
                        alarmButton.isHidden = false
                        AudioServicesPlaySystemSound (systemSoundID)
                        alrmOffFlag = false
                    }
                   
                } else {
                    alarmButton.isHidden = true
                    AudioServicesDisposeSystemSoundID(systemSoundID)
                    alrmOffFlag = true
                }
                // TODO: Determine if item is equal to ranged beacon
                if items[row] == beacon {
                    items[row].beacon = beacon
                    indexPaths += [IndexPath(row: row, section: 0)]
                   
                }
            }
               //print("data dictionary is \(dataDictionary)")
        }

        // Update beacon locations of visible rows.
        if let visibleRows = tableView.indexPathsForVisibleRows {
            let rowsToUpdate = visibleRows.filter { indexPaths.contains($0)}

            for row in rowsToUpdate {
                let cell = tableView.cellForRow(at: row) as! ItemCell
                cell.refreshLocation()
            }
           
        }
        
    }
    
    
    @objc func sendDataIntoWeb() {
        
        print("\n\n\nmethod call")
        
        let jsonCall = APICall()
        let jsonparameter = "beacon_id=\(idKey1)&distance=\(dist1)&status=\(status)"
        let jsonparameter1 = "beacon_id=\(idKey3)&distance=\(dist3)&status=\(status)"
        let jsonparameter2 = "beacon_id=\(idKey2)&distance=\(dist2)&status=\(status)"
        print("parametres 1: \(jsonparameter) ,2 :  \(jsonparameter1) ,3 : \(jsonparameter2)")
    
       
        // old url "http://192.168.1.194:8002/api/beacon_position/?"
        
        jsonCall.getDataFromJson1(url: "http://192.168.1.184:8001/api/beacon_position/", parameter: jsonparameter ) { (response) in
            
            print("response 1 \(response)")
        }
        
        jsonCall.getDataFromJson1(url: "http://192.168.1.184:8001/api/beacon_position/", parameter: jsonparameter2 ) { (response) in
            
             print("response 2 \(response)")

        }
        
        jsonCall.getDataFromJson1(url: "http://192.168.1.184:8001/api/beacon_position/", parameter: jsonparameter1 ) { (response) in
            print("response 3 \(response)")

        }
        
    
    }
   
    
}







/*
 * Copyright (c) 2017 Razeware LLC
 */

import UIKit
import AVFoundation


class ItemCell: UITableViewCell {
  
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var statusIconButton: UIButton!
    
    var withinRangeSoundFlag : Bool =  true
    var liveItems = [Item]()
    
    var item: Item? = nil {
        didSet {
            if let item = item {
                imgIcon.image = Icons(rawValue: item.icon)?.image()
                lblName.text = item.name
                lblLocation.text = item.locationString()
                
            } else {
                imgIcon.image = nil
                lblName.text = ""
                lblLocation.text = ""
                statusIconButton.setBackgroundImage(UIImage(named:"button_04.png"), for: .normal)
            }
        }
    }
  
    
    func refreshLocation(){
    
        lblLocation.text = item?.locationString() ?? ""
        let locationNameWithDistance = lblLocation.text?.components(separatedBy:" ")
        let location = locationNameWithDistance![1]
        if location == "Immediate"||location == "Near"||location == "Far" {
            UserDefaults.standard.set(1, forKey: "unknownStateTrack")
            let longDistance = locationNameWithDistance![3]
            let distance = longDistance.components(separatedBy:"m")
            let processDistance = distance[0]
            let finalDistance = Double(processDistance)
            switch finalDistance! {
            case 0.00 ..< 75.00 :
                if withinRangeSoundFlag{
                    let systemSoundID: SystemSoundID = 1100
                    AudioServicesPlaySystemSound (systemSoundID)
                    withinRangeSoundFlag = false
                   }
            default:
                print("out of range")
            }
        }
        
        statusIconButton.isHidden = false
        
        switch location {
            
        case "Immediate":
            statusIconButton.setBackgroundImage(UIImage(named:"button_01.png"), for: .normal)
            
        case "Near":
            statusIconButton.setBackgroundImage(UIImage(named:"button_02.png"), for: .normal)
           
        case "Far":
            statusIconButton.setBackgroundImage(UIImage(named:"button_03.png"), for: .normal)
            
        default:
            statusIconButton.setBackgroundImage(UIImage(named:"button_04.png"), for: .normal)
            withinRangeSoundFlag = true
        
        }
        
    }
    
}


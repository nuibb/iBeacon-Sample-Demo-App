/*
 * Copyright (c) 2017 Razeware LLC
 */

import Foundation
import UIKit


enum Icons: Int {
    
    case computer = 0
    case house1
    case mobile1
    case house2
    case mobile2
    case house3
    case mobile3
    case wallet
    case bag
    
    func image() -> UIImage? {
        return UIImage(named: "\(self.name())")
    }
    
    func name() -> String {
        switch self {
        case .computer: return "computer"
        case .house1: return "house1"
        case .mobile1: return "mobile1"
        case .house2: return "house2"
        case .mobile2: return "mobile2"
        case .house3: return "house3"
        case .mobile3: return "mobile3"
        case .wallet: return "Icon_Wallet"
        case .bag: return "Icon_Bag"
        }
    }
    
    static func icon(forTag tag: Int) -> Icons {
        
        return Icons(rawValue: tag) ?? .bag
    }
    
    static let allIcons: [Icons] = {
        
        var all = [Icons]()
        var index: Int = 0
        while let icon = Icons(rawValue: index) {
            all += [icon]
            index += 1
        }
        return all.sorted { $0.rawValue < $1.rawValue }
    }()
    
}

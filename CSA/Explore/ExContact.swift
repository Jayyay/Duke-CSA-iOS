//
//  ExContact.swift
//  Duke CSA
//
//  Created by Zhe Wang on 5/13/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class ExContact: NSObject {
    let PFInstance:PFUser
    var netID_pivot:Character = "-"
    var netID_letterReverse:String = "zzzz"
    var netID_number:String = "9999"
    var gender:String = ""
    var year:String = ""
    var major:String = ""
    var minor:String = ""
    var realName:String = ""
    var displayName:String = ""
    var netID:String = ""
    
    init?(user u:PFUser){
        PFInstance = u
        super.init()
        if let isValid = u[PFKey.IS_VALID] as? Bool {
            if !isValid {
                return nil
            }
        }else {
            return nil
        }
        if let g = u[PFKey.USER.GENDER] as? String {
            gender = g
        }else {
            return nil
        }
        if let y = u[PFKey.USER.WHICH_YEAR] as? String {
            year = y
        }else {
            return nil
        }
        if let m = u[PFKey.USER.MAJOR] as? String {
            major = m
        }else {
            return nil
        }
        if let m = u[PFKey.USER.MINOR] as? String {
            minor = m
        }else {
            return nil
        }
        if let r = u[PFKey.USER.REAL_NAME] as? String {
            realName = r
        }else {
            return nil
        }
        if let d = u[PFKey.USER.DISPLAY_NAME] as? String {
            displayName = d
        }else {
            return nil
        }
        if let n = u[PFKey.USER.NET_ID] as? String {
            netID = n
        }else {
            return nil
        }
        if AppTools.netIDIsValid(netID) {
            makeNetIDPivot()
        }
    }
    
    func makeNetIDPivot(){
        let nid = netID.lowercaseString
        //seperate letters and numbers and store them
        var letterStr, numberStr:String
        var letterStart:String.Index! = nil, letterEnd:String.Index! = nil
        var numberStart:String.Index! = nil, numberEnd:String.Index! = nil
        //letter part
        var index = nid.startIndex
        while index != nid.endIndex {
            if "a"<=nid[index] && nid[index]<="z" {
                letterStart = index
                break
            }
            index = index.successor()
        }
        index = nid.endIndex.predecessor()
        while index != nid.startIndex {
            if "a"<=nid[index] && nid[index]<="z" {
                letterEnd = index
                break
            }
            index = index.predecessor()
        }
        if letterEnd == nil{
            letterEnd = nid.startIndex
        }
        letterStr = nid.substringWithRange(letterStart...letterEnd)
        
        //number part
        index = nid.startIndex
        while index != nid.endIndex {
            if "0"<=nid[index] && nid[index]<="9" {
                numberStart = index
                break
            }
            index = index.successor()
        }
        if numberStart == nil {//this netID has no number in it
            numberStr = ""
        } else {
            index = nid.endIndex.predecessor()
            while index != nid.startIndex {
                if "0"<=nid[index] && nid[index]<="9" {
                    numberEnd = index
                    break
                }
                index = index.predecessor()
            }
            numberStr = nid.substringWithRange(numberStart...numberEnd)
        }
        //reverseString
        var letterStr_reverse = ""
        for c in letterStr.characters {
            letterStr_reverse = String(c) + letterStr_reverse
        }
        (netID_letterReverse, netID_number) = (letterStr_reverse, numberStr)
        netID_pivot = netID_letterReverse[netID_letterReverse.startIndex]
    }
}

//
//  Message.swift
//  SMS Collection
//
//  Created by Sumit on 23/07/2018.
//  Copyright © 2018 Sumit. All rights reserved.
//

import Foundation



struct Message {
    
    var id : Int
    var categoryID : Int
    var smsText : String
    var isDeleted : Bool
    var isFavourite : Bool
    var createdDate : String
    var isActive : Bool
    var createdBy : Int
   
   
}

struct SMSCategory {
    var categoryID : Int
    var categoryName : String
    var isActive : Bool
    var isDeleted : Bool
    var createdDate : String
    var lastUpdated : String
    
   
}


struct Users {
    
    var userID : Int
    var userName : String
    var isActive : Bool
    var mobileNumber : Int
    var email : String
}

struct Favourites {
    
     var favId : Int
     var smsID : Int
     var userID : Int
    var favouriteDate : String

    
}


















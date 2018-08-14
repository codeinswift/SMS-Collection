    //
    //  ViewController.swift
    //  SMS Collection
    //
    //  Created by Sumit on 23/07/2018.
    //  Copyright © 2018 Sumit. All rights reserved.
    //

    import UIKit

    class ViewController: UIViewController {

        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("part2.sqlite")
        
        var db: SQLiteDatabase?
        var messagesArray : [Message] = []

        
        override func viewDidLoad() {
            super.viewDidLoad()
            databaseStart()

            let isTablesCreated = UserDefaults.standard.bool(forKey: "isTablesCreated")
            print("value of table created \(isTablesCreated)")

            if (!isTablesCreated){
                tablecreation()
                messagesArray = populateMessages()
                print("populated")
                print("try inserting")
                insertMessages(messages: messagesArray)
                //setting user default to true
                UserDefaults.standard.set(true,forKey: "isTablesCreated")
            }
            
           
        }

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }


        
        func databaseStart(){
            let part1DbPath = fileURL.path
            do {
                db = try SQLiteDatabase.open(path: part1DbPath)
                print("Successfully opened connection to database.")
            } catch SQLiteError.OpenDatabase(let message) {
                print("Unable to open database. Verify that you created the directory. \(message)")
            }catch {
                // Catch any other errors
            }
            
        }
        
        func tablecreation(){
            do {
                try db!.createTable(table: Message.self)
            } catch {
                print(db.debugDescription)
            }
        
       
        do {
        try db!.createTable(table: SMSCategory.self)
        } catch {
        print(db.debugDescription)
        }
        
        do {
        try db!.createTable(table: Users.self)
        } catch {
        print(db.debugDescription)
        }
        
        do {
        try db!.createTable(table: Favourites.self)
        } catch {
        print(db.debugDescription)
        }
        
        
        }

        
        func tabledeletion(){
            
            do {
                try db!.dropTable(table: Message.self)
            } catch {
                print(db.debugDescription)
            }
            
            
            do {
                try db!.dropTable(table: SMSCategory.self)
            } catch {
                print(db.debugDescription)
            }
            
            do {
                try db!.dropTable(table: Users.self)
            } catch {
                print(db.debugDescription)
            }
            
            do {
                try db!.dropTable(table: Favourites.self)
            } catch {
                print(db.debugDescription)
            }
            
        }
        
        func insertMessages(messages : [Message]){
            print("inserting in vc")
            for message in messages{
                
                do {
                    try db!.insertMessages(message: message)

                } catch {
                    print(db.debugDescription)
                }
                
            }
        }
    }

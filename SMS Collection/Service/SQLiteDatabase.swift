    //
    //  SQLiteDatabase.swift
    //  SMS Collection
    //
    //  Created by Sumit on 25/07/2018.
    //  Copyright © 2018 Sumit. All rights reserved.
    //

    import Foundation
    import SQLite3


    enum SQLiteError: Error {
        case OpenDatabase(message: String)
        case Prepare(message: String)
        case Step(message: String)
        case Bind(message: String)
    }

    //Wrapping the Database Connection
    class SQLiteDatabase {
        
        // C Pointer to Database
        fileprivate let dbPointer: OpaquePointer?
        
        // Initialise pointer
        fileprivate init(dbPointer: OpaquePointer?) {
            self.dbPointer = dbPointer
        }
        
        //De-initialise Pointer
        deinit {
            sqlite3_close(dbPointer)
        }

        
        // Handling Error Message returned by Pointer
        fileprivate var errorMessage: String {
            if let errorPointer = sqlite3_errmsg(dbPointer) {
                let errorMessage = String(cString: errorPointer)
                return errorMessage
            } else {
                return "No error message provided from sqlite."
            }
        }
        
        
        //Mark:- Opening the database
        static func open(path: String) throws -> SQLiteDatabase {
            var db: OpaquePointer? = nil
            // 1
            if sqlite3_open(path, &db) == SQLITE_OK {
                // 2
                return SQLiteDatabase(dbPointer: db)
            } else {
                // 3
                defer {
                    if db != nil {
                        sqlite3_close(db)
                    }
                }
                
                if let errorPointer = sqlite3_errmsg(db) {
                    let message = String.init(cString: errorPointer)
                    throw SQLiteError.OpenDatabase(message: message)
                } else {
                    throw SQLiteError.OpenDatabase(message: "No error message provided from sqlite.")
                }
            }
        }
        
        
        
        
        
        
        
    }


    extension SQLiteDatabase {
        
        // Make a Prepare statement from a sql string.
        func prepareStatement(sql: String) throws -> OpaquePointer? {
            var statement: OpaquePointer? = nil
            guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
                print("error")
                throw SQLiteError.Prepare(message: errorMessage)
            }
            
            return statement
        }
        
        // Create a table from the given Model type create statement
        func createTable(table: SQLTable.Type) throws {
            // 1
            let createTableStatement = try prepareStatement(sql: table.createStatement)
            // 2
            defer {
                sqlite3_finalize(createTableStatement)
            }
            // 3
            guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
                throw SQLiteError.Step(message: errorMessage)
            }
            print("\(table) table created.")
        }
        
       
        // drop table
        func dropTable(table: SQLTable.Type) throws {
            // 1
            let dropTableStatement = try prepareStatement(sql: table.dropStatement)
            // 2
            defer {
                sqlite3_finalize(dropTableStatement)
            }
            // 3
            guard sqlite3_step(dropTableStatement) == SQLITE_DONE else {
                throw SQLiteError.Step(message: errorMessage)
            }
            print("\(table) table deleted.")
        }
        
        
        
        func insertMessages(message : Message) throws  {
            print("inserting in db")
            let insertSQLQuery =  """
                                    Insert into Message(categoryID, smsText, isDeleted, isFavourite, createdDate, isActive, createdBy) VALUES (?,?,?,?,?,?,?);
                                    """
            let insertStatement = try prepareStatement(sql: insertSQLQuery)
            print(insertStatement)
            defer {
                sqlite3_finalize(insertStatement)
            }
            
            let categoryID = message.categoryID
            let smstext = message.smsText as NSString
            let isDeleted = message.isDeleted ? 1 : 0
            let isFavourite = message.isFavourite ? 1 : 0
            let createdDate = message.createdDate as NSString
            let isActive = message.isActive ? 1 : 0

            print(categoryID, smstext, createdDate, isDeleted,isFavourite,isActive)
            
                guard sqlite3_bind_int(insertStatement, 1, Int32(categoryID)) == SQLITE_OK &&
                    sqlite3_bind_text16(insertStatement, 2, smstext.utf8String, -1, nil) == SQLITE_OK &&
                    sqlite3_bind_int(insertStatement, 3, Int32(isDeleted)) == SQLITE_OK &&
                    sqlite3_bind_int(insertStatement, 4, Int32(isFavourite)) == SQLITE_OK &&
                    sqlite3_bind_text16(insertStatement, 5, createdDate.utf8String, -1, nil) == SQLITE_OK &&
                    sqlite3_bind_int(insertStatement, 6, Int32(isActive)) == SQLITE_OK   else {
                   
                        print(errorMessage.debugDescription)
                        throw SQLiteError.Bind(message: errorMessage)
                        
                }
            
           guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            print(errorMessage.debugDescription)

                throw SQLiteError.Step(message: errorMessage)
            }
            
            print("Successfully inserted row.")

            
        }
        
    }

    //Protocol to create sql table for an Model
    protocol SQLTable {
        static var createStatement: String { get }
        static var dropStatement : String {get}
    }

    //implementing above protocol
    extension Message : SQLTable {
        static var createStatement: String {
            return """
            CREATE TABLE Message(
            Id INTEGER PRIMARY KEY AUTOINCREMENT,
            CategoryID INTEGER,
            smsText TEXT,
            Author TEXT,
            isDeleted INTEGER,
            isFavourite INTEGER,
            createdDate TEXT,
            isActive INTEGER,
            createdBy TEXT
            );
            """
        }
        static var dropStatement : String {
            return " drop table Message"
    }
        
        
    }
    extension SMSCategory : SQLTable {
        static var createStatement: String {
            return """
            CREATE TABLE SMSCategory(
            categoryID INTEGER PRIMARY KEY NOT NULL,
            categoryName TEXT,
            isActive INTEGER,
            isDeleted INTEGER,
            createdDate TEXT,
            lastUpdated TEXT
            );
            """
        }
        static var dropStatement : String {
            return " drop table SMSCategory"
        }
    }

    extension Users : SQLTable {
        static var createStatement: String {
            return """
            CREATE TABLE Users(
            userID INTEGER PRIMARY KEY NOT NULL,
            userName TEXT,
            isActive INTEGER,
            mobileNumber INTEGER,
            email TEXT
            );
            """
        }
        static var dropStatement : String {
            return " drop table Users"
        }
    }

    extension Favourites : SQLTable {
        static var createStatement: String {
            return """
            CREATE TABLE Favourites(
            favId INTEGER,
            smsID INTEGER,
            userID INTEGER,
            favouriteDate TEXT
            );
            """
        }
        
        static var dropStatement : String {
            return " drop table Favourites"
        }
    }



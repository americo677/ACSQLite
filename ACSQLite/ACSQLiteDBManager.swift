//
//  ACSQLiteDBManager.swift
//  ACSQLite
//
//  Created by Américo José Cantillo Gutiérrez on 2/7/19.
//  Copyright © 2019 Américo José Cantillo Gutiérrez. All rights reserved.
//

import Foundation
import SQLite3

enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
}

protocol SQLTable {
    static var createStatement: String { get }
    static var qrySQLStatement: String { get }
    static var insSQLStatement: String { get }
    static var updSQLStatement: String { get }
    static var delSQLStatement: String { get }
}

protocol DAOManager {
    
    associatedtype T
    typealias ContentValues = Dictionary
    typealias ContentTypes  = Dictionary

    mutating func save()
    
    mutating func update<T>(object: T)
    
    mutating func delete<T>(object: T)
    
    mutating func getAll<T>() -> [T]
    
    //mutating func getSome<T>(projection: [String], values: ContentValues<String, Any>, filterType: ContentTypes<String, Any>, orderBy: [String]) -> [T]
    
    mutating func getBy<T>(id: Int32) -> T?
}


class ACSQLiteDBManager {
    
    fileprivate let db: OpaquePointer?
    var stmt: OpaquePointer?
    var dbName: String?
    
    fileprivate var errorMessage: String {
        if let errorPointer = sqlite3_errmsg(db) {
            let errorMessage = String(cString: errorPointer)
            return errorMessage
        } else {
            return "No error message provided from sqlite."
        }
    }
    
    fileprivate init(db: OpaquePointer?) {
        self.db = db
    }
    
    deinit {
        sqlite3_close(self.db)
    }

    func errMessage() -> String {
        return errorMessage
    }
    
    static func open(name: String) throws -> ACSQLiteDBManager {
        var db: OpaquePointer?
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(name + ".db")
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
            print("Database path: \(fileURL.path)")
            return ACSQLiteDBManager(db: db)
        } else {
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

extension ACSQLiteDBManager {
    func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        return statement
    }
}

extension ACSQLiteDBManager {
    func createTable(table: SQLTable.Type) throws {
        let createTableStatement = try prepareStatement(sql: table.createStatement)
        defer {
            sqlite3_finalize(createTableStatement)
        }
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        print("Tabla \(table) creada.")
    }
}

extension ACSQLiteDBManager {
    func insTarea(tarea: Tarea) throws {
        let insertStatement = try prepareStatement(sql: Tarea.insSQLStatement)
        defer {
            sqlite3_finalize(insertStatement)
        }
        
        let name: NSString = tarea.name! as NSString
        guard /*sqlite3_bind_int(insertStatement, 1, tarea.id) == SQLITE_OK  && */
              sqlite3_bind_text(insertStatement, 1, name.utf8String, -1, nil) == SQLITE_OK &&
              sqlite3_bind_double(insertStatement, 2, tarea.started!.timeIntervalSinceReferenceDate) == SQLITE_OK &&
              sqlite3_bind_double(insertStatement, 3, tarea.finished!.timeIntervalSinceReferenceDate) == SQLITE_OK &&
              sqlite3_bind_int(insertStatement, 4, tarea.elapsed!) == SQLITE_OK &&
              sqlite3_bind_int(insertStatement, 5, tarea.status!) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: errorMessage)
        }
        
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        print("Successfully inserted row.")
    }
}

extension ACSQLiteDBManager {
    func updTarea(tarea: Tarea) throws {
        let updateStatement = try prepareStatement(sql: Tarea.updSQLStatement)
        defer {
            sqlite3_finalize(updateStatement)
        }
        
        let name: NSString = tarea.name! as NSString
        guard /*sqlite3_bind_int(insertStatement, 1, tarea.id) == SQLITE_OK  && */
            sqlite3_bind_text(updateStatement, 1, name.utf8String, -1, nil) == SQLITE_OK &&
                sqlite3_bind_double(updateStatement, 2, tarea.started!.timeIntervalSinceReferenceDate) == SQLITE_OK &&
                sqlite3_bind_double(updateStatement, 3, tarea.finished!.timeIntervalSinceReferenceDate) == SQLITE_OK &&
                sqlite3_bind_int(updateStatement, 4, tarea.elapsed!) == SQLITE_OK &&
                sqlite3_bind_int(updateStatement, 5, tarea.status!) == SQLITE_OK &&
                sqlite3_bind_int(updateStatement, 6, tarea.id!) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: errorMessage)
        }
        
        guard sqlite3_step(updateStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        print("Successfully updated row.")
    }
}

extension ACSQLiteDBManager {
    func delTarea(tarea: Tarea) throws {
        let deleteStatement = try prepareStatement(sql: Tarea.delSQLStatement)
        defer {
            sqlite3_finalize(deleteStatement)
        }
        
        guard sqlite3_bind_int(deleteStatement, 1, tarea.id!) == SQLITE_OK else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        
        guard sqlite3_step(deleteStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        print("Successfully deleted row.")
    }
}

extension ACSQLiteDBManager {
    func qryTarea(tarea: Tarea) throws -> [Tarea]? {
        
        var results = [Tarea]()
        
        let queryStatement = try prepareStatement(sql: Tarea.qrySQLStatement)
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        while sqlite3_step(queryStatement) == SQLITE_ROW {
            
            var id: Int32 = 0
            var name: String = ""
            var started: Date = Date()
            var finished: Date = Date()
            var elapsed: Int32 = 0
            var status: Int32 = 0

            if sqlite3_column_type(queryStatement, 0) != SQLITE_NULL {
                id = sqlite3_column_int(queryStatement, 0)
            }
            
            if sqlite3_column_type(queryStatement, 1) != SQLITE_NULL {
                if let cString = sqlite3_column_text(queryStatement, 1) {
                    name = String(cString: cString)
                }
            }

            if sqlite3_column_type(queryStatement, 2) != SQLITE_NULL {
                started = Date(timeIntervalSinceReferenceDate: sqlite3_column_double(queryStatement, 2))
            }

            if sqlite3_column_type(queryStatement, 3) != SQLITE_NULL {
                finished = Date(timeIntervalSinceReferenceDate: sqlite3_column_double(queryStatement, 3))
            }

            if sqlite3_column_type(queryStatement, 4) != SQLITE_NULL {
                elapsed = sqlite3_column_int(queryStatement, 4)
            }

            if sqlite3_column_type(queryStatement, 5) != SQLITE_NULL {
                status = sqlite3_column_int(queryStatement, 5)
            }

            let tarea = Tarea(id: id, name: name, started: started, finished: finished, elapsed: elapsed, status: status)
            
            results.append(tarea)
        }

        print("Successfully fetched rows.")

        return results
        
    }
}

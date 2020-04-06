//
//  SQLiteManager.swift
//  ACSQLite
//
//  Created by Américo José Cantillo Gutiérrez on 2/11/19.
//  Copyright © 2019 Américo José Cantillo Gutiérrez. All rights reserved.
//

import Foundation
import SQLite3

protocol DAOProtocol {
    
    associatedtype T
    typealias ContentValues = Dictionary
    typealias ContentTypes  = Dictionary
    
    mutating func save()
    
    mutating func update<T>(object: T)
    
    mutating func delete<T>(object: T)
    
    mutating func getAll<T>() -> [T]
    
   // mutating func getSome<T>(projection: [String], values: ContentValues<String, Any>, filterType: ContentTypes<String, Any>, orderBy: [String]) -> [T]
    
    mutating func getBy<T>(id: Int32) -> T?
}

class SQLiteManager {
    
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
    
    static func open(name: String) throws -> SQLiteManager {
        var db: OpaquePointer?
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(name + ".db")
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
            print("Database path: \(fileURL.path)")
            return SQLiteManager(db: db)
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

extension SQLiteManager {
    func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        return statement
    }
}

extension SQLiteManager {
    func create(acEntity: ACEntity) throws {
        //print("SQL Generado: \(acEntity.getCreateTableStatement())")
        let createTableStatement = try prepareStatement(sql: acEntity.getCreateTableStatement())
        defer {
            sqlite3_finalize(createTableStatement)
        }
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        print("Tabla \(acEntity.name) creada.")
    }
}

extension SQLiteManager {
    func insert(acEntity: ACEntity) throws {
        let insertStatement = try prepareStatement(sql: acEntity.insStatement())
        defer {
            sqlite3_finalize(insertStatement)
        }
        /*
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
        */
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        print("Successfully inserted row in table \(acEntity.name).")
    }
}

extension SQLiteManager {
    func update(acEntity: ACEntity) throws {
        let updateStatement = try prepareStatement(sql: acEntity.updStatement())
        defer {
            sqlite3_finalize(updateStatement)
        }
        /*
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
        */
        guard sqlite3_step(updateStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        print("Successfully updated row in table \(acEntity.name).")
    }
}

extension SQLiteManager {
    func delete(acEntity: ACEntity) throws {
        let deleteStatement = try prepareStatement(sql: acEntity.delStatement())
        defer {
            sqlite3_finalize(deleteStatement)
        }
        
        /*
        guard sqlite3_bind_int(deleteStatement, 1, tarea.id!) == SQLITE_OK else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        */
        guard sqlite3_step(deleteStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        print("Successfully deleted row in table \(acEntity.name).")
    }
}

extension SQLiteManager {
    func select(acEntity: ACEntity, slCols: [ACColumn], whCols: [ACColumn]?) throws -> [ACEntity]? {
        
        var results = [ACEntity]()
        
        
        
        var col: ACColumn = ACColumn()
        
        var entity: ACEntity = ACEntity()
        
        let sql_stmt: String = acEntity.selStatement(slCols: slCols, whCols: whCols!)
        
        if sqlite3_prepare_v2(db, sql_stmt, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        
        //let queryStatement = try prepareStatement(sql: acEntity.selStatement(whCols: whCols))
        //defer {
        //    sqlite3_finalize(queryStatement)
       // }
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            
            var index: Int = 0
            var index_stmt: Int32 = 0
            //var c = ACColumn()
            var cols: [ACColumn] = [ACColumn]()
            for column in acEntity.columns.sorted(by: { ($0 as ACColumn).index! < ($1 as ACColumn).index! }) {
                if sqlite3_column_type(stmt, index_stmt) != SQLITE_NULL {
                    col = column.copy() as! ACColumn
                    let tp = column.type!
                    switch tp {
                    case .int32, .int64, .integer:
                        col.valueInt32 = sqlite3_column_int(stmt, index_stmt)
                        //col.setValue(value: sqlite3_column_int(stmt, index_stmt))
                    case .char, .text:
                        let text = sqlite3_column_text(stmt, index_stmt)
                        //print("Descripción del registro: \(String(cString: text!))")
                        col.valueString = String(cString: text!)
                        //col.setValue(value: String(cString: text!))
                    case .bool:
                        col.valueBool = sqlite3_column_int(stmt, index_stmt)
                        //col.setValue(value: sqlite3_column_int(stmt, index_stmt))
                    case .date:
                        col.valueDate = Date(timeIntervalSinceReferenceDate: sqlite3_column_double(stmt, index_stmt))
                        //col.setValue(value: Date(timeIntervalSinceReferenceDate: sqlite3_column_double(stmt, index_stmt)))
                    default:
                        break
                    }
                }
                cols.append(col)
                index += 1
                index_stmt += 1
            }
            
            /*
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
            
            //let tarea = Tarea(id: id, name: name, started: started, finished: finished, elapsed: elapsed, status: status)
            */
            
            entity = acEntity.copy() as! ACEntity
            
            entity.addColumns(cols: cols)
            
            results.append(entity)
        }
        
        if sqlite3_finalize(stmt) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        
        stmt = nil

        print("Successfully fetched rows.")
        
        return results
        
    }
}

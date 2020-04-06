//
//  CreateSchema.swift
//  ACSQLite
//
//  Created by Américo José Cantillo Gutiérrez on 6/30/19.
//  Copyright © 2019 Américo José Cantillo Gutiérrez. All rights reserved.
//

import Foundation

class ACSchema {
    
    private var _db: SQLiteManager?

    static let shared = ACSchema()
    
    private var message: String? = ""
    
    // Se definen todas las entidades que componen el esquema
    let acEstado = ACEntity(name: "ACESTADO")
    let acAgenda = ACEntity(name: "ACAGENDA")
    
    
    // En el constructor se inicializan todas las entidades para el manejo de persistencia
    private init(_ db: SQLiteManager? = nil) {
        
        isInitialized = false
        
        if db == nil {
            connect(dbName: "dbtest")
        } else {
            _db = db
        }
        
        initEntities()

        if !isInitialized {
            
            create(acEntity: acEstado)
            save(acEntity: acEstado)
            
            create(acEntity: acAgenda)
            save(acEntity: acAgenda)
        }
    }
    
    func getDatabase() -> SQLiteManager? {
        return _db
    }
    
    func setDatabase(_ db: SQLiteManager?) {
        _db = db
    }
    
    func connect(dbName: String) {
        do {
            if !doesFileExist(name: dbName + ".db") {
                print("The bd file \(dbName).db doesn't exist.")
            } else {
                isInitialized = true
            }
            print("isInitialized: \(isInitialized)")
            _db = try SQLiteManager.open(name: dbName)
            print("Successfully opened connection to database <\(dbName)>.")
        } catch SQLiteError.OpenDatabase(self.message) {
            print("Unable to open database <\(dbName)>. Verify that you created the directory described in the Getting Started section.")
            print(self.message)
        } catch {
            print(error)
        }
    }
    
    func initEntities() {
        let estadoId: ACColumn = ACColumn(index: 0, name: "id")
        estadoId.type = ACType.int32
        estadoId.attributes.append(.primaryKey)
        estadoId.attributes.append(.autoIncrement)
        estadoId.setValue(value: 1)
        
        let estadoNombre: ACColumn = ACColumn(index: 1, name: "descripcion")
        estadoNombre.type = ACType.char
        estadoNombre.attributes.append(.notNull)
        estadoNombre.setValue(value: "Activo")
        
        acEstado.addColumns(cols: [estadoId, estadoNombre])
        
        
        let colId: ACColumn = ACColumn(index: 0, name: "id")
        colId.type = ACType.int32
        colId.attributes.append(.primaryKey)
        colId.attributes.append(.autoIncrement)
        colId.setValue(value: 1)
        //colId.valueInt32 = 1
        
        let colDesc: ACColumn = ACColumn(index: 1, name: "descripcion")
        colDesc.type = ACType.char
        colDesc.attributes.append(.notNull)
        colDesc.setValue(value: "Ir a Estación")
        
        let colFechaActivacion = ACColumn(index: 2, name: "fechaActivacion", type: .date)
        colFechaActivacion.attributes.append(.notNull)
        colFechaActivacion.setValue(value: Date())
        
        let colDuracionPausa = ACColumn(index: 3, name: "duracionPausa", type: .int32)
        colDuracionPausa.attributes.append(.notNull)
        //colDuracionPausa.defaultValueInt32 = 10
        colDuracionPausa.setValue(value: 15)
        colDuracionPausa.attributes.append(.lack)
        
        let colEstado =  ACColumn(index: 4, name: "estadoid", type: .int32, long: 10, refACEntityName: acEstado.name, refACColumnName: "id")
        colEstado.attributes.append(.foreignKey)
        //colEstado.defaultValueInt32 = 1
        colEstado.setValue(value: 1)
        colEstado.attributes.append(.lack)
        
        acAgenda.addColumns(cols: [colId, colDesc, colFechaActivacion, colDuracionPausa, colEstado])

    }
    
    func create(acEntity: ACEntity) {
        do {
            try _db!.create(acEntity: acEntity)
        } catch {
            print(_db!.errMessage())
        }
    }
    
    func save(acEntity: ACEntity) {
        do {
            try _db!.insert(acEntity: acEntity)
        } catch {
            print(_db!.errMessage())
        }
    }
    
}

//
//  ViewController.swift
//  ACSQLite
//
//  Created by Américo José Cantillo Gutiérrez on 2/7/19.
//  Copyright © 2019 Américo José Cantillo Gutiérrez. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    let db = ACSchema.shared.getDatabase()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("Instanciado el objeto.")
        
        let descAgenda: ACColumn = ACSchema.shared.acAgenda.getColumn(name: "descripcion").copy() as! ACColumn
        
        descAgenda.valueString = "eba"
        
        let rs: [ACEntity] = try! (db?.select(acEntity: ACSchema.shared.acAgenda, slCols: ACSchema.shared.acAgenda.columns, whCols: [descAgenda]))!
        
        
        
        for r in rs {
            print(r.getColumn(name: "id").getValueToString() + " - " + r.getColumn(name: "descripcion").getValueToString())
        }
        
        //ACSchema.shared.connect(dbName: "dbtest")
        
        //print("Registro insertado")
        /*
        do {
            let resultados = try db!.select(acEntity: acAgenda, whCols: [colDuracionPausa])
            
            for obs in resultados as! [ACEntity] {
                print("Resultado: \(obs)")
                print("Cols: ID<\(obs.getColumn(name: "id").name)>")
                print("Cols: NAME<\(obs.getColumn(name: "descripcion").name)>")
                
                let id = obs.getColumn(name: "id").getValue() as Int
                let descripcion = obs.getColumn(name: "descripcion").getValue() as String
                
                print("ID: \(id)  - Descripcion: \(descripcion)")
            }
            
        } catch {
            print(db!.errMessage())
        }
 */

        
    }


}


//
//  Model.swift
//  ACSQLite
//
//  Created by Américo José Cantillo Gutiérrez on 2/10/19.
//  Copyright © 2019 Américo José Cantillo Gutiérrez. All rights reserved.
//

import Foundation

class TareaManager {
    
}

struct Tarea {
    var id: Int32?
    var name: String?
    var started: Date?
    var finished: Date?
    var elapsed: Int32?
    var status: Int32?
    
    init() {
        
    }
    
    init(name: String, started: Date, finished: Date, elapsed: Int32, status: Int32) {
        self.init()
        self.name = name
        self.started = started
        self.finished = finished
        self.elapsed = elapsed
        self.status = status
    }
    
    init(id: Int32, name: String, started: Date, finished: Date, elapsed: Int32, status: Int32) {
        self.init(name: name, started: started, finished: finished, elapsed: elapsed, status: status)
        self.id = id
    }
}

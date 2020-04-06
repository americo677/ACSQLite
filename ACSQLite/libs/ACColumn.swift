//
//  ACColumn.swift
//  ACSQLite
//
//  Created by Américo José Cantillo Gutiérrez on 2/15/19.
//  Copyright © 2019 Américo José Cantillo Gutiérrez. All rights reserved.
//

import Foundation

enum ACType: Int {
    case int32 = 0, int64, integer, double, float, text, char, bool, date, blob
}

enum ACAttribute: String {
    case primaryKey = "PRIMARY KEY", autoIncrement = "AUTOINCREMENT", notNull = "NOT NULL", unique = "UNIQUE", lack = "DEFAULT", foreignKey = "FOREIGN KEY"
}

class ACColumn: NSCopying {
    
    var index: Int?
    
    var name = String()
    
    var type: ACType?
    
    var attributes = [ACAttribute]()
    
    var referenceACEntityName: String = ""
    
    var referenceACColumnName: String = ""
    
    var long: Int = 250
    
    var valueInt32 = Int32()
    var valueInt64 = Int64()
    var valueFloat = Float()
    var valueDouble = Double()
    var valueString = String()
    var valueBool = Int32()
    var valueDate = Date()
    //var valueBlob: AnyObject = nil
    
    var defaultValueInt32 = Int32()
    var defaultValueInt64 = Int64()
    var defaultValueFloat = Float()
    var defaultValueDouble = Double()
    var defaultValueString = String()
    var defaultValueBool = Int32()
    var defaultValueDate = Date()
    //var defaultValueBlob: AnyObject = nil

    init() {
        self.referenceACEntityName = ""
        self.referenceACColumnName = ""
    }
    
    convenience init(index: Int) {
        self.init()
        self.index = index
    }
    
    convenience init(index: Int, name: String) {
        self.init(index: index)
        self.name = name
    }
    
    convenience init(index: Int, name: String, type: ACType, long: Int = 255) {
        self.init(index: index, name: name)
        self.type = type
        self.long = long
    }

    convenience init(index: Int, name: String, type: ACType, long: Int = 255, refACEntityName: String, refACColumnName: String) {
        self.init(index: index, name: name, type: type, long: long)
        self.referenceACEntityName = refACEntityName
        self.referenceACColumnName = refACColumnName
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ACColumn.init(index: self.index!, name: self.name, type: self.type!, long: self.long)
        copy.attributes = self.attributes

        copy.valueInt32 = self.valueInt32
        copy.valueInt64 = self.valueInt64
        copy.valueFloat = self.valueFloat
        copy.valueDouble = self.valueDouble
        copy.valueString = self.valueString
        copy.valueBool = self.valueBool
        copy.valueDate = self.valueDate
        
        copy.defaultValueInt32 = self.defaultValueInt32
        copy.defaultValueInt64 = self.defaultValueInt64
        copy.defaultValueFloat = self.defaultValueFloat
        copy.defaultValueDouble = self.defaultValueDouble
        copy.defaultValueString = self.defaultValueString
        copy.defaultValueBool = self.defaultValueBool
        copy.defaultValueDate = self.defaultValueDate

        return copy
    }

    func setValue<T: Equatable>(value: T) {
        switch self.type! {
        case .int32, .integer:
            self.valueInt32 = Int32(value as! Int)
        case .int64:
            self.valueInt64 = Int64(value as! Int)
        case .double:
            self.valueDouble = Double(truncating: NSNumber.init(value: value as! Double))
        case  .float:
            self.valueFloat = Float(truncating: NSNumber.init(value: value as! Float))
        case .char, .text:
            self.valueString = value as! String
        //case .blob:
        //    return defaultValueBlob.stringValue
            
        case .bool:
            self.valueBool = value as! Int32
        case.date:
            self.valueDate = value as! Date
        default:
            self.valueString = value as! String
        }

    }

    func getValue<T>() -> T {
        var result: T
        switch self.type! {
        case .int32, .integer:
            result = NSNumber.init(value: self.valueInt32).intValue as! T
        case .int64:
            result = NSNumber.init(value: self.valueInt64).intValue as! T
        case .double:
            result = NSNumber.init(value: self.valueDouble).doubleValue as! T
        case  .float:
            result = NSNumber.init(value: self.valueFloat).floatValue as! T
        case .char, .text:
            result = self.valueString as! T
            //case .blob:
            //    return defaultValueBlob.stringValue
            
        case .bool:
            result = NSNumber.init(value: self.valueBool).intValue as! T
        case.date:
            result = self.valueDate as! T
        default:
            result = self.valueString as! T
        }
        
        return result
    }

    func getAttributesToString() -> String {
        var result: String = ""
        
        if (attributes.contains(ACAttribute.primaryKey)) {
            if result == "" {
                result = ACAttribute.primaryKey.rawValue
            }
        }
        
        if (attributes.contains(ACAttribute.autoIncrement)) {
            if result == "" {
                result = ACAttribute.autoIncrement.rawValue
            } else {
                result += " " + ACAttribute.autoIncrement.rawValue
            }
        }
        
        if (attributes.contains(ACAttribute.unique)) {
            if result == "" {
                result = ACAttribute.unique.rawValue
            } else {
                result += " " + ACAttribute.unique.rawValue
            }
        }

        if (attributes.contains(ACAttribute.notNull)) {
            if result == "" {
                result = ACAttribute.notNull.rawValue
            } else {
                result += " " + ACAttribute.notNull.rawValue
            }
        }
        
        if (attributes.contains(ACAttribute.lack)) {
            
            let defaultValue = getDefaultToString()
            
            if defaultValue != "" {
                if result == "" {
                    result = ACAttribute.lack.rawValue + " " + getDefaultToString()
                } else {
                    result += " " + ACAttribute.lack.rawValue + " " + getDefaultToString()
                }
            }
        }
        
        return result

    }
    
    private func getDefaultToString() -> String {
        let blank: String = ""
        
        switch self.type! {
        case .int32, .integer, .int64:
            let val = NSNumber(value: self.defaultValueInt32)
            return val.stringValue
        case .double:
            let val = NSNumber(value: defaultValueDouble)
            return val.stringValue
        case .float:
            let val = NSNumber(value: defaultValueFloat)
            return val.stringValue
        case .char, .text:
            let val: String = defaultValueString
            return "'" + val + "'"
        //case .blob:
        //    return defaultValueBlob.stringValue
        case .bool:
            let entero: Int = defaultValueBool.hashValue
            let val: NSNumber = NSNumber.init(value: entero)
            return "'" + val.stringValue + "'"
        case.date:
            let formatter = DateFormatter()
            // initially set the format based on your datepicker date / server String
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let val: String = formatter.string(from: defaultValueDate)
            
            if val != "" {
                return "'" + val + "'"
            } else {
                return blank
            }
            // string purpose I add here
            // convert your string to date
            //let yourDate = formatter.date(from: myString)
            //then again set the date format whhich type of output you need
            //formatter.dateFormat = "dd-MMM-yyyy"
            // again convert your date to string
            //let myStringafd = formatter.string(from: yourDate!)
        default:
            return blank
        }
    }
    
    func getTypeToString() -> String {
        var result: String = ""
        
        switch self.type! {
        case .int32, .integer:
            result = "INTEGER"
        case .int64:
            result =  "INTEGER"
        case .double:
            result =  "INTEGER"
        case .float:
            result =  "INTEGER"
        case .char:
            result =  "CHAR(" + NSNumber.init(value: self.long).stringValue + ")"
        case .text:
            result =  "TEXT"
        //case .blob:
        //    result =  "BLOB"
        case .bool:
            result =  "INTEGER"
        case.date:
            result =  "DATE"
        default:
            result =  "TEXT"
        }
        
        return result
    }
    
    func getValueToString() -> String {
        var result: String = ""
        
        switch self.type! {
        case .int32, .integer:
            let value: Int32 = valueInt32
            result = NSNumber.init(value: value).stringValue
        case .int64:
            let value: Int64 = valueInt64
            result = NSNumber.init(value: value).stringValue
        case .double:
            let value: Double = valueDouble
            result = NSNumber.init(value: value).stringValue
        case .float:
            let value: Float = valueFloat
            result = NSNumber.init(value: value).stringValue
        case .char:
            result = valueString
        case .text:
            result = valueString
        //case .blob:
        //    result =  value
        case .bool:
            let value: Int = defaultValueBool.hashValue
            result = NSNumber.init(value: value).stringValue
        case.date:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            result = formatter.string(from: valueDate) // string purpose I add here
        default:
            result = valueString
            
        }
        
        return result

    }
}

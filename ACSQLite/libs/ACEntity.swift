//
//  ACEntity.swift
//  ACSQLite
//
//  Created by Américo José Cantillo Gutiérrez on 2/11/19.
//  Copyright © 2019 Américo José Cantillo Gutiérrez. All rights reserved.
//

import Foundation

enum ACSentence: String {
    case equals = "OIZQ = @ODER@", initLike = "OIZQ LIKE '@ODER@%'", finishLike = "OIZQ LIKE '%@ODER@'", contains = "OIZQ LIKE '%@ODER@%'", greaterEqualThan = "OIZQ >= @ODER@", lessEqualThan = "OIZQ <= @ODER@", greaterThan = "OIZQ > @ODER@", lessThan = "OIZQ < @ODER@", notEquals = "OIZQ <> @ODER@"
}


class ACEntity: NSCopying {
    
    var name = String()
    
    var columns = [ACColumn]()
    
    private var dicCols = Dictionary<String, ACColumn>()
    
    init() {
    }
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
    
    convenience init(name: String, columns: [ACColumn]) {
        self.init()
        self.name = name
        self.columns = columns
        for column in columns {
            dicCols[column.name] = column
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ACEntity(name: self.name, columns: self.columns)
        return copy
    }


    func addColumn(col: ACColumn) {
        columns.append(col)
        dicCols[col.name] = col
    }
    
    func addColumns(cols: [ACColumn]) {
        columns = cols
        for column in columns {
            dicCols[column.name] = column
        }
    }
    
    func getColumn(name: String) -> ACColumn {
        var col: ACColumn?
        
        col = dicCols[name]
        
        return col!
    }
    
    func removeColumn(index: Int) {
        let colToRemove = columns[index]
        columns.remove(at: index)
        dicCols.removeValue(forKey: colToRemove.name)
    }
    
    func removeColumn(column: ACColumn) {
        dicCols.removeValue(forKey: column.name)
        let indexFounded: Int = (columns.index{$0 === column})!
        columns.remove(at: indexFounded)
    }
    
    func getCreateTableStatement() -> String {
        var stmt: String = ""
        var cols_statements: String = ""
        for col in columns {
            if cols_statements == "" {
                cols_statements += col.name + " " + col.getTypeToString() + " " + col.getAttributesToString()
            } else {
                cols_statements += ", " + col.name + " " + col.getTypeToString() + " " + col.getAttributesToString()
            }
        }
        
        var foreignKeys: String = ""
        
        for col in columns {
            
            if (col.attributes.contains(ACAttribute.foreignKey)) {
                
                if foreignKeys == "" {
                        foreignKeys = ACAttribute.foreignKey.rawValue + " (" + col.name + ") REFERENCES " + col.referenceACEntityName + "(" + col.referenceACColumnName + ") "
                } else {
                        foreignKeys += ", " + ACAttribute.foreignKey.rawValue + " (" + col.name + ") REFERENCES " + col.referenceACEntityName + "(" + col.referenceACColumnName + ") "
                }
            }
        }
        
        if foreignKeys != "" {
            cols_statements += ", " + foreignKeys
        }
        
        stmt = "CREATE TABLE IF NOT EXISTS " + name + "(" + cols_statements + ")"
        print (stmt)
        return stmt
    }
    
    private func getUpdateStatement() -> String {
        var stmt: String = ""
        
        var cols_statements: String = ""
        var cols_where_stmt: String = ""
        
        for column in columns {
            if column.attributes.contains(.primaryKey) {
                if cols_where_stmt == "" {
                    cols_where_stmt += column.name + " = @" + column.name + "@"
                } else {
                    cols_where_stmt += " AND " + column.name + " = @" + column.name + "@"
                }
            }
            
            if !column.attributes.contains(.primaryKey) {
                if cols_statements == "" {
                    cols_statements += column.name + " = @" + column.name + "@ "
                } else {
                    cols_statements += ", " + column.name + " = @" + column.name + "@ "
                }
            }
        }
        
        stmt = "UPDATE " + self.name + " SET " + cols_statements + " WHERE " + cols_where_stmt + ";"
        
        return stmt
    }

    private func getInsertStatement() -> String {
        var stmt: String = ""
        
        var cols_statements: String = ""
        var cols_value_stmt: String = ""
        
        for column in columns {
            if !column.attributes.contains(.autoIncrement) {
                if cols_value_stmt == "" {
                    cols_value_stmt += "@" + column.name + "@"
                    
                } else {
                    cols_value_stmt += ", @" + column.name + "@"
                }
                if cols_statements == "" {
                    cols_statements += column.name
                } else {
                    cols_statements += ", " + column.name
                }
            }
        }
        
        stmt = "INSERT INTO " + self.name + " (" + cols_statements + " ) VALUES ( " + cols_value_stmt + ");"
        
        return stmt
    }

    private func getDeleteStatement() -> String {
        var stmt: String = ""
        
        //var cols_statements: String = ""
        var cols_where_stmt: String = ""
        
        for column in columns {
            if column.attributes.contains(.primaryKey) {
                if cols_where_stmt == "" {
                    cols_where_stmt += column.name + " = @" + column.name + "@"
                } else {
                    cols_where_stmt += " AND " + column.name + " = @" + column.name + "@"
                }
            }
        }
        
        stmt = "DELETE FROM " + self.name + " WHERE " + cols_where_stmt + ";"
        
        return stmt
    }
    
    private func getStatementComparision(sentence: ACSentence) -> String {
        var result: String = ""

        switch sentence {
    
        case .equals:
        result = ACSentence.equals.rawValue
        case .initLike:
        result = ACSentence.initLike.rawValue
        case .finishLike:
        result = ACSentence.finishLike.rawValue
        case .contains:
        result = ACSentence.contains.rawValue
        case .greaterEqualThan:
        result = ACSentence.greaterEqualThan.rawValue
        case .lessEqualThan:
        result = ACSentence.lessEqualThan.rawValue
        case .greaterThan:
        result = ACSentence.greaterThan.rawValue
        case .lessThan:
        result = ACSentence.lessThan.rawValue
        case .notEquals:
        result = ACSentence.notEquals.rawValue
        }
    
        return result
    }
    
    func getSelectStatement(slCols:[ACColumn], whCols: [ACColumn]?, sentence: ACSentence = ACSentence.contains) -> String {
        var stmt: String = ""
        
        var cols_statements: String = ""
        var cols_where_stmt: String = ""
        
        // construye las columnas que se seleccionarán
        check_all_cols: for column in columns.sorted(by: { ($0 as ACColumn).index! < ($1 as ACColumn).index! }) {
            check_col_selected: for c in slCols {
                if column.name.lowercased() == c.name.lowercased() {
                    if cols_statements == "" {
                        cols_statements += column.name
                    } else {
                        cols_statements += ", " + column.name
                    }
                    break check_col_selected
                }
            }
            
        }

        // construye el where del select
        if whCols?.count != 0 {
            
            var strWhere: String = ""
            
            for column in whCols!.sorted(by: { ($0 as ACColumn).index! < ($1 as ACColumn).index! }) {
                
                strWhere = getStatementComparision(sentence: sentence)
                
                strWhere = strWhere.replacingOccurrences(of: "OIZQ", with: column.name)
                strWhere = strWhere.replacingOccurrences(of: "ODER", with: column.name)
                
                if cols_where_stmt == "" {
                    cols_where_stmt += strWhere
                } else {
                    cols_where_stmt += " AND " + strWhere
                }
            }
        }
        
        
        stmt = "SELECT " + cols_statements + " FROM " + self.name
        if cols_where_stmt != "" {
            stmt += " WHERE " + cols_where_stmt + ";"
        }
        return stmt
    }
    
    func insStatement() -> String {
        var stmt: String = getInsertStatement()
        for column in columns {
            stmt = stmt.replacingOccurrences(of: "@" + column.name + "@", with: column.getValueToString())
        }
        return stmt
    }
    
    func updStatement() -> String {
        var stmt: String = getUpdateStatement()
        for column in columns {
            stmt = stmt.replacingOccurrences(of: "@" + column.name + "@", with: column.getValueToString())
        }
        return stmt
    }
    
    func delStatement() -> String {
        var stmt: String = getDeleteStatement()
        for column in columns {
            stmt = stmt.replacingOccurrences(of: "@" + column.name + "@", with: column.getValueToString())
        }
        return stmt
    }
    
    func selStatement(slCols: [ACColumn], whCols: [ACColumn]?) -> String {
        // se genera la sentencia select comparando like - contains, operador por default
        var stmt: String = getSelectStatement(slCols: slCols, whCols: whCols)
        if whCols!.count > 0 {
            for column in whCols! {
                stmt = stmt.replacingOccurrences(of: "@" + column.name + "@", with: column.getValueToString())
            }
        }
        print("select statement: \(stmt)")
        return stmt
    }

}

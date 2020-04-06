//
//  Extensions.swift
//  Mis Regalos
//
//  Created by Américo Cantillo on 30/01/17.
//  Copyright © 2017 Américo Cantillo Gutiérrez. All rights reserved.
//

import Foundation
import UIKit
//import GoogleMobileAds
import StoreKit
import CoreData

// Put this piece of code anywhere you like
extension UIViewController {
    
    // MARK: - Procedimiento para ocultar el teclado al tocar la pantalla en cualquier punto
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Para terminar la edición de un UITextField
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Procedimientos para desplazar los controles de la vista al aparecer el teclado
    @objc func keyboardShowUp(notification: NSNotification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            self.view.frame.origin = CGPoint(x: 0, y: 0)
            
            //let lowerY = getLowerCoordYForTextField()
            
            // se resta de la vista la altura del teclado y la altura de la toolbar
            //self.view.frame.origin.y -= keyboardFrame.height - (self.navigationController?.toolbar.frame.size.height)!
            
            //let viewY = self.view.frame.origin.y - ( keyboardFrame.height - (self.navigationController?.toolbar.frame.size.height)!)
            
            //print("Modelo: \(UIDevice().model)")
            //print("Nombre: \(UIDevice().name)")
            //print("Descripcion: \(UIDevice().description)")
            //print("Nivel de batería: \(UIDevice().batteryLevel)")
            
            // Solo aplica para dispositivos iPod y iPhone
            if UIDevice().model.lowercased().contains("phone") || UIDevice().model.lowercased().contains("pod") {
                // se resta de la vista la altura del teclado y la altura de la toolbar
                self.view.frame.origin.y -= keyboardFrame.height - (self.navigationController?.toolbar.frame.size.height)!
            }
            
        }
    }
    
    // MARK: - Procedimientos para desplazar los controles de la vista al desaparecer el teclado
    @objc func keyboardHideUp(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            self.view.frame.origin = CGPoint(x: 0, y: 0)
        }
    }
    /*
    // MARK: - Registra las notificaciones del teclado
    func registerFromKeyboardNotifications() {
        
        // registra las notificaciones del teclado
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShowUp(notification:)), name: NSNotification.Name.UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHideUp(notification:)), name: NSNotification.Name.UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Remueve las notificaciones del teclado
    func deregisterFromKeyboardNotifications()
    {
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIResponder.keyboardWillHideNotification, object: nil)
    }
    */
    // MARK: - Alerta personalizada
    func showCustomAlert(_ vcSelf: UIViewController!, titleApp: String, strMensaje: String, toFocus: UITextField?) {
        let alertController = UIAlertController(title: titleApp, message:
            strMensaje, preferredStyle: UIAlertController.Style.alert)
        
        let action = UIAlertAction(title: "Aceptar", style: UIAlertAction.Style.cancel,handler: {_ in
            
            if toFocus != nil {
                toFocus!.becomeFirstResponder()
            }
        }
        )
        
        alertController.addAction(action)
        
        vcSelf.present(alertController, animated: true, completion: nil)
        
    }
    
    func getLowerCoordYForTextField() -> CGFloat {
        var lowerY: CGFloat = 0.0
        
        for v in self.view.subviews {
            if let tf = v as? UITextField {
                if lowerY <= tf.frame.origin.y {
                    lowerY = tf.frame.origin.y
                }
            }
        }
        return lowerY
    }
    
    func getObjectsThatConformToType<T>(type:T.Type) -> [T] {
        var returnArray: [T] = []
        for object in self.view.subviews as [UIView] {
            if let comformantModule = object as? T {
                returnArray.append(comformantModule)
            }
        }
        return returnArray
    }
    
    /*
    
    func initToolBar(toolbarDesign: ToolbarButtonDesign, actions: Array<Selector?>, title: String) {
        
        // Configuración Toolbar
        self.navigationController?.isToolbarHidden = false
        
        // Cambia el color de la navigation bar
        self.navigationController?.navigationBar.barTintColor = UIColor.toolbarBackgroundColor()
        
        // Cambia el color del texto de la navigation bar
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.toolbarTitleFontColor(),  NSAttributedStringKey.font: UIFont(name: Global.fuente.FONT_NAME_TITLE_NAVIGATION_BAR, size: Global.fuente.FONT_SIZE_14)!]
        
        self.navigationController?.navigationBar.tintColor = UIColor.toolbarTitleFontColor()
        
        self.navigationItem.title = title
        
        // Status bar white font
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        
        
        let buttonFont : UIFont = UIFont(name: Global.fuente.FONT_NAME_TITLE_NAVIGATION_BAR, size: Global.fuente.FONT_SIZE_13)!
        
        let attribs = [NSAttributedStringKey.foregroundColor : UIColor.toolbarTitleFontColor(),NSAttributedStringKey.font : buttonFont]
        
        if toolbarDesign == .toLeftMenuToRightEditNewStyle {
            let menuButtonLeft = UIBarButtonItem(title: "Menú", style: UIBarButtonItemStyle.plain, target: self, action: actions[0])
            
            let editButtonRight   = UIBarButtonItem(title: "Editar", style: UIBarButtonItemStyle.plain, target: self, action: actions[1])
            
            editButtonRight.possibleTitles = ["Editar", "Aceptar"]
            
            let newButtonRight = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: actions[2])
            
            let backButtonLeft = UIBarButtonItem(title: "Regresar", style: UIBarButtonItemStyle.plain, target: self, action: actions[0])
            
            menuButtonLeft.setTitleTextAttributes(attribs, for: UIControlState.normal)
            editButtonRight.setTitleTextAttributes(attribs, for: UIControlState.normal)
            newButtonRight.setTitleTextAttributes(attribs, for: UIControlState.normal)
            backButtonLeft.setTitleTextAttributes(attribs, for: UIControlState.normal)
            
            navigationItem.rightBarButtonItems = [newButtonRight, editButtonRight]
            
            self.navigationItem.leftBarButtonItem = menuButtonLeft
            
            self.navigationItem.backBarButtonItem = backButtonLeft
            
        } else if toolbarDesign == .toLeftBackToRightEditNewStyle {
            let backButtonLeft = UIBarButtonItem(title: "Regresar", style: UIBarButtonItemStyle.plain, target: self, action: actions[0])
            
            let editButtonRight = UIBarButtonItem(title: "Editar", style: UIBarButtonItemStyle.plain, target: self, action: actions[1])
            
            editButtonRight.possibleTitles = ["Editar", "Aceptar"]
            
            let newButtonRight = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: actions[2])
            
            backButtonLeft.setTitleTextAttributes(attribs, for: UIControlState.normal)
            editButtonRight.setTitleTextAttributes(attribs, for: UIControlState.normal)
            newButtonRight.setTitleTextAttributes(attribs, for: UIControlState.normal)
            
            navigationItem.rightBarButtonItems = [newButtonRight, editButtonRight]
            
            self.navigationItem.backBarButtonItem = backButtonLeft
        } else if toolbarDesign == .toLeftBackToRightSaveStyle {
            let backButtonLeft = UIBarButtonItem(title: "Regresar", style: UIBarButtonItemStyle.plain, target: self, action: actions[0])
            
            let saveButtonRight = UIBarButtonItem(title: "Guardar", style: UIBarButtonItemStyle.plain, target: self, action: actions[1])
            
            saveButtonRight.setTitleTextAttributes(attribs, for: UIControlState.normal)
            backButtonLeft.setTitleTextAttributes(attribs, for: UIControlState.normal)
            
            navigationItem.rightBarButtonItems = [saveButtonRight]
            
            self.navigationItem.backBarButtonItem = backButtonLeft
        } else if toolbarDesign == .toLeftBackToRightStyle {
            let backButtonLeft = UIBarButtonItem(title: "Regresar", style: UIBarButtonItemStyle.plain, target: self, action: actions[0])
            
            backButtonLeft.setTitleTextAttributes(attribs, for: UIControlState.normal)
            
            self.navigationItem.backBarButtonItem = backButtonLeft
        } else if toolbarDesign == .toLeftBackToRightPDFStyle {
            let backButtonLeft = UIBarButtonItem(title: "Regresar", style: UIBarButtonItemStyle.plain, target: self, action: actions[0])
            
            let pdfButtonRight = UIBarButtonItem(title: "PDF", style: UIBarButtonItemStyle.plain, target: self, action: actions[1])
            
            pdfButtonRight.setTitleTextAttributes(attribs, for: UIControlState.normal)
            backButtonLeft.setTitleTextAttributes(attribs, for: UIControlState.normal)
            
            navigationItem.rightBarButtonItems = [pdfButtonRight]
            self.navigationItem.backBarButtonItem = backButtonLeft
        }
    }
    */
    
    //    func restrictRotation(restrict: Bool) {
    //        let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //        appDelegate.restrictRotation = restrict
    //    }
    
    //    // MARK: - Consulta a la BD de instituciones y escalas registradas
    //    func fetchData(entity: ClassForPreLoading, byIndex index: Double? = nil, orderByIndex order: Bool? = false) -> [AnyObject] {
    //
    //        var results = [AnyObject]()
    //
    //        let moc = SingleManagedObjectContext.sharedInstance.getMOC()
    //        //let sortDescriptor = NSSortDescriptor(key: "secciones.recibos.fecha", ascending: false)
    //
    //
    //        // fetchRequest.sortDescriptors = [sortDescriptor]
    //
    //        // Initialize Fetch Request
    //        //let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: smModelo.smPresupuesto.entityName)
    //
    //        //let fetchRequest: NSFetchRequest<Programa> = Programa.fetchRequest() //
    //        //var fecthRequest: NSFetchRequestResult?
    //
    //        switch entity {
    //        case .institucion:
    //            let fetchInstitucion: NSFetchRequest<Institucion> = Institucion.fetchRequest()
    //            fetchInstitucion.entity = NSEntityDescription.entity(forEntityName: "Institucion", in: moc)
    //            if index != nil {
    //                let predicate = NSPredicate(format: " indice == %d ", (index! as NSNumber).intValue)
    //                //let predicate = NSPredicate(format: " descripcion contains[c] %@ ", "norte" as String)
    //                fetchInstitucion.predicate = predicate
    //            }
    //            do {
    //                results = try moc.fetch(fetchInstitucion)
    //
    //            } catch {
    //                let fetchError = error as NSError
    //                print(fetchError)
    //            }
    //            break
    //        case .escala:
    //            let fetchEscala: NSFetchRequest<Escala> = Escala.fetchRequest()
    //            fetchEscala.entity = NSEntityDescription.entity(forEntityName: "Escala", in: moc)
    //            if index != nil {
    //                let predicate = NSPredicate(format: " indice == %d ", (index! as NSNumber).intValue)
    //                fetchEscala.predicate = predicate
    //            }
    //            do {
    //                results = try moc.fetch(fetchEscala)
    //
    //            } catch {
    //                let fetchError = error as NSError
    //                print(fetchError)
    //            }
    //            break
    //        case .programa:
    //            let fetchPrograma: NSFetchRequest<Programa> = Programa.fetchRequest()
    //            fetchPrograma.entity = NSEntityDescription.entity(forEntityName: "Programa", in: moc)
    //            if index != nil {
    //                let predicate = NSPredicate(format: " indice == %d ", (index! as NSNumber).intValue)
    //                fetchPrograma.predicate = predicate
    //            }
    //            do {
    //                let programas = try moc.fetch(fetchPrograma)
    //                if order! {
    //                    results = programas.sorted { ($0 as Programa).indice < ($1 as Programa).indice }
    //                } else {
    //                    results = programas
    //                }
    //
    //            } catch {
    //                let fetchError = error as NSError
    //                print(fetchError)
    //            }
    //            break
    //        default:
    //            break
    //        }
    //
    //        return results
    //    }
    
    
    // MARK: - Configuración del Banner de publicidad
    /*
     func configAds() {
     
     self.gadBannerView.adSize = kGADAdSizeBanner
     
     //let frame = CGRect(x:0, y:self.view.frame.size.height - self.gadBannerView.adSize.size.height - (self.navigationController?.toolbar.frame.size.height)!, width:320, height:50)
     
     //self.gadBannerView.frame = frame
     
     let request = GADRequest()
     
     request.testDevices = [kGADSimulatorID]
     
     self.gadBannerView.adUnitID = CGlobal().AD_UNIT_ID_TEST
     //self.gadBannerView.adUnitID = CGlobal().AD_UNIT_ID
     
     self.gadBannerView.delegate = self
     
     self.gadBannerView.rootViewController = self
     
     self.gadBannerView.load(request)
     
     //self.gadBannerView.tag = 1
     
     self.gadBannerView.translatesAutoresizingMaskIntoConstraints = false
     
     self.view.addSubview(self.gadBannerView)
     
     let center = NSLayoutConstraint(item: self.gadBannerView, attribute: .centerX, relatedBy: .lessThanOrEqual, toItem: self.gadBannerView.superview, attribute: .centerX, multiplier: 1, constant: 0)
     
     //let bottom = NSLayoutConstraint(item: self.gadBannerView, attribute: .bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute:.top, multiplier: 1, constant:-((self.navigationController?.toolbar.frame.size.height)!))
     
     let bottom = NSLayoutConstraint(item: self.gadBannerView, attribute: .bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute:.top, multiplier: 1, constant:0)
     
     self.view.addConstraints([center, bottom])
     }
     */
}


extension NSDate {
    
    public func isLessThan(date: Date) -> Bool {
        return self.compare(date) == ComparisonResult.orderedAscending
    }
    
    public func isLessEqualThan(date: Date) -> Bool {
        return self.compare(date) == ComparisonResult.orderedAscending && self.compare(date) == ComparisonResult.orderedSame
    }
    
    public func isGreaterThan(date: Date) -> Bool {
        return self.compare(date) == ComparisonResult.orderedDescending
    }
    
    public func isGreaterEqualThan(date: Date) -> Bool {
        return self.compare(date) == ComparisonResult.orderedDescending && self.compare(date) == ComparisonResult.orderedSame
    }
}


extension UIViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Funciones de los UIPickerViews
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 0
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return nil
    }
    
    // MARK: - Carga inicial del pickerView con Array<String>
    /*
    func loadPickerView(_ pickerView: inout UIPickerView, indiceSeleccionado: Int, indicePorDefecto: Int = 0, tag: Int, textField tf: UITextField? = nil, opciones: Array<String>, accionDone: Selector?, accionCancel: Selector?) {
        
        // Preparación del Picker de ipo de RegistroT
        pickerView     = UIPickerView(frame: CGRect(x: 0, y: 10, width: view.frame.width, height: 220))
        
        pickerView.backgroundColor = UIColor.lightGray
        
        pickerView.tag = tag
        
        pickerView.showsSelectionIndicator = true
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let tb         = UIToolbar()
        tb.barStyle    = UIBarStyle.default
        tb.isTranslucent = true
        
        //toolBar.tintColor = UIColor.whiteColor()
        //UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        tb.sizeToFit()
        
        let btnDone = UIBarButtonItem(title: "Aceptar", style: UIBarButtonItemStyle.plain, target: self, action: accionDone!)
        
        let btnSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let btnCancel = UIBarButtonItem(title: "Cancelar", style: UIBarButtonItemStyle.plain, target: self, action: accionCancel!)
        
        tb.setItems([btnCancel, btnSpace, btnDone], animated: false)
        tb.isUserInteractionEnabled = true
        
        // colocar el valor por default en el picker de un solo componente
        if pickerView.selectedRow(inComponent: 0) == -1 {
            if pickerView.numberOfRows(inComponent: 0) > 0 {
                pickerView.selectRow(indicePorDefecto, inComponent: 0, animated: true)
                
                if tf != nil {
                    tf?.text = opciones[pickerView.selectedRow(inComponent: 0)]
                }
            }
        } else {
            if tf != nil {
                tf?.text = opciones[pickerView.selectedRow(inComponent: 0)]
            }
        }
        
        if tf != nil {
            tf?.inputView = pickerView
            tf?.inputAccessoryView = tb
        }
        
    }
     */
}
 
extension Double {
    func doubleFormatter(decimales: Int, estilo: NumberFormatter.Style = .none) -> String {
        let fmt = NumberFormatter()
        
        fmt.numberStyle = estilo
        fmt.maximumFractionDigits = decimales
        
        return fmt.string(from: NSNumber.init(value: self))!
    }
}

extension Float {
    func floatFormatter(decimales: Int, estilo: NumberFormatter.Style = .none) -> String {
        let fmt = NumberFormatter()
        
        fmt.numberStyle = estilo
        fmt.maximumFractionDigits = decimales
        
        return fmt.string(from: NSNumber.init(value: self))!
    }
}

extension String {
    
    static let numberFormatter = NumberFormatter()
    
    func getFilenameWithoutExtension() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }
    
    func getFileExtension() -> String {
        return (self as NSString).pathExtension
    }
    
    func occurrencies(_ chr: Character) -> Int {
        var count: Int = 0
        let chars = Array(self)
        
        for char in chars {
            if (chr == char) {
                count += 1
            }
        }
        return count
    }
    
    func doubleValue() -> Double {
        
        let value: NSNumber = NSNumber.init(value: 0)
        String.numberFormatter.maximumFractionDigits = 0
        String.numberFormatter.numberStyle = .none
        
        //nuevo
        String.numberFormatter.numberStyle = .decimal
        
        
        // nuevo
        String.numberFormatter.decimalSeparator = "."
        
        if let result: NSNumber = String.numberFormatter.number(from: self) {
            return result.doubleValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result: NSNumber = String.numberFormatter.number(from: self) {
                return result.doubleValue
            }
        }
        
        String.numberFormatter.decimalSeparator = "."
        String.numberFormatter.maximumFractionDigits = 2
        
        // nuevo
        String.numberFormatter.numberStyle = .decimal
        
        if let result: NSNumber = String.numberFormatter.number(from: self) {
            return result.doubleValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result: NSNumber = String.numberFormatter.number(from: self) {
                return result.doubleValue
            }
        }
        
        String.numberFormatter.decimalSeparator = "."
        String.numberFormatter.numberStyle = .currency
        String.numberFormatter.maximumFractionDigits = 2
        
        if let result: NSNumber = String.numberFormatter.number(from: self) {
            return result.doubleValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result: NSNumber = String.numberFormatter.number(from: self) {
                return result.doubleValue
            }
        }
        
        return value.doubleValue
    }
    
    func floatValue() -> Float {
        let value: NSNumber = NSNumber.init(value: 0)
        
        String.numberFormatter.decimalSeparator = "."
        String.numberFormatter.maximumFractionDigits = 0
        String.numberFormatter.numberStyle = .none
        
        if let result: NSNumber = String.numberFormatter.number(from: self) {
            return result.floatValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result: NSNumber = String.numberFormatter.number(from: self) {
                return result.floatValue
            }
        }
        
        String.numberFormatter.decimalSeparator = "."
        String.numberFormatter.maximumFractionDigits = 2
        
        if let result: NSNumber = String.numberFormatter.number(from: self) {
            return result.floatValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result: NSNumber = String.numberFormatter.number(from: self) {
                return result.floatValue
            }
        }
        
        String.numberFormatter.decimalSeparator = "."
        String.numberFormatter.maximumFractionDigits = 2
        String.numberFormatter.numberStyle = .currency
        
        if let result: NSNumber = String.numberFormatter.number(from: self) {
            return result.floatValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result: NSNumber = String.numberFormatter.number(from: self) {
                return result.floatValue
            }
        }
        
        return value.floatValue
    }
    
    func doubleFormatter(decimales: Int, estilo: NumberFormatter.Style = .none) -> String {
        let fmt = NumberFormatter()
        
        fmt.numberStyle = estilo
        fmt.maximumFractionDigits = decimales
        
        return fmt.string(from: NSNumber.init(value: self.doubleValue()))!
    }
    
}


extension Tarea: DAOManager {
    typealias T = Tarea
    typealias ContentValues = Dictionary
    typealias ContentTypes  = Dictionary

    func save() {
        // para insertar
        //let tarea = self
        
        var message: String?
        var db: ACSQLiteDBManager?
        do {
            db = try ACSQLiteDBManager.open(name: "dbtest")
            print("Successfully opened connection to database.")
        } catch SQLiteError.OpenDatabase(message) {
            print("Unable to open database. Verify that you created the directory described in the Getting Started section.")
            
            print(message!)
        } catch {
            
        }
        
        do {
            try db!.createTable(table: Tarea.self)
        } catch {
            print(db!.errMessage())
        }

        do {
            try db!.insTarea(tarea: self )
        } catch {
            print(db!.errMessage())
        }

    }
    
    func update<T>(object: T) {
        
    }
    
    func delete<T>(object: T) {
        
    }
    
    func getAll<T>() -> [T] {
        let tareas = [Tarea]()
        return [tareas] as! [T]
    
    }
    
    func getSome<T>(projection: [String], values: ContentValues<String, Any>, filterType: ContentTypes<String, Any>, orderBy: [String]) -> [T] {
        
        let tarea = [Tarea]()

        return [tarea] as! [T]
    }
    
    func getBy<T>(id: Int32) -> T? {
        let tarea = Tarea()
        
        return tarea as? T
    }

}

extension Tarea: SQLTable {
    static var createStatement: String {
        return "CREATE TABLE IF NOT EXISTS TAREA (ID INTEGER PRIMARY KEY AUTOINCREMENT, "
        + "NAME TEXT NOT NULL, "
        + "STARTED DATE NOT NULL, "
        + "FINISHED DATE, "
        + "ELAPSED INTEGER, "
        + "STATUS INTEGER);"
    }

    static var qrySQLStatement: String {
        return "SELECT id, name, started, finished, elapsed, status FROM Tarea;"
    }
    
    static var insSQLStatement: String {
        return "INSERT INTO Tarea (name, started, finished, elapsed, status) VALUES (?, ?, ?, ?, ?);"
    }
    
    static var updSQLStatement: String {
        return "UPDATE Tarea SET name = ?, started = ?, finished = ?, elapsed = ?, status = ? WHERE id = ?;"
    }
    
    static var delSQLStatement: String {
        return "DELETE FROM Tarea WHERE id = ?;"
    }
    
}


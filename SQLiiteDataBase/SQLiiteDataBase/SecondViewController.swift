//
//  SecondViewController.swift
//  SQLiiteDataBase
//
//  Created by Mac on 04/05/22.
//

import UIKit
import SQLite3

class SecondViewController: UIViewController {
    
    // MARK: Outlet
    @IBOutlet weak private var idTF: UITextField!
    @IBOutlet weak private var nameTF: UITextField!
    @IBOutlet weak private var phoneTF: UITextField!
    
    //MARK: VAriables
    private var dataBaseDetails: OpaquePointer?
    private var tableName = "Student"
    private var studentArray: Student?
   
    var dataPassClosure: (([Student]) -> Void)?
    
    // MARK: LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "SecVC"
        navigationItem.hidesBackButton = true
        guard let dbDetails = createAndOpenDB() else {
            print("Data Base Could not detected")
            return
        }
        self.dataBaseDetails = dbDetails
        createTableInDB(tableName: tableName)
    }
    
    
    // MARK: Save Action
    @IBAction private func saveButtonAction(){
        let id = idTF.text ?? ""
        let intId = Int(id) ?? 0
        let name = nameTF.text ?? ""
        let phoneNo = phoneTF.text ?? ""
        if ( intId == nil || name == "" || phoneNo == "" ){
          showAlert()
        }
        let alert = UIAlertController(title: "Data Save", message: "Successfull", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { UIAlertAction in
            let student = Student(id: intId, name: name, phoneNo: phoneNo)
            self.insertdataInDB(student: student)
        }))
        present(alert, animated: true)
    }
    
    @IBAction private func readButtonAction(){
        let studentArray1 = readDataFromDB()
        print(studentArray1)
        self.dataPassClosure!(studentArray1)
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: DataBase Methods
    private func fetchDocumentDirectoryURL() -> URL? {
        do {
            let documentDirectoryPath = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            return documentDirectoryPath
        } catch {
            print("Error is \(error.localizedDescription)")
            return nil
        }
    }
    
    
    private func fetchDataBasePath() -> String? {
        guard let ddPath = fetchDocumentDirectoryURL() else {
            return nil
        }
        let dataBasePath = ddPath.appendingPathComponent("infosys.sqlite")
        print("Data Base path created at \(dataBasePath.absoluteString)")
        return dataBasePath.absoluteString
    }
    
    private func createAndOpenDB() -> OpaquePointer? {
        let dbPath = fetchDataBasePath()
        var dbDetails: OpaquePointer?
        if  sqlite3_open(dbPath, &dbDetails) == SQLITE_OK {
            return dbDetails
        } else {
            return nil
        }
    }
    
    private func createTableInDB(tableName: String) {
        var createTableStatement: OpaquePointer? = nil
        let createTableQuery = "CREATE TABLE \(tableName)(ID INT PRIMARY KEY, Name TEXT, PhoneNumber TEXT)"
        if sqlite3_prepare_v2(self.dataBaseDetails, createTableQuery, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Create table query executed successfully")
            } else {
                print("Create Table Query not executed")
            }
        } else {
            print("Create table Query not prepared")
        }
    }
    
    private func insertdataInDB(student: Student) {
        var insertStatement:OpaquePointer? = nil
        let insertDataQuery = "INSERT INTO \(tableName)(ID, Name, PhoneNumber) VALUES (?, ?, ?)"
        if sqlite3_prepare_v2(self.dataBaseDetails, insertDataQuery, -1, &insertStatement, nil) == SQLITE_OK {
            // conert sqift data type to C data type
            let intId32 = Int32(student.id)
            let nameC = (student.name as NSString).utf8String
            let phoneC = (student.phoneNo as NSString).utf8String
            // bind the value to insert query
            sqlite3_bind_int(insertStatement, 1, intId32)
            sqlite3_bind_text(insertStatement, 2, nameC, -1, nil)
            sqlite3_bind_text(insertStatement, 3, phoneC, -1, nil)
            if   sqlite3_step(insertStatement) == SQLITE_DONE {
                print(" Insert Query Executed ")
            } else {
                print(" Insert Query not Executed ")
            }
        } else {
            print("Insert Query not prepared")
        }
    }

    private func readDataFromDB() -> [Student] {
        var array = [Student]()
        var readStatement: OpaquePointer? = nil
        let readQuery = "SELECT * FROM \(tableName)"
        if sqlite3_prepare_v2(self.dataBaseDetails, readQuery, -1, &readStatement, nil) == SQLITE_OK {
            while sqlite3_step(readStatement) == SQLITE_ROW {
            // read data from read Statement
            let idInt32 = sqlite3_column_int(readStatement, 0)
            let nameUTF = sqlite3_column_text(readStatement, 1)!
            let phoneUTF = sqlite3_column_text(readStatement, 2)!
            // covert to swift object
            let id = Int(idInt32)
            let name = String(cString: nameUTF)
            let phone = String(cString: phoneUTF)
                self.studentArray = Student(id: id, name: name, phoneNo: phone)
                array.append(studentArray!)
            }
        } else {
            print("read query not prepared")
        }
        return array
    }
}


extension SecondViewController {
    
    func showAlert(){
        let alert = UIAlertController(title: "Alert", message: "Fill All Information", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    func saveAlert(){
    }
}


//
//  ViewController.swift
//  SQLiiteDataBase
//
//  Created by Mac on 04/05/22.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: Outlet
    @IBOutlet weak var dataCollectionView: UICollectionView!
    
    // MARK: Variables
    var studentData: [Student] = []
    let studentarray: [Student] = []
    
    // MARK: LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "FirstVC"
        dataCollectionView.dataSource = self
        dataCollectionView.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(barButtonAction))
       
    }

    // MARK: Push Action
    @IBAction func barButtonAction(){
        guard let secVC = self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController") as? SecondViewController else {
            return
        }
        secVC.dataPassClosure = {(studentArray1) in
            for data in studentArray1 {
                let id = data.id
                let name = data.name
                let phone = data.phoneNo
                let student = Student(id: id, name: name, phoneNo: phone)
                self.studentData.append(student)
                self.dataCollectionView.reloadData()
            }
        }
        navigationController?.pushViewController(secVC, animated: true)
    }
}



// MARK: UICollectionViewDataSource Protocol
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if studentData.count == 0 {
            noDataToDisplay()
            return 0
        } else {
            dataCollectionView.backgroundView = nil
            return studentData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = self.dataCollectionView.dequeueReusableCell(withReuseIdentifier: "DataCell", for: indexPath) as? MyCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.idLabel.text = String(studentData[indexPath.row].id)
        cell.nameLabel.text = studentData[indexPath.row].name
        cell.phoeLabel.text = studentData[indexPath.row].phoneNo
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout Protocol
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: dataCollectionView.frame.size.width/2, height: dataCollectionView.frame.size.height/3)
    }
}


// MARK: No Data Display Function
extension ViewController {
    func noDataToDisplay() {
        let label: UILabel = UILabel()
        label.text = "No data to display"
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        dataCollectionView.backgroundView = label
    }
}

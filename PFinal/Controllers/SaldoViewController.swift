//
//  SaldoViewController.swift
//  PFinal
//
//  Created by Juan E. M. on 5/07/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage


class SaldoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        
//        Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("Combustible").observe(DataEventType.value, with: {(snapshot) in
//                    let snap = Snap()
//                    snap.imagenURL = (snapshot.value as! NSDictionary)["imagenURL"] as! String
//                    snap.from = (snapshot.value as! NSDictionary)["from"] as! String
//                    snap.descrip = (snapshot.value as! NSDictionary)["descripcion"] as! String
//                    snap.id = snapshot.key
//                    snap.imagenID = (snapshot.value as! NSDictionary)["imagenID"] as! String
//                    snap.audioURL = (snapshot.value as! NSDictionary)["audioURL"] as! String
//                    snap.audioID = (snapshot.value as! NSDictionary)["audioID"] as! String
//                    snap.audioNombre = (snapshot.value as! NSDictionary)["audioNombre"] as! String
//                    self.snaps.append(snap)
//                    self.tablaSnaps.reloadData()
//                })
//
//        Database.database().reference().child("usuario").child((Auth.auth().currentUser?.uid)!).child("snaps").observe(DataEventType.childAdded, with: {(snapshot) in
//                    let snap = Snap()
//                    snap.imagenURL = (snapshot.value as! NSDictionary)["imagenURL"] as! String
//                    snap.from = (snapshot.value as! NSDictionary)["from"] as! String
//                    snap.descrip = (snapshot.value as! NSDictionary)["descripcion"] as! String
//                    snap.id = snapshot.key
//                    snap.imagenID = (snapshot.value as! NSDictionary)["imagenID"] as! String
//                    snap.audioURL = (snapshot.value as! NSDictionary)["audioURL"] as! String
//                    snap.audioID = (snapshot.value as! NSDictionary)["audioID"] as! String
//                    snap.audioNombre = (snapshot.value as! NSDictionary)["audioNombre"] as! String
//                    self.snaps.append(snap)
//                    self.tablaSnaps.reloadData()
//                })
        
        
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    var sectionIsExpanded = [Bool](repeating: true, count: 3)
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        switch section {
        case 0:
            title = "Combustibles"
        case 1:
            title = "Peajes"
        case 2:
            title = "Otros"
        default:
            print("error")
        }
        return title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionIsExpanded[section] ? 10 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "hola"
        cell.detailTextLabel?.text = "descripcion"
        return cell
    }
    
    @objc func sectionHeaderTapped(_ recognizer: UITapGestureRecognizer) {
        guard let section = recognizer.view?.tag else { return }
        sectionIsExpanded[section] = !sectionIsExpanded[section]
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }

    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44))
        headerView.backgroundColor = .lightGray

        let headerLabel = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: 44))
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerLabel.textColor = .white
        headerLabel.backgroundColor = .clear
        headerLabel.font = UIFont.systemFont(ofSize: 14) // Ajusta el tamaño de la fuente según tus preferencias
        headerLabel.textAlignment = .left // Ajusta la alineación del texto según tus preferencias
        headerView.addSubview(headerLabel)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sectionHeaderTapped(_:)))
        headerView.addGestureRecognizer(tapGesture)
        headerView.tag = section

        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),
            headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15),
            headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])

        return headerView
    }






    
}

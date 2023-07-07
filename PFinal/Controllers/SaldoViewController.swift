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
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    var sectionIsExpanded = [Bool](repeating: true, count: 3)
    var registrosCombustibles:[Combustible] = []
    var registrosPeajes:[Peaje] = []
    var registrosOtros:[Otro] = []
    
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
        switch section {
        case 0:
            return sectionIsExpanded[section] ? registrosCombustibles.count : 0
        case 1:
            return sectionIsExpanded[section] ? registrosPeajes.count : 0
        case 2:
            return sectionIsExpanded[section] ? registrosOtros.count : 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "Nro. Factura:  \(registrosCombustibles[indexPath.row].factura) - Kilometraje:  \(registrosCombustibles[indexPath.row].km)"
            cell.detailTextLabel?.text = "Monto: S/.  \(registrosCombustibles[indexPath.row].monto)"
        case 1:
            cell.textLabel?.text = "Nro. Factura:  \(registrosPeajes[indexPath.row].factura) - Destino:  \(registrosPeajes[indexPath.row].destino)"
            cell.detailTextLabel?.text = "Monto: S/.  \(registrosPeajes[indexPath.row].monto)"
        case 2:
            cell.textLabel?.text = "Tipo documento:  \(registrosOtros[indexPath.row].tipodocumento) - Nro. documento:  \(registrosOtros[indexPath.row].numerodocumento)"
            cell.detailTextLabel?.text = "Monto: S/.  \(registrosOtros[indexPath.row].monto)"
        default:
            return cell
        }
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
    
    //Eliminación de registro
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
            return .delete
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                
                let alerta = UIAlertController(title: "Confirmación de eliminación", message: "¿Desea eliminar el registro?", preferredStyle: .alert)
                let btnOK = UIAlertAction(title: "Aceptar", style: .default, handler:{_ in
                    switch indexPath.section {
                    case 0:
                        let combustible = self.registrosCombustibles[indexPath.row]
                        self.eliminarRegistroCombustible(combustible)
                    case 1:
                        let peaje = self.registrosPeajes[indexPath.row]
                        self.eliminarRegistroPeajes(peaje)
                    case 2:
                        let otros = self.registrosOtros[indexPath.row]
                        self.eliminarRegistroOtros(otros)
                    default:
                        return
                    }
                    
                });
                alerta.addAction(btnOK)
                let btnCANCEL = UIAlertAction(title: "Cancelar", style: .default, handler: nil);
                alerta.addAction(btnCANCEL)
                present(alerta, animated: true, completion: nil)
                
                
            }
        }
    
    
    
    
    //Eliminar registros
    func eliminarRegistroCombustible(_ comb: Combustible) {
        Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("Combustible").child(comb.id).removeValue { (error, _) in
            if let error = error {
                print("Error al eliminar el registro de Combustible: \(error)")
                return
            }
            Storage.storage().reference().child("imagenes").child("combustible").child("factura").child("\(comb.urlfactura).jpg").delete { (error) in
                if let error = error {
                    print("Error al eliminar la imagen de factura: \(error)")
                    return
                }
                Storage.storage().reference().child("imagenes").child("combustible").child("km").child("\(comb.urlkm).jpg").delete { (error) in
                    if let error = error {
                        print("Error al eliminar la imagen de km: \(error)")
                        return
                    }
                    self.registrosCombustibles.removeAll { $0.id == comb.id }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func eliminarRegistroPeajes(_ peaje: Peaje) {
        Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("Peaje").child(peaje.id).removeValue { (error, _) in
            if let error = error {
                print("Error al eliminar el registro de peajes: \(error)")
                return
            }
            Storage.storage().reference().child("imagenes").child("peajes").child("\(peaje.urlfactura).jpg").delete { (error) in
                if let error = error {
                    print("Error al eliminar la imagen de factura: \(error)")
                    return
                }
                self.registrosPeajes.removeAll { $0.id == peaje.id }
                self.tableView.reloadData()
                
            }
        }
    }
    
    func eliminarRegistroOtros(_ otro: Otro) {
        Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("Otros").child(otro.id).removeValue { (error, _) in
            if let error = error {
                print("Error al eliminar el registro de otros: \(error)")
                return
            }
            Storage.storage().reference().child("imagenes").child("otros").child("\(otro.urlotros).jpg").delete { (error) in
                if let error = error {
                    print("Error al eliminar la imagen: \(error)")
                    return
                }
                Storage.storage().reference().child("audios").child("otros").child("\(otro.urldescripcion).m4a").delete { (error) in
                    if let error = error {
                        print("Error al eliminar audio: \(error)")
                        return
                    }
                    self.registrosOtros.removeAll { $0.id == otro.id }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    
    

    override func viewWillAppear(_ animated: Bool) {
        
        Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("Combustible").observe(.value) { (snapshot) in
            if let combustibleSnapshot = snapshot.value as? [String: Any], !combustibleSnapshot.isEmpty {
                self.registrosCombustibles.removeAll()
                for (key, value) in combustibleSnapshot {
                    if let combustibleData = value as? [String: Any],
                       let factura = combustibleData["factura"] as? String,
                       let km = combustibleData["km"] as? String,
                       let urlFactura = combustibleData["urlfactura"] as? String,
                       let urlKm = combustibleData["urlkm"] as? String,
                       let monto = combustibleData["monto"] as? String {
                        // Crea una instancia de Combustible y asigna los valores
                        let comb = Combustible()
                        comb.factura = factura
                        comb.km = km
                        comb.urlfactura = urlFactura
                        comb.urlkm = urlKm
                        comb.id = key
                        comb.monto = monto
                        
                        self.registrosCombustibles.append(comb)
                    }
                }
                
                self.tableView.reloadData()
            }
        }
        
        
        Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("Peaje").observe(.value) { (snapshot) in
            if let peajeSnapshot = snapshot.value as? [String: Any], !peajeSnapshot.isEmpty {
                self.registrosPeajes.removeAll()
                for (key, value) in peajeSnapshot {
                    if let peajeData = value as? [String: Any],
                       let factura = peajeData["factura"] as? String,
                       let urlFactura = peajeData["urlfactura"] as? String,
                       let monto = peajeData["monto"] as? String,
                       let destino = peajeData["destino"] as? String,
                       let destinolatitud = peajeData["destinolatitud"] as? String,
                       let destinolongitud = peajeData["destinolongitud"] as? String
                    {
                        let peaje = Peaje()
                        peaje.factura = factura
                        peaje.urlfactura = urlFactura
                        peaje.id = key
                        peaje.monto = monto
                        peaje.destino = destino
                        peaje.destinolatitud = destinolatitud
                        peaje.destinolongitud = destinolongitud
                        
                        self.registrosPeajes.append(peaje)
                    }
                }
                
                self.tableView.reloadData()
            }
        }
        
        
        
        Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("Otros").observe(.value) { (snapshot) in
            if let otroSnapshot = snapshot.value as? [String: Any], !otroSnapshot.isEmpty {
                self.registrosOtros.removeAll()
                for (key, value) in otroSnapshot {
                    if let otroData = value as? [String: Any],
                       let tipodocumento = otroData["tipodocumento"] as? String,
                       let numerodocumento = otroData["numerodocumento"] as? String,
                       let urldescripcion = otroData["urldescripcion"] as? String,
                       let urlotros = otroData["urlotros"] as? String,
                       let monto = otroData["monto"] as? String {
                        let otro = Otro()
                        otro.tipodocumento = tipodocumento
                        otro.numerodocumento = numerodocumento
                        otro.urldescripcion = urldescripcion
                        otro.urlotros = urlotros
                        otro.id = key
                        otro.monto = monto
                        
                        self.registrosOtros.append(otro)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
}

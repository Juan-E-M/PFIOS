//
//  UserViewController.swift
//  PFinal
//
//  Created by Juan E. M. on 24/06/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class UserViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let auth = Auth.auth()
    var userID: String?
    var option = 0
    var indexcargo = 0
    var options = [ "Trabajador de campo", "Supervisor", "Administrador"]
    var selectedOption = ""
    var cargo = ""
    var email = ""
    var user = ""
    
    @IBOutlet weak var txtNameUser: UITextField!
    @IBOutlet weak var txtEmailUser: UITextField!
    @IBOutlet weak var pickerRolUser: UIPickerView!
    @IBOutlet weak var btnSingOut: UIButton!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBAction func btnSingOutTapped(_ sender: Any) {
        if option == 0 {
            do {
                try Auth.auth().signOut()
                
                if let keyWindow = UIApplication.shared.keyWindow {
                    keyWindow.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                }
            } catch let error {
                print("Error al cerrar sesión: \(error.localizedDescription)")
            }
        }else{
            txtNameUser.isEnabled = false
            btnUpdate.setTitle("Editar", for: .normal)
            option = 0
            btnSingOut.setTitle("Cerrar Sesion", for: .normal)
            btnSingOut.backgroundColor = UIColor.red
            btnSingOut.setTitleColor(UIColor.white, for: .normal)
            pickerRolUser.isUserInteractionEnabled = false
            self.datos()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerRolUser.delegate = self
        pickerRolUser.dataSource = self
        txtNameUser.isEnabled = false
        txtEmailUser.isEnabled = false
        pickerRolUser.isUserInteractionEnabled = false
        selectedOption = options[0]
        //txtRoleUser.isEnabled = false
        self.getuser{ [weak self] user, email, cargo in
            DispatchQueue.main.async {
                self?.txtNameUser.text = user
                self?.txtEmailUser.text = email
                self?.pickerRolUser.reloadAllComponents()
                if let index = self?.options.firstIndex(of: cargo) {
                    self?.pickerRolUser.reloadAllComponents()
                    self?.pickerRolUser.selectRow(index, inComponent: 0, animated: false)
                    self?.indexcargo = index
                }else{
                    self?.pickerRolUser.selectRow(0, inComponent: 0, animated: false)
                }
                self?.user = user
                self?.email = email
            }
        }
        
        }
    func getuser(completion: @escaping (String, String, String) -> Void){
        if let currentUser = auth.currentUser {
            userID = currentUser.uid
            let database = Database.database().reference()
            let profileRef = database.child("usuarios").child(userID!).child("profile")

            profileRef.observeSingleEvent(of: .value) { snapshot in
                if let profileData = snapshot.value as? [String: Any],
                   let cargo = profileData["cargo"] as? String,
                   let email = profileData["email"] as? String,
                   let user = profileData["user"] as? String {
                    completion(user, email, cargo)
                }
            }
        } else {
            print("No se ha iniciado sesión")
        }
    }
    
    @IBAction func btnUpdateTapped(_ sender: Any) {
        if option == 0{
            btnSingOut.setTitle("Cancelar", for: .normal)
            btnSingOut.backgroundColor = UIColor.gray
            btnSingOut.setTitleColor(UIColor.black, for: .normal)
            txtNameUser.isEnabled = true
            btnUpdate.setTitle("Actualizar", for: .normal)
            pickerRolUser.isUserInteractionEnabled  = true
            option = 1
            self.datos()
        }else{
            let alerta = UIAlertController(title: "Actualizar", message: "¿Seguro que quiere guardar los cambios?", preferredStyle: .alert)
            let btnCancelar = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
            let btnCrear = UIAlertAction(title: "Acertar", style: .default, handler: { [weak self] _ in
                self?.btnUpdate.setTitle("Editar", for: .normal)
                self?.btnSingOut.setTitle("Cerrar Sesion", for: .normal)
                self?.btnSingOut.backgroundColor = UIColor.red
                self?.btnSingOut.setTitleColor(UIColor.white, for: .normal)
                self?.pickerRolUser.isUserInteractionEnabled = false
                self?.option = 0
                var dataUpdate = [
                    "user":self?.txtNameUser.text!,
                    "cargo":self?.selectedOption,
                ]
                let database = Database.database().reference()
                let profileRef = database.child("usuarios").child((self?.userID)!).child("profile")
                profileRef.updateChildValues(dataUpdate) { error, _ in
                    if let error = error {
                        print("Error al actualizar los datos: \(error.localizedDescription)")
                    } else {
                        let alerta = UIAlertController(title: "Actualizacion exitosa", message: "Se registraron los cambios conrrectamente", preferredStyle: .alert)
                        let btnOK = UIAlertAction(title: "Aceptar", style: .default, handler:nil )
                        alerta.addAction(btnOK)
                        self?.present(alerta, animated: true, completion: nil)
                    }
                }
            })

            alerta.addAction(btnCancelar)
            alerta.addAction(btnCrear)
            self.present(alerta, animated: true, completion: nil)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedOption = options[row]
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = options[row]
        label.textAlignment = .center
        return label
    }
    func datos(){
        txtNameUser.text = self.user
        txtEmailUser.text = self.email
        pickerRolUser.selectRow(self.indexcargo, inComponent: 0, animated: false)
    }

}

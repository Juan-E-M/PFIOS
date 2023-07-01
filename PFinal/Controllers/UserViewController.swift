//
//  UserViewController.swift
//  PFinal
//
//  Created by Juan E. M. on 24/06/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class UserViewController: UIViewController {

    let auth = Auth.auth()
    var userID: String?
    
    @IBOutlet weak var txtNameUser: UITextField!
    @IBOutlet weak var txtEmailUser: UITextField!
    @IBOutlet weak var txtRoleUser: UITextField!
    @IBOutlet weak var btnSingOut: UIButton!
    
    @IBAction func btnSingOutTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            
            if let keyWindow = UIApplication.shared.keyWindow {
                keyWindow.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            }
        } catch let error {
            print("Error al cerrar sesión: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
            super.viewDidLoad()
            txtNameUser.isEnabled = false
            txtEmailUser.isEnabled = false
            txtRoleUser.isEnabled = false

            if let currentUser = auth.currentUser {
                userID = currentUser.uid
                let database = Database.database().reference()
                let profileRef = database.child("usuarios").child(userID!).child("profile")

                profileRef.observeSingleEvent(of: .value) { snapshot in
                    if let profileData = snapshot.value as? [String: Any],
                       let cargo = profileData["cargo"] as? String,
                       let email = profileData["email"] as? String,
                       let user = profileData["user"] as? String {
                        self.txtNameUser.text = user
                        self.txtEmailUser.text = email
                        self.txtRoleUser.text = cargo
                    }
                }
            } else {
                print("No se ha iniciado sesión")
            }
        }
    

}

//
//  ViewController.swift
//  PFinal
//
//  Created by Juan E. M. on 10/06/23.
//

import UIKit
import FirebaseDatabase
import GoogleSignIn
import FirebaseStorage
import FirebaseAuth
import FirebaseCore

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }
    
    //OULETS
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginTapped(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!){(user, error) in print("Intentando iniciar sesiòn")
            if error != nil{
                print("Se presento el siguiente error: \(error)")
                let alerta = UIAlertController(title: "Error en el inicio de sesión", message: "El Usuario o contraseña son inválidos", preferredStyle: .alert)
                let btnCancelar = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
                let btnCrear = UIAlertAction(title: "Crear", style: .default, handler: nil /*{(UIAlertAction) in
                    self.performSegue(withIdentifier: "crearcuentasegue", sender: nil)
                    }*/
                )
                alerta.addAction(btnCancelar)
                alerta.addAction(btnCrear)
                self.present(alerta, animated: true, completion: nil)
            }else{
                print("Inicio de sesiòn exitoso")
                //self.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)
            }
        }
    }
    
    
    @IBAction func loginGoogleTapped(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) {[unowned self] result, error in
            guard error == nil else {
                return
            }
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Ocurrió un error: \(error)")
                    return
                } else {
                    print("Logeo por Google de forma correcta")
                    
                    guard let user = authResult?.user else {
                        return
                    }
                    var profile = [
                        "user": user.displayName,
                        "email": user.email,
                        "cargo": "Trabajador de campo",
                    ]
                    let ref = Database.database().reference().child("usuarios").child(user.uid).child("profile")
                    ref.setValue(profile) { (error, _) in
                        if let error = error {
                            print("Error al guardar los datos del usuario: \(error)")
                        } else {
                            print("Datos del usuario guardados exitosamente")
                        }
                    }
                    
                    
                }
            }
        }
    }
}


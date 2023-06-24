//
//  RegisterViewController.swift
//  PFinal
//
//  Created by Juan E. M. on 17/06/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase




class RegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    @IBAction func registerTapped(_ sender: Any) {
        if checkPassword(password: passwordTextField.text!, confirmPassword: confirmPasswordTextField.text!) {
            Auth.auth().createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: {(user,error) in
                if error != nil {
                    print("Se presento el error al crear el usuario:\(error)")
                }else{
                    print("El usuario se creo correctamente")
                    
                    Database.database().reference().child("usuarios").child(user!.user.uid).child("email").setValue(user!.user.email)
                    
                    let alerta = UIAlertController(title: "Successfull", message: "Usuario: \(self.emailTextField.text!) se creó correctamente.", preferredStyle: .alert)
                    let btnOK = UIAlertAction(title: "Aceptar", style: .default, handler: nil
                    /*{(UIAlertAction) in
                        self.performSegue(withIdentifier: "registrarusuariosegue", sender: nil)
                    }*/
                    )
                    alerta.addAction(btnOK)
                    self.present(alerta, animated: true, completion: nil)
                    
                }
            })
        } else {
            let alerta = UIAlertController(title: "Error", message: "Contraseñas no coinciden", preferredStyle: .alert)
            let btnCancelar = UIAlertAction(title: "Cancelar", style: .default, handler: nil
            /*{(UIAlertAction) in
                self.performSegue(withIdentifier: "registrarusuariosegue", sender: nil)
            }*/
            )
            alerta.addAction(btnCancelar)
            self.present(alerta, animated: true, completion: nil)
        }
        
    }
    
    func checkPassword(password: String, confirmPassword:String)-> Bool  {
        let arePasswordsEqual =  passwordTextField.text! == confirmPasswordTextField.text! ? true: false
        return arePasswordsEqual
    }

    

}

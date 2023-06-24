//
//  RegisterViewController.swift
//  PFinal
//
//  Created by Juan E. M. on 17/06/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase




class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //pickerView config
        cargoSelect.delegate = self
        cargoSelect.dataSource = self
        cargoSelect.reloadAllComponents()
        cargoSelect.selectRow(0, inComponent: 0, animated: false)
        selectedOption = options[0]
    }
    
    
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    @IBAction func registerTapped(_ sender: Any) {
        print(selectedOption)
        if checkPassword(password: passwordTextField.text!, confirmPassword: confirmPasswordTextField.text!) {
            Auth.auth().createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: {(user,error) in
                if error != nil {
                    print("Se presento el error al crear el usuario:\(error)")
                }else{
                    print("El usuario se creo correctamente")
                    
                    var profile = [
                        "user": self.userTextField.text!,
                        "email": self.emailTextField.text!,
                        "cargo": self.selectedOption,
                    ]
                    Database.database().reference().child("usuarios").child(user!.user.uid).child("profile").setValue(profile)

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
    
    //Funciones para el picker view
    @IBOutlet weak var cargoSelect: UIPickerView!
    var options = [ "Trabajador de campo", "Supervisor", "Administrador"]
    var selectedOption = ""
    
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


    

}

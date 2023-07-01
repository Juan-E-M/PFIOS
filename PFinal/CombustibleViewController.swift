//
//  CombustibleViewController.swift
//  PFinal
//
//  Created by Mac20 on 24/06/23.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import FirebaseDatabase

class CombustibleViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker2.delegate = self
    }
    var kmImageSelected: UIImage?
    var facturaImageSelected: UIImage?
    var imagePicker = UIImagePickerController()
    var imagePicker2 = UIImagePickerController()
    @IBOutlet weak var facturaTextField: UITextField!
    @IBOutlet weak var montoTotalTextField: UITextField!
    @IBOutlet weak var kmTextField: UITextField!
    @IBOutlet weak var kmImagemButton: UIButton!
    @IBOutlet weak var facturaImagenTextField: UIButton!
    var stateKmImage = false
    var imagenURLkm = ""
    var imagenURLfactura = ""
    let dispatchGroup = DispatchGroup()
    
    @IBAction func kmFotoTapped(_ sender: Any) {
        stateKmImage = true
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func facturaFotoTapped(_ sender: Any) {
        imagePicker2.sourceType = .savedPhotosAlbum
        imagePicker2.allowsEditing = false
        present(imagePicker2, animated: true, completion: nil)
    }
    
    @IBAction func enviarTapped(_ sender: Any) {
        if facturaTextField.text! != "" && montoTotalTextField.text! != "" && kmTextField.text! != "" && facturaImageSelected != nil && kmImageSelected != nil{
            enviardatos(facturaTextField.text! ,montoTotalTextField.text!,kmTextField.text!, kmImageSelected!,facturaImageSelected!)
            
//            //imagen km
//            let imagenesKmFolder = Storage.storage().reference().child("imagenes").child("combustible").child("km")
//            let imagenKmData =  kmImageSelected?.jpegData(compressionQuality: 0.5)
//            let cargarKmImagen = imagenesKmFolder.child("\(NSUUID().uuidString).jpg")
//
//            //imagen factura
//            let imagenesFacturaFolder = Storage.storage().reference().child("imagenes").child("combustible").child("factura")
//            let imagenFacturaData =  facturaImageSelected?.jpegData(compressionQuality: 0.5)
//            let cargarFacturaImagen = imagenesFacturaFolder.child("\(NSUUID().uuidString).jpg")
//
//            // Cargar imagen
//            let dispatchGroup = DispatchGroup()
//
//            dispatchGroup.enter()
//            cargarKmImagen.putData(imagenKmData!, metadata: nil) { (metadata, error) in
//                if let error = error {
//                    print("Ocurrió un error al subir imagen: \(error)")
//                    self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al subir la imagen. Verifique ", accion: "Aceptar")
//                } else {
//                    cargarKmImagen.downloadURL(completion: { (url, error) in
//                        if let url = url {
//                            self.imagenURLkm = url.absoluteString
//                        } else {
//                            print("Ocurrió un error al obtener la URL de la imagen subida: \(error)")
//                            self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al obtener información de la imagen", accion: "Cancelar")
//                        }
//                        dispatchGroup.leave()
//                    })
//                }
//            }
//            // Cargar imagen factura
//            dispatchGroup.enter()
//            cargarFacturaImagen.putData(imagenFacturaData!, metadata: nil) { (metadata, error) in
//                if let error = error {
//                    print("Ocurrió un error al subir imagen: \(error)")
//                    self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al subir la imagen. Verifique ", accion: "Aceptar")
//                } else {
//                    cargarFacturaImagen.downloadURL(completion: { (url, error) in
//                        if let url = url {
//                            self.imagenURLfactura = url.absoluteString
//                        } else {
//                            print("Ocurrió un error al obtener la URL de la imagen subida: \(error)")
//                            self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al obtener información de la imagen", accion: "Cancelar")
//                        }
//                        dispatchGroup.leave()
//                    })
//                }
//            }
//
//
//
//            // Esperando a que ambas promises se completen
//            dispatchGroup.notify(queue: .main) {
//                let datafuel = [
//                    "factura": self.facturaTextField.text!,
//                    "monto": self.montoTotalTextField.text!,
//                    "km": self.kmTextField.text!,
//                    "urlkm": self.imagenURLkm,
//                    "urlfactura": self.imagenURLfactura
//                ]
//                dispatchGroup.notify(queue: .main) {
//                    Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("Combustible").childByAutoId().setValue(datafuel)
//                }
//            }
//
        } else {
            self.mostrarAlertaEnvio(titulo: "Error", mensaje: "Complete todos los Campos. ", accion: "Aceptar")
        }
            
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if stateKmImage == true {
            let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            imagePicker.dismiss(animated: true, completion: nil)
            kmImageSelected = image
            kmImagemButton.setTitle("Seleccionada", for: .normal)
            stateKmImage = false
            print("NO DEBÍ ENTRAR")
        } else {
            let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            imagePicker2.dismiss(animated: true, completion: nil)
            facturaImageSelected = image
            facturaImagenTextField.setTitle("Seleccionada", for: .normal)
        }
    }
    
    func enviardatos(_ factura:String,_ monto:String,_ km:String ,_ imagenkm:UIImage,_ imagenfactura:UIImage){
        
        stateKmImage = true
        subirimagenes("km",imagenkm)
        stateKmImage = false
        subirimagenes("factura",imagenfactura)
        let datefueld = [
            "factura": factura,
            "monto": monto,
            "km": km,
            "urlkm": imagenURLkm,
            "urlfactura": imagenURLfactura,
        ]
        dispatchGroup.notify(queue: .main) {
            Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("Combustible").childByAutoId().setValue(datefueld)
        }
    }
    
    func mostrarAlerta (titulo: String, mensaje: String, accion: String){
            let alerta = UIAlertController(title: titulo, message: mensaje,
                                           preferredStyle: .alert )
            let btnCANCELOK = UIAlertAction(title: accion, style: .default, handler: nil)
            alerta.addAction(btnCANCELOK)
            present(alerta,  animated: true, completion: nil)
        }
    
    func mostrarAlertaEnvio (titulo: String, mensaje: String, accion: String){
            let alerta = UIAlertController(title: titulo, message: mensaje,
                                           preferredStyle: .alert )
            let btnCANCELOK = UIAlertAction(title: accion, style: .default, handler: nil)
            alerta.addAction(btnCANCELOK)
            present(alerta,  animated: true, completion: nil)
        }
    
    
    
    
    
    func subirimagenes (_ child:String,_ imagen:UIImage){
        
        let imagenesFolder = Storage.storage().reference().child("imagenes").child("combustible").child(child).child("\(NSUUID().uuidString).jpg")
        let imagenData =  imagen.jpegData(compressionQuality: 0.5)
        dispatchGroup.enter()
        let cargarImagen = imagenesFolder.putData(imagenData!, metadata: nil) { (metadata, error) in
            if error != nil {
                self.mostrarAlerta(titulo: "Error", mensaje: "Se produj un error al subir la imagen. Verifique ", accion: "Aceptar")
                
                print("Ocurrió un error al subir imagen: \(error)")
            } else {
                if self.stateKmImage == true {
                    imagenesFolder.downloadURL(completion: { (url, error) in
                        if let url = url {
                            self.imagenURLkm = url.absoluteString
                            print("URL de la imagen subida: \(self.imagenURLkm)")
                        } else {
                            print("Ocurrió un error al obtener la URL de la imagen subida: \(error)")
                            self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al obtener información de la imagen", accion: "Cancelar")
                            
                        }
                        self.dispatchGroup.leave()
                    })
                } else {
                    imagenesFolder.downloadURL(completion: { (url, error) in
                        if let url = url {
                            self.imagenURLfactura = url.absoluteString
                            print("URL de la imagen subida: \(self.imagenURLfactura)")
                        } else {
                            print("Ocurrió un error al obtener la URL de la imagen subida: \(error)")
                            self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al obtener información de la imagen22", accion: "Cancelar")
                            
                        }
                        self.dispatchGroup.leave()
                    })
                }
                
            }
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

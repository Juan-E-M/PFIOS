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
    
    var imagePicker = UIImagePickerController()
    var imagePicker2 = UIImagePickerController()
    @IBOutlet weak var facturaTextField: UITextField!
    @IBOutlet weak var montoTotalTextField: UITextField!
    @IBOutlet weak var kmTextField: UITextField!
    @IBOutlet weak var kmImageButton: UIButton!
    @IBOutlet weak var facturaImageButton: UIButton!
    @IBOutlet weak var BtnEnviar: UIButton!
    var stateKmImage = false
    var kmImageSelected: UIImage?
    var facturaImageSelected: UIImage?
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
            facturaTextField.isEnabled = false
            montoTotalTextField.isEnabled = false
            kmTextField.isEnabled = false
            kmImageButton.isEnabled = false
            facturaImageButton.isEnabled = false
            BtnEnviar.isEnabled = false
            let dispatchGroup = DispatchGroup()
            uploadImagesToStorage("km", kmImageSelected!, dispatchGroup) { imageURLkm,imagenKMID in
                self.uploadImagesToStorage("factura", self.facturaImageSelected!, dispatchGroup) { imageURLfactura, imagenFacturaID in
                    self.uploadDataToDatabase(imageURLkm, imageURLfactura,imagenFacturaID, imagenKMID)
                }
            }
        } else {
            self.mostrarAlertaEnvio(titulo: "Error", mensaje: "Complete todos los Campos. ", accion: "Aceptar")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if stateKmImage == true {
            let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            imagePicker.dismiss(animated: true, completion: nil)
            kmImageSelected = image
            kmImageButton.setTitle("Seleccionado", for: .normal)
            stateKmImage = false
        } else {
            let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            imagePicker2.dismiss(animated: true, completion: nil)
            facturaImageSelected = image
            facturaImageButton.setTitle("Seleccionado", for: .normal)
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
    
    func uploadImagesToStorage(_ child: String, _ imagen: UIImage, _ dispatchGroup: DispatchGroup, completion: @escaping (String?,String?) -> Void) {
        let imagenID = NSUUID().uuidString
        let imagenesFolder = Storage.storage().reference().child("imagenes").child("combustible").child(child).child("\(imagenID).jpg")
        let imagenData = imagen.jpegData(compressionQuality: 0.5)
        
        dispatchGroup.enter()
        imagenesFolder.putData(imagenData!, metadata: nil) { (metadata, error) in
            if let error = error {
                self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al subir la imagen. Verifique ", accion: "Aceptar")
                print("Ocurrió un error al subir imagen: \(error)")
                completion(nil,nil)
            } else {
                imagenesFolder.downloadURL(completion: { (url, error) in
                    if let url = url {
                        let imageURL = url.absoluteString
                        print("URL de la imagen subida: \(imageURL)")
                        completion(imageURL,imagenID)
                    } else if let error = error{
                        print("Ocurrió un error al obtener la URL de la imagen subida: \(error)")
                        self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al obtener información de la imagen", accion: "Cancelar")
                        completion(nil,nil)
                    }
                })
            }
            
            dispatchGroup.leave()
        }
    }
    
    func uploadDataToDatabase(_ imageURLkm: String?, _ imageURLfactura: String?, _ idimagenfactura: String?, _ idimagenkm:String?) {
        let dataFuel: [String: Any] = [
            "factura": self.facturaTextField.text!,
            "monto": self.montoTotalTextField.text!,
            "km": self.kmTextField.text!,
            "urlkm": imageURLkm ?? "",
            "urlfactura": imageURLfactura ?? "",
            "idimagenfactura":idimagenfactura ?? "",
            "idimagenkm":idimagenkm ?? "",
        ]
        let ref = Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("Combustible").childByAutoId()
        ref.setValue(dataFuel) { (error, _) in
            if let error = error {
                print("Ocurrió un error al registrar el gasto de combustible: \(error)")
                self.mostrarAlerta(titulo: "Error", mensaje: "No se pudo registrar el gasto de combustible. Verifique", accion: "Aceptar")
                self.Habilitar()
            } else {
                print("Registro de gasto de combustible exitoso")
                let alerta = UIAlertController(title: "Registro exitoso", message: "Registro de gasto combustible de forma exitosa", preferredStyle: .alert)
                self.resetOriginalValues()
                let btnOK = UIAlertAction(title: "Aceptar", style: .default, handler: {(UIAlertAction) in
                    self.Habilitar()
                })
                alerta.addAction(btnOK)
                self.present(alerta, animated: true, completion: nil)
            }
        }
    }
    
    func resetOriginalValues () {
        self.facturaTextField.text = ""
        self.montoTotalTextField.text = ""
        self.kmTextField.text = ""
        self.kmImageSelected = nil
        self.facturaImageSelected = nil
        self.imagenURLkm = ""
        self.imagenURLfactura = ""
        self.kmImageButton.setTitle("Tomar Foto", for: .normal)
        self.facturaImageButton.setTitle("Tomar Foto", for: .normal)
    }
    
    func Habilitar() {
        self.facturaTextField.isEnabled = true
        self.montoTotalTextField.isEnabled = true
        self.kmTextField.isEnabled = true
        self.kmImageButton.isEnabled = true
        self.facturaImageButton.isEnabled = true
        self.BtnEnviar.isEnabled = true
    }
}

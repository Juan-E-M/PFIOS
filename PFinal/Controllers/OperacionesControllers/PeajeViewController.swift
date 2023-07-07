//
//  PeajeViewController.swift
//  PFinal
//
//  Created by Mac20 on 24/06/23.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class PeajeViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, MapViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }
    var imagePicker = UIImagePickerController()
    var facturaImageSelected : UIImage?
    var imagenURLfactura = ""
    let dispatchGroup = DispatchGroup()
    var destinationname = ""
    var destinationlat = ""
    var destinationlon = ""
    
    @IBOutlet weak var TextFactura: UITextField!
    @IBOutlet weak var TextMonto: UITextField!
    @IBOutlet weak var BtnTextImageFactura: UIButton!
    @IBAction func BtnEnviarPeaje(_ sender: Any) {
        
        print(destinationname)
        print(destinationlat)
        print(destinationlon)
        
        /*
        if TextFactura.text! != "" && TextMonto.text! != "" && facturaImageSelected != nil {
            
            let dispatchGroup = DispatchGroup()
            uploadImagesToStorage( self.facturaImageSelected!, dispatchGroup) { imageURLfactura in
                    self.uploadDataToDatabase( imageURLfactura)
                }
            
        } else {
            self.mostrarAlertaEnvio(titulo: "Error", mensaje: "Complete todos los Campos. ", accion: "Aceptar")
        }*/
    }
    
    @IBAction func BtnImagen(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        facturaImageSelected = image
        imagePicker.dismiss(animated: true, completion: nil)
        BtnTextImageFactura.setTitle("Seleccionada", for: .normal)
    }
    
    func mostrarAlertaEnvio (titulo: String, mensaje: String, accion: String){
            let alerta = UIAlertController(title: titulo, message: mensaje,
                                           preferredStyle: .alert )
            let btnCANCELOK = UIAlertAction(title: accion, style: .default, handler: nil)
            alerta.addAction(btnCANCELOK)
            present(alerta,  animated: true, completion: nil)
    }
    
    func mostrarAlerta (titulo: String, mensaje: String, accion: String){
            let alerta = UIAlertController(title: titulo, message: mensaje,
                                           preferredStyle: .alert )
            let btnCANCELOK = UIAlertAction(title: accion, style: .default, handler: nil)
            alerta.addAction(btnCANCELOK)
            present(alerta,  animated: true, completion: nil)
    }
    
    func uploadImagesToStorage(_ imagen: UIImage, _ dispatchGroup: DispatchGroup, completion: @escaping (String?) -> Void) {
        let imagenesFolder = Storage.storage().reference().child("imagenes").child("peajes").child("\(NSUUID().uuidString).jpg")
        let imagenData = imagen.jpegData(compressionQuality: 0.5)
        
        dispatchGroup.enter()
        imagenesFolder.putData(imagenData!, metadata: nil) { (metadata, error) in
            if let error = error {
                self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al subir la imagen. Verifique ", accion: "Aceptar")
                print("Ocurrió un error al subir imagen: \(error)")
                completion(nil)
            } else {
                imagenesFolder.downloadURL(completion: { (url, error) in
                    if let url = url {
                        let imageURL = url.absoluteString
                        print("URL de la imagen subida: \(imageURL)")
                        completion(imageURL)
                    } else if let error = error{
                        print("Ocurrió un error al obtener la URL de la imagen subida: \(error)")
                        self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al obtener información de la imagen", accion: "Cancelar")
                        completion(nil)
                    }
                })
            }
            
            dispatchGroup.leave()
        }
    }
    
    func uploadDataToDatabase(_ imageURLfactura: String?) {
        let dataFuel: [String: Any] = [
            "factura": self.TextFactura.text!,
            "monto": self.TextMonto.text!,
            "urlfactura": imageURLfactura ?? ""
        ]
        let ref = Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("peajes").childByAutoId()
        ref.setValue(dataFuel) { (error, _) in
            if let error = error {
                print("Ocurrió un error al registrar el gasto de peaje: \(error)")
                self.mostrarAlerta(titulo: "Error", mensaje: "No se pudo registrar el gasto de peaje. Verifique", accion: "Aceptar")
            } else {
                print("Registro de gasto de peaje exitoso")
                let alerta = UIAlertController(title: "Registro exitoso", message: "Registro de gasto peaje de forma exitosa", preferredStyle: .alert)
                let btnOK = UIAlertAction(title: "Aceptar", style: .default, handler: {(UIAlertAction) in
                    self.resetOriginalValues()
                })
                alerta.addAction(btnOK)
                self.present(alerta, animated: true, completion: nil)
            }
        }
    }
    
    func resetOriginalValues () {
        self.TextFactura.text = ""
        self.TextMonto.text = ""
        self.facturaImageSelected = nil
        self.imagenURLfactura = ""
        self.BtnTextImageFactura.setTitle("Tomar Foto", for: .normal)
    }
    
    @IBAction func irMapaTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "mapsegue", sender: nil)
    }
    func didSelectDestination(destinationName: String, latitude: String, longitude: String) {
        destinationname = destinationName
        destinationlat = latitude
        destinationlon = longitude
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapsegue" {
            if let mapViewController = segue.destination as? MapViewController {
                mapViewController.delegate = self
            }
        }
    }
    
}

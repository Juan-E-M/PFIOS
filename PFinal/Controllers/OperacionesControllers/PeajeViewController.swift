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
    @IBOutlet weak var BtnEnviar: UIButton!
    @IBOutlet weak var BtnMapa: UIButton!
    @IBAction func BtnEnviarPeaje(_ sender: Any) {
        if TextFactura.text! != "" && TextMonto.text! != "" && destinationname != "" && destinationlat != "" && destinationlon != "" && facturaImageSelected != nil {
            TextFactura.isEnabled = false
            TextMonto.isEnabled = false
            BtnEnviar.isEnabled = false
            BtnMapa.isEnabled = false
            BtnTextImageFactura.isEnabled = false
            let dispatchGroup = DispatchGroup()
            uploadImagesToStorage( self.facturaImageSelected!, dispatchGroup) { imageURLfactura, imagenID in
                    self.uploadDataToDatabase( imageURLfactura,imagenID)
                }
        } else {
            self.mostrarAlertaEnvio(titulo: "Error", mensaje: "Complete todos los Campos. ", accion: "Aceptar")
        }
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
        BtnTextImageFactura.setTitle("Seleccionado", for: .normal)
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
    
    func uploadImagesToStorage(_ imagen: UIImage, _ dispatchGroup: DispatchGroup, completion: @escaping (String?,String?) -> Void) {
        let imagenID = NSUUID().uuidString
        let imagenesFolder = Storage.storage().reference().child("imagenes").child("peajes").child("\(imagenID).jpg")
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
    
    func uploadDataToDatabase(_ imageURLfactura: String?,_ imagenID:String?) {
        let dataFuel: [String: Any] = [
            "factura": self.TextFactura.text!,
            "monto": self.TextMonto.text!,
            "destino":destinationname,
            "destinolatitud":destinationlat,
            "destinolongitud":destinationlon,
            "urlfactura": imageURLfactura ?? "",
            "idpeaje": imagenID ?? "",
        ]
        let ref = Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("Peaje").childByAutoId()
        ref.setValue(dataFuel) { (error, _) in
            if let error = error {
                print("Ocurrió un error al registrar el gasto de peaje: \(error)")
                self.mostrarAlerta(titulo: "Error", mensaje: "No se pudo registrar el gasto de peaje. Verifique", accion: "Aceptar")
                self.Habilitar()
            } else {
                print("Registro de gasto de peaje exitoso")
                let alerta = UIAlertController(title: "Registro exitoso", message: "Registro de gasto peaje de forma exitosa", preferredStyle: .alert)
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
        self.TextFactura.text = ""
        self.TextMonto.text = ""
        self.facturaImageSelected = nil
        self.imagenURLfactura = ""
        self.destinationname = ""
        self.destinationlat = ""
        self.destinationlon = ""
        self.BtnTextImageFactura.setTitle("Tomar Foto", for: .normal)
        self.BtnMapa.setTitle("Ir a Mapa", for: .normal)
    }
    
    func Habilitar() {
        self.TextFactura.isEnabled = true
        self.TextMonto.isEnabled = true
        self.BtnEnviar.isEnabled = true
        self.BtnMapa.isEnabled = true
        self.BtnTextImageFactura.isEnabled = true
    }
    
    @IBAction func irMapaTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "mapsegue", sender: nil)
    }
    func didSelectDestination(destinationName: String, latitude: String, longitude: String) {
        destinationname = destinationName
        destinationlat = latitude
        destinationlon = longitude
        self.BtnMapa.setTitle("Seleccionado", for: .normal)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapsegue" {
            if let mapViewController = segue.destination as? MapViewController {
                mapViewController.delegate = self
            }
        }
    }
    
}

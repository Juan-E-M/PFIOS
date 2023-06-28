//
//  PeajeViewController.swift
//  PFinal
//
//  Created by Mac20 on 24/06/23.
//

import UIKit
import FirebaseStorage

class PeajeViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }
    var imagePicker = UIImagePickerController()
    var selected :UIImage?
    @IBOutlet weak var TextFactura: UITextField!
    
    @IBOutlet weak var galeria: UIImageView!
    @IBAction func BtnEnviarPeaje(_ sender: Any) {
        let imagenesFolder = Storage.storage().reference().child("imagenes")
        let imagenData =  imagen.jpegData(compressionQuality: 0.5)
        let cargarImagen = imagenesFolder.child("\(NSUUID().uuidString).jpg").putData(imagenData!, metadata: nil) { (metadata, error) in
                    if error != nil {
                        self.mostrarAlerta(titulo: "Error", mensaje: "Se produj un error al subir la imagen. Verifique ", accion: "Aceptar")
                        
                        print("Ocurrió un error al subir imagen: \(error)")
                    } else {
                        print("Todo salio bien")
                    }
                }
    }
    @IBAction func BtnImagen(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        selected = image
        print("========================")
        print(selected?.size)
        imagePicker.dismiss(animated: true, completion: nil)
    }
    func enviardatos(_ imagen:UIImage){
        galeria.image = imagen
        let imagenesFolder = Storage.storage().reference().child("imagenes")
        let imagenData =  imagen.jpegData(compressionQuality: 0.5)
        let cargarImagen = imagenesFolder.child("\(NSUUID().uuidString).jpg").putData(imagenData!, metadata: nil) { (metadata, error) in
                    if error != nil {
                        self.mostrarAlerta(titulo: "Error", mensaje: "Se produj un error al subir la imagen. Verifique ", accion: "Aceptar")
                        
                        print("Ocurrió un error al subir imagen: \(error)")
                    } else {
        
                    }
                    }
    }
    
    func mostrarAlerta (titulo: String, mensaje: String, accion: String){
            let alerta = UIAlertController(title: titulo, message: mensaje,
                                           preferredStyle: .alert )
            let btnCANCELOK = UIAlertAction(title: accion, style: .default, handler: nil)
            alerta.addAction(btnCANCELOK)
            present(alerta,  animated: true, completion: nil)
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

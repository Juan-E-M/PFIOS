//
//  CombustibleViewController.swift
//  PFinal
//
//  Created by Mac20 on 24/06/23.
//

import UIKit
import FirebaseCore
import FirebaseStorage
import FirebaseDatabase

class CombustibleViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagenPicker.delegate = self
        
        
        
    }
    var kmImageSelected: UIImage?
    var imagenPicker = UIImagePickerController()
    @IBOutlet weak var facturaTextField: UITextField!
    @IBOutlet weak var montoTotalTextField: UITextField!
    @IBOutlet weak var kmTextField: UITextField!
    @IBOutlet weak var kmImagemButton: UIButton!
    @IBOutlet weak var facturaImagenTextField: UIButton!
    
    
    @IBAction func kmFotoTapped(_ sender: Any) {
        imagenPicker.sourceType = .savedPhotosAlbum
        imagenPicker.allowsEditing = false
        present(imagenPicker, animated: true, completion: nil)
    }
    @IBAction func facturaFotoTapped(_ sender: Any) {
        
    }
    
    @IBAction func enviarTapped(_ sender: Any) {
        let imagenesFolder = Storage.storage().reference().child("imagenes").child("combustible")
        let imagenData =  kmImageSelected!.jpegData(compressionQuality: 0.5)
        let cargarImagen = imagenesFolder.child("\(NSUUID().uuidString).jpg").putData(imagenData!, metadata: nil) { (metadata, error) in
            if error != nil {
                
                print("Ocurrió un error al subir imagen: \(error)")
            } else {
                print("todo fue exitoso")
            }
        }
            
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        kmImageSelected = image
        imagenPicker.dismiss(animated: true, completion: nil)
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

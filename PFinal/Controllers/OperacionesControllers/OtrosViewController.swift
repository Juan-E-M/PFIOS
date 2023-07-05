//
//  OtrosViewController.swift
//  PFinal
//
//  Created by Mac20 on 24/06/23.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class OtrosViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let options = ["Opción 1", "Opción 2", "Opción 3"]
    var TextTypeDocument = ""
    var imagePicker = UIImagePickerController()
    var otrosImageSelected : UIImage?
    var imagenURLOtros = ""
    let dispatchGroup = DispatchGroup()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Número de columnas en el selector
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count // Número de filas en el selector
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row] // Texto para cada fila
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        TextTypeDocument = options[row] // Obtiene el valor seleccionado
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = options[row]
        label.textAlignment = .center
        return label
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerViewDoc.delegate = self
        pickerViewDoc.dataSource = self
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }
    
    
    @IBOutlet weak var TextDocument: UITextField!
    @IBOutlet weak var TextMonto: UITextField!
    @IBOutlet weak var BtnImages: UIButton!
    @IBOutlet weak var pickerViewDoc: UIPickerView!
    @IBOutlet weak var pickerViewAutorizacion: UIPickerView!
    
    @IBAction func BtnGrabarDescription(_ sender: Any) {
        
    }
    
    @IBAction func BtnImagesOtros(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func EnviarOtros(_ sender: Any) {
        if TextDocument.text! != "" && TextMonto.text! != "" && otrosImageSelected != nil && TextTypeDocument != ""{
            
            let dispatchGroup = DispatchGroup()
            uploadImagesToStorage( self.otrosImageSelected!, dispatchGroup) { imageURLfactura in
                    self.uploadDataToDatabase( imageURLfactura)
                }
            
        } else {
            self.mostrarAlertaEnvio(titulo: "Error", mensaje: "Complete todos los Campos. ", accion: "Aceptar")
        }
    }
    
    func uploadImagesToStorage(_ imagen: UIImage, _ dispatchGroup: DispatchGroup, completion: @escaping (String?) -> Void) {
        let imagenesFolder = Storage.storage().reference().child("imagenes").child("otros").child("\(NSUUID().uuidString).jpg")
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
            "TipoDocument": self.TextTypeDocument,
            "NroDocument": self.TextDocument.text!,
            "Monto Total": self.TextMonto.text!,
            "urlotros": imageURLfactura ?? ""
        ]
        let ref = Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("otros").childByAutoId()
        ref.setValue(dataFuel) { (error, _) in
            if let error = error {
                print("Ocurrió un error al registrar el gasto de otros: \(error)")
                self.mostrarAlerta(titulo: "Error", mensaje: "No se pudo registrar el gasto de otros. Verifique", accion: "Aceptar")
            } else {
                print("Registro de gasto de otros exitoso")
                let alerta = UIAlertController(title: "Registro exitoso", message: "Registro de gasto otros de forma exitosa", preferredStyle: .alert)
                let btnOK = UIAlertAction(title: "Aceptar", style: .default, handler: {(UIAlertAction) in
                    self.resetOriginalValues()
                })
                alerta.addAction(btnOK)
                self.present(alerta, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        otrosImageSelected = image
        imagePicker.dismiss(animated: true, completion: nil)
        BtnImages.setTitle("Seleccionada", for: .normal)
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
    
    func resetOriginalValues () {
        self.TextDocument.text = ""
        self.TextMonto.text = ""
        self.otrosImageSelected = nil
        self.imagenURLOtros = ""
        self.BtnImages.setTitle("Tomar Foto", for: .normal)
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

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
import AVFoundation

class OtrosViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let options = ["Dni", "Pasaparte", "C. de Extranjeria"]
    let options2 = ["Juan Escobar", "Luis Paucar", "Junior Molina", "Cristofer Rodriguez"]
    var TextTypeDocument = ""
    var TextAutorizacion = ""
    var imagePicker = UIImagePickerController()
    var otrosImageSelected : UIImage?
    var imagenURLOtros = ""
    let dispatchGroup = DispatchGroup()
    var statuspicker = false
    
    var audioURL = ""
    var audioLocalURL:URL?
    var grabarAudio: AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Número de columnas en el selector
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerViewDoc {
                // Retorna el número de elementos para pickerView1
            return options.count
        } else if pickerView == pickerViewAutorizacion {
                // Retorna el número de elementos para pickerView2
            return options2.count
        }
            
        return 0
//        return options.count // Número de filas en el selector
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerViewDoc {
                // Retorna el título para la fila en pickerView1 en la posición 'row'
            return options[row]
        } else if pickerView == pickerViewAutorizacion {
                // Retorna el título para la fila en pickerView2 en la posición 'row'
            return options2[row]
        }
            
            return nil
//        return options[row] // Texto para cada fila
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        TextTypeDocument = options[pickerViewDoc.selectedRow(inComponent: 0)]
        TextAutorizacion = options2[pickerViewAutorizacion.selectedRow(inComponent: 0)]
    }
    
//    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//        var fontSize: CGFloat = 17.0 // Tamaño de fuente predeterminado
//            
//            if pickerView == pickerViewDoc {
//                fontSize = 40.0 // Tamaño de fuente para el `pickerViewDoc`
//            } else if pickerView == pickerViewAutorizacion {
//                fontSize = 10.0 // Tamaño de fuente para el `pickerViewAutorizacion`
//            }
//            
//            let title: String
//            if pickerView == pickerViewDoc {
//                title = options[row]
//            } else if pickerView == pickerViewAutorizacion {
//                title = options2[row]
//            } else {
//                title = ""
//            }
//            
//            let attributedString = NSMutableAttributedString(string: title)
//            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: fontSize), range: NSRange(location: 0, length: attributedString.length))
//            
//            return attributedString
//    }
    
    
//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerViewDoc.delegate = self
        pickerViewDoc.dataSource = self
        
        
        pickerViewAutorizacion.delegate = self
        pickerViewAutorizacion.dataSource = self
        
        imagePicker.delegate = self
        configurarGrabacion()
        // Do any additional setup after loading the view.
    }
    
    
    @IBOutlet weak var TextDocument: UITextField!
    @IBOutlet weak var TextMonto: UITextField!
    @IBOutlet weak var BtnImages: UIButton!
    @IBOutlet weak var pickerViewDoc: UIPickerView!
    @IBOutlet weak var pickerViewAutorizacion: UIPickerView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    @IBAction func playTapped(_ sender: Any) {
        do{
            try reproducirAudio = AVAudioPlayer(contentsOf: audioLocalURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
        } catch {}
    }
    @IBAction func BtnGrabarDescription(_ sender: Any) {
        if grabarAudio!.isRecording {
            grabarAudio?.stop()
            recordButton.setTitle("Grabar", for: .normal)
            playButton.isEnabled = true
        }else{
            grabarAudio?.record()
            recordButton.setTitle("Detener", for: .normal)
            playButton.isEnabled = false
        }
    }
    
    @IBAction func BtnImagesOtros(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func EnviarOtros(_ sender: Any) {
        if TextDocument.text! != "" && TextMonto.text! != "" && otrosImageSelected != nil && TextTypeDocument != "" && TextAutorizacion != "" && audioLocalURL != nil{
            
            let dispatchGroup = DispatchGroup()
            uploadImagesToStorage( self.otrosImageSelected!, dispatchGroup) { imagenurl in self.uploadAudioToStorage() { audioURL in
                    self.uploadDataToDatabase(imagenurl,audioURL )
                }
            }
            
        } else {
            self.mostrarAlertaEnvio(titulo: "Error", mensaje: "Complete todos los Campos. ", accion: "Aceptar")
        }
    }
    
    func configurarGrabacion(){
        do{
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode:AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask,true).first!
            let pathComponents = [basePath,"audio.m4a"]
            audioLocalURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            grabarAudio = try AVAudioRecorder(url:audioLocalURL!, settings: settings)
            grabarAudio!.prepareToRecord()
        }catch let error as NSError{
            print(error)
        }
    }
    
    func uploadAudioToStorage(completion: @escaping (String?) -> Void) {
        let audiosFolder = Storage.storage().reference().child("audios").child("otros")
        let audioData = try? Data(contentsOf: self.audioLocalURL!)
        let uploadAudio = audiosFolder.child("\(NSUUID().uuidString).m4a")
        
        uploadAudio.putData(audioData!, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Ocurrió un error al subir el audio: \(error)")
                self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al subir el audio. Verifique ", accion: "Aceptar")
                completion(nil)
            } else {
                uploadAudio.downloadURL { (url, error) in
                    if let url = url {
                        let audioURL = url.absoluteString
                        print("URL del audio subido: \(self.audioURL)")
                        completion(audioURL)
                    } else if let error = error{
                        print("Ocurrió un error al obtener la URL del audio subido: \(error)")
                        self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al obtener información del audio", accion: "Cancelar")
                        completion(nil)
                    }
                    
                }
            }
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
    
    func uploadDataToDatabase(_ imageURLfactura: String?,_ audioURL: String?) {
        let dataFuel: [String: Any] = [
            "tipodocumento": self.TextTypeDocument,
            "numerodocumento": self.TextDocument.text!,
            "autorizacion": self.TextAutorizacion,
            "monto": self.TextMonto.text!,
            "urlotros": imageURLfactura ?? "",
            "urldescripcion" : audioURL ?? "",
        ]
        let ref = Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("Otros").childByAutoId()
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

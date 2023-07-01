//
//  TrasladoViewController.swift
//  PFinal
//
//  Created by Mac20 on 24/06/23.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase
import AVFoundation


class TrasladoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        
    }
    

    @IBOutlet weak var siteTextField: UITextField!
    @IBOutlet weak var nroTextField: UITextField!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    var audioURL = ""
    var audioLocalURL:URL?
    var grabarAudio: AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    
    @IBAction func enviarTapped(_ sender: Any) {
        if siteTextField.text! != "" && nroTextField.text! != "" && audioLocalURL != nil{
            uploadAudioToStorage() { audioURL in
                self.uploadDataToDatabase(audioURL)
            }
        } else {
            self.mostrarAlertaEnvio(titulo: "Error", mensaje: "Complete todos los Campos. ", accion: "Aceptar")
        }
    }
    
    
    @IBAction func recordTapped(_ sender: Any) {
        if grabarAudio!.isRecording {
            grabarAudio?.stop()
            recordButton.setTitle("Grabar Audio", for: .normal)
            playButton.isEnabled = true
        }else{
            grabarAudio?.record()
            recordButton.setTitle("Detener", for: .normal)
            playButton.isEnabled = false
        }
    }
    @IBAction func playTapped(_ sender: Any) {
        do{
            try reproducirAudio = AVAudioPlayer(contentsOf: audioLocalURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
        } catch {}
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
        let audiosFolder = Storage.storage().reference().child("audios").child("traslados")
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
    
    func uploadDataToDatabase(_ audioURL: String?) {
        let dataFuel: [String: Any] = [
            "sitio": self.siteTextField.text!,
            "nro": self.nroTextField.text!,
            "urlComentario": audioURL ?? "",
        ]
        let ref = Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("traslado").childByAutoId()
        ref.setValue(dataFuel) { (error, _) in
            if let error = error {
                print("Ocurrió un error al registrar el gasto de traslado: \(error)")
                self.mostrarAlerta(titulo: "Error", mensaje: "No se pudo registrar el gasto de traslado. Verifique", accion: "Aceptar")
            } else {
                print("Registro de gasto de traslado exitoso")
                let alerta = UIAlertController(title: "Registro exitoso", message: "Registro de gasto traslado de forma exitosa", preferredStyle: .alert)
                let btnOK = UIAlertAction(title: "Aceptar", style: .default, handler: {(UIAlertAction) in
                    self.resetOriginalValues()
                })
                alerta.addAction(btnOK)
                self.present(alerta, animated: true, completion: nil)
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
    
    func mostrarAlertaEnvio (titulo: String, mensaje: String, accion: String){
            let alerta = UIAlertController(title: titulo, message: mensaje,
                                           preferredStyle: .alert )
            let btnCANCELOK = UIAlertAction(title: accion, style: .default, handler: nil)
            alerta.addAction(btnCANCELOK)
            present(alerta,  animated: true, completion: nil)
        }
    
    func resetOriginalValues () {
        self.siteTextField.text = ""
        self.nroTextField.text = ""
        self.audioURL = ""
    }

}

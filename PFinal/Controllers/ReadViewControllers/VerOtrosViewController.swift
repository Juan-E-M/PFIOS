//
//  VerOtrosViewController.swift
//  PFinal
//
//  Created by Juan E. M. on 8/07/23.
//

import UIKit
import SDWebImage
import AVFoundation

class VerOtrosViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        montoLabel.text = "Monto: S/. \(otro.monto)"
        autorizacionLabel.text = "Autorización: \(otro.autorizacion)"
        tipodocumentoLabel.text = "Tipo de documento: \(otro.tipodocumento)"
        nrodocumentoLabel.text = "Nro. documento: \(otro.numerodocumento)"
        imageView.sd_setImage(with: URL(string: otro.urlotros), completed: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    @IBOutlet weak var montoLabel: UILabel!
    @IBOutlet weak var autorizacionLabel: UILabel!
    @IBOutlet weak var tipodocumentoLabel: UILabel!
    @IBOutlet weak var nrodocumentoLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var reproducirButton: UIButton!
    
    var player: AVPlayer?
    var timer: Timer?
    var startTime: Date?
    
    
    var otro = Otro()
    
    @IBAction func reproducirTapped(_ sender: Any) {
        guard let audioURL = URL(string: otro.urldescripcion) else {
            mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al reproducir el audio", accion: "Aceptar")
            return
        }
        
        player = AVPlayer(url: audioURL)
        player?.play()
        
        startTimer()
    }
    
    func startTimer() {
        startTime = Date()
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTimerLabel()
        }
    }
    
    func updateTimerLabel() {
        guard let startTime = startTime else {
            return
        }
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        let minutes = Int(elapsedTime / 60)
        let seconds = Int(elapsedTime.truncatingRemainder(dividingBy: 60))
        let timeString = String(format: "%02d:%02d", minutes, seconds)
        lblTimer.text = timeString
    }
    
    @objc func playerDidFinishPlaying() {
        timer?.invalidate()
        lblTimer.text = "00:00"
    }
    
    func mostrarAlerta(titulo: String, mensaje: String, accion: String) {
            let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
            let btnAceptar = UIAlertAction(title: accion, style: .default, handler: nil)
            alerta.addAction(btnAceptar)
            present(alerta, animated: true, completion: nil)
        }
}

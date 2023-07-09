//
//  VerPeajeViewController.swift
//  PFinal
//
//  Created by Juan E. M. on 8/07/23.
//

import UIKit

class VerPeajeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        montoLabel.text = "Monto: S/. \(peaje.monto)"
        facturaLabel.text = "Factura: \(peaje.factura)"
        destinoLabel.text = "Destino: \(peaje.destino)"
        longitudLabel.text = "Longitud: \(peaje.destinolongitud)"
        latitudLabel.text = "Latitud: \(peaje.destinolatitud)"
        
        facturaImageView.sd_setImage(with: URL(string: peaje.urlfactura), completed: nil)
        
    }
    
    var peaje = Peaje()
    @IBOutlet weak var montoLabel: UILabel!
    @IBOutlet weak var facturaLabel: UILabel!
    @IBOutlet weak var latitudLabel: UILabel!
    @IBOutlet weak var longitudLabel: UILabel!
    @IBOutlet weak var destinoLabel: UILabel!
    @IBOutlet weak var facturaImageView: UIImageView!
    

}

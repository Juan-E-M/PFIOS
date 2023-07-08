//
//  VerCombustibleViewController.swift
//  PFinal
//
//  Created by Juan E. M. on 8/07/23.
//

import UIKit
import SDWebImage

class VerCombustibleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        montoLabel.text = "Monto: S/. \(combustible.monto)"
        facturaLabel.text = "Factura: \(combustible.factura)"
        facturaImageView.sd_setImage(with: URL(string: combustible.urlfactura), completed: nil)
        kmLabel.text = "Kilometraje: \(combustible.km)"
        kmImageView.sd_setImage(with: URL(string: combustible.urlkm), completed: nil)
    }
    
    
    @IBOutlet weak var montoLabel: UILabel!
    @IBOutlet weak var facturaLabel: UILabel!
    @IBOutlet weak var kmLabel: UILabel!
    @IBOutlet weak var facturaImageView: UIImageView!
    @IBOutlet weak var kmImageView: UIImageView!
    
    
    var combustible = Combustible()
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

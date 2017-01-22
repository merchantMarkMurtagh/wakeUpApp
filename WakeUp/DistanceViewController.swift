//
//  DistanceViewController.swift
//  WakeUp
//
//  Created by Mark Murtagh on 22/11/2016.
//  Copyright © 2016 MAVM. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
class DistanceViewController: UIViewController {

    var radiuz = 0.0
    var selected : MKPlacemark? = nil
    @IBOutlet weak var labl: UILabel!
    @IBOutlet weak var sldr: UISlider!
    
    @IBAction func slider(_ sender: UISlider)
    {
        labl.text = String(sender.value)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    @IBAction func setVal(_ sender: UIButton) {
        radiuz = Double(labl.text!)!
        
        //print(radiuz)
        sldr.isEnabled=false
        performSegue(withIdentifier: "backToMap", sender: radiuz)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {//
        if(segue.identifier=="backToMap")
        {
            let mapVC:ViewController=segue.destination as! ViewController
            let data = radiuz
            mapVC.locationPicked=true
            mapVC.radiuz=data
            mapVC.printPin=selected
            
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  ViewController.swift
//  OVLocationTagger
//
//  Created by Onur Var on 10/02/2017.
//  Copyright (c) 2017 Onur Var. All rights reserved.
//

import UIKit
import OVLocationTagger

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnStopTapped(_ sender: Any) {
        OVLocationTagger.shared.stopTagger()
    }
    
    @IBAction func btnStartTapped(_ sender: Any) {
        OVLocationTagger.shared.startTagger()
    }
    
    @IBAction func btnTriggerTapped(_ sender: Any) {
        OVLocationTagger.shared.triggerTagger()
    }
    
    
}


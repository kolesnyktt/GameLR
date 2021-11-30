//
//  StartViewController.swift
//  GameLR
//
//  Created by Taras Kolesnyk on 30.11.2021.
//

import UIKit

class StartViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create image
        let image = UIImage(named: "startButtonImage")
        
        let button = UIButton()
        button.frame = CGRect(x: view.frame.size.width/2, y: view.frame.size.height/2, width: 200, height: 80)
        button.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        button.setBackgroundImage(image, for: UIControl.State.normal)
        button.addTarget(self, action:#selector(self.imageButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @objc func imageButtonTapped(_ sender:UIButton!)
    {
        performSegue(withIdentifier: "goGame", sender: nil)
    }
    
}

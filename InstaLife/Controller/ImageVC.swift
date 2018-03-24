//
//  ImageVC.swift
//  InstaLife
//
//  Created by SherifShokry on 3/17/18.
//  Copyright © 2018 SherifShokry. All rights reserved.
//

import UIKit

class ImageVC: UIViewController , UIGestureRecognizerDelegate {

    @IBOutlet weak var image: UIImageView!
    var photo : UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
       image.image = photo!
        doubleTap()
        // Do any additional setup after loading the view.
    }

    func doubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(closeVC))
            doubleTap.numberOfTapsRequired = 2
            doubleTap.delegate = self
         self.view.addGestureRecognizer(doubleTap)
    }
    @objc func closeVC(){
        dismiss(animated: true, completion: nil)
    }


}

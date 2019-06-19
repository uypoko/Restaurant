//
//  OrderConfirmationViewController.swift
//  Restaurant
//
//  Created by Ryan on 6/19/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import UIKit

class OrderConfirmationViewController: UIViewController {

    var minutes: Int!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        timeLabel.text = "Thank you for your order! Your wait time is approximately \(minutes!)."
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

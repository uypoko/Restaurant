//
//  MenuItemDetailViewController.swift
//  Restaurant
//
//  Created by Ryan on 6/19/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import UIKit

class MenuItemDetailViewController: UIViewController {

    var menuItem: MenuItem?
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var addToOrderButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addToOrderButton.layer.cornerRadius = 5.0
        updateUI()
    }
    
    func updateUI() {
        guard let menuItem = menuItem else { return }
        title = menuItem.name
        nameLabel.text = menuItem.name
        priceLabel.text = String(format: "$ %.2f", menuItem.price)
        detailLabel.text = menuItem.detailText
        MenuController.shared.fetchImage(url: menuItem.imageURL) { (image) in
            guard let image = image else { return }
            DispatchQueue.main.async {
                self.imgView.image = image
            }
        }
    }

    @IBAction func orderButtonTapped(_ sender: Any) {
        guard let menuItem = menuItem else { return }
        UIView.animate(withDuration: 0.3) {
            self.addToOrderButton.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
            self.addToOrderButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        MenuController.shared.order.menuItems.append(menuItem)
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        guard let menuItem = menuItem else { return }
        coder.encode(menuItem.id, forKey: "menuItemId")
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        let menuItemId = Int(coder.decodeInt32(forKey: "menuItemId"))
        menuItem = MenuController.shared.item(withId: menuItemId)
        updateUI()
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

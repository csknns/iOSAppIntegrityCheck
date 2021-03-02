//
//  ViewController.swift
//  IntegrityCheck
//
//  Created by Christos Koninis on 1/21/21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isJailBroken() {
            let alertController = UIAlertController(title: "You device is Jailbroken", message: "", preferredStyle: .alert)

            let OKAction = UIAlertAction(title: "Bye", style: .default) { (action) in
                abort()
            }
            alertController.addAction(OKAction)

            self.present(alertController, animated: true)
        }
    }

    @objc dynamic func isJailBroken() -> Bool {
        return true
    }
}


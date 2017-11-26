//
//  DetailVC.swift
//  DemoCoreData
//
//  Created by HoangLuyen on 11/23/17.
//  Copyright © 2017 HoangLuyen. All rights reserved.
//

import UIKit

class DetailVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nameTextField: UITextField!
    var detailItem: Person? {
        didSet {
            configureView()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        configureView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func configureView() {
        if let detail = detailItem {
            if let label = nameTextField {
                label.text = detail.name?.description
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        updatePerson()
    }
    //MARK: - Update data
    func updatePerson() {
        if let person = detailItem {
            person.name = nameTextField.text ?? ""
            AppDelegate.shared.saveContext()
        }
        navigationController?.popViewController(animated: true)
    }
}

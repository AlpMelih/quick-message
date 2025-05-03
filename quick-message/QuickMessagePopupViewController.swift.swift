import UIKit
import ContactsUI

protocol QuickMessagePopupViewControllerDelegate: AnyObject {
    func saveQuickMessage(phoneNumber: String, message: String)
}

class QuickMessagePopupViewController: UIViewController, CNContactPickerDelegate {

    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var messageTextField: UITextField!  // UITextView yerine UITextField
    @IBOutlet weak var saveButton: UIButton!
    
    weak var delegate: QuickMessagePopupViewControllerDelegate?
    
    var selectedPhoneNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
    }
    
    @IBAction func selectPhoneNumberTapped(_ sender: UIButton) {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        present(contactPicker, animated: true, completion: nil)
    }
    
    // Rehberden telefon numarası seçildiğinde
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
            selectedPhoneNumber = phoneNumber
            phoneNumberLabel.text = phoneNumber
            saveButton.isEnabled = true
        }
    }
    
    @IBAction func saveMessageTapped(_ sender: UIButton) {
        guard let phoneNumber = selectedPhoneNumber, let message = messageTextField.text, !message.isEmpty else {
            return
        }
        
        // Veriyi delegate ile ana ekrana gönder
        delegate?.saveQuickMessage(phoneNumber: phoneNumber, message: message)
        dismiss(animated: true, completion: nil)
    }
}

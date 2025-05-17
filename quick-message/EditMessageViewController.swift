import UIKit

class EditMessageViewController: UIViewController {
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    
    var quickMessage: QuickMessage?
    var messageIndex: Int!
    
    // Düzenleme sonrası veriyi geri göndermek için closure
    var onSave: ((QuickMessage) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mevcut mesaj bilgilerini göster
        if let quickMessage = quickMessage {
            phoneNumberTextField.text = quickMessage.phoneNumber
            messageTextView.text = quickMessage.message
        }
    }
    
    // Storyboard'daki Kaydet butonuna bu IBAction'ı bağla
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let updatedPhone = phoneNumberTextField.text,
              let updatedMessage = messageTextView.text,
              !updatedPhone.isEmpty,
              !updatedMessage.isEmpty else {
            // Gerekirse uyarı verilebilir
            let alert = UIAlertController(title: "Eksik Bilgi", message: "Lütfen numara ve mesajı doldurun.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
            return
        }
        
        let updatedQuickMessage = QuickMessage(phoneNumber: updatedPhone, message: updatedMessage)
        
        // Değişiklikleri closure ile geri gönder
        onSave?(updatedQuickMessage)
        
        // Bu sayfayı kapat (geri git)
        navigationController?.popViewController(animated: true)
    }
}

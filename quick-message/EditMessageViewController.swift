import UIKit
import ContactsUI

class EditMessageViewController: UIViewController, CNContactPickerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var selectPhoneNumberButton: UIButton!
    @IBOutlet weak var messagePickerView: UIPickerView!
    
    var quickMessage: QuickMessage?
    var messageIndex: Int!
    
    var onSave: ((QuickMessage) -> Void)?
    
    let predefinedMessages = [
        "Merhaba, nasılsın?",
        "Toplantıya biraz gecikeceğim.",
        "Seni sonra arayacağım.",
        "Şu anda meşgulüm, sonra konuşalım.",
        "Yoldayım, az kaldı.",
        "Uygun olduğunda beni ara lütfen.",
        "Bugün görüşebilir miyiz?",
        "Teşekkür ederim!",
        "İyi çalışmalar.",
        "Toplantıyı yarına erteleyebilir miyiz?",
        "Görüşme saatimiz hala geçerli mi?",
        "Adres bilgilerini paylaşabilir misin?",
        "Bugün çok yoğunum, yarın konuşalım mı?",
        "Randevuyu unutmamak için yazıyorum.",
        "Lütfen bana konum atar mısın?",
        "E-postanı aldım, en kısa sürede döneceğim.",
        "İşim biter bitmez seni arayacağım.",
        "Az önce seni düşündüm :)",
        "Birlikte kahve içelim mi?",
        "Geç kaldım, özür dilerim.",
        "Doğum günün kutlu olsun! Pastayı unutmamışsındır umarım 😄",
        "Yeni yaşında bol bol kahkaha ve biraz da mantık diliyorum 😂",
        "Nice yıllara! Hediye yok ama mesaj var 😅",
        "Halı sahaya geliyorum, kaleci var mı?",
        "Bugün yine Messi modundayım, ayakkabıları getirdim!",
        "Kadroyu tamamladık mı, ben forma almam 😎",
        "Parti saat kaçta başlıyor? Dans ayakkabılarım hazır!",
        "Evde mi eğleniyoruz, yoksa dışarda mı coşuyoruz?",
        "Kimin playlist’i? Lütfen bu sefer slow çalma 🙏",
        "Telefon elimde patladı, yanlış kişiye mesaj atmadım umarım 😬",
        "Dünya dönüyor ama ben hâlâ ayaktayım 💫",
        "Kahve içmeden kimseyle konuşmuyorum. Nokta.",
        "Günaydın mı diyeyim, geçmiş olsun mu bilemedim 🙃"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Picker ayarları
        messagePickerView.delegate = self
        messagePickerView.dataSource = self
        
        messageTextView.delegate = self
        messageTextView.layer.borderColor = UIColor.lightGray.cgColor
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.cornerRadius = 6
        messageTextView.isScrollEnabled = true
        
        if let quickMessage = quickMessage {
            phoneNumberTextField.text = quickMessage.phoneNumber
            messageTextView.text = quickMessage.message
        }
    }
    
    @IBAction func selectPhoneNumberTapped(_ sender: UIButton) {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        present(contactPicker, animated: true)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
            phoneNumberTextField.text = phoneNumber
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let updatedPhone = phoneNumberTextField.text,
              let updatedMessage = messageTextView.text,
              !updatedPhone.isEmpty,
              !updatedMessage.isEmpty else {
            let alert = UIAlertController(title: "Eksik Bilgi", message: "Lütfen numara ve mesajı doldurun.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
            return
        }
        
        let updatedQuickMessage = QuickMessage(phoneNumber: updatedPhone, message: updatedMessage)
        onSave?(updatedQuickMessage)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - PickerView
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return predefinedMessages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return predefinedMessages[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        messageTextView.text = predefinedMessages[row]
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // Burada karakter sayısını sınırlandırmak istersen ekleyebilirsin
    }
}

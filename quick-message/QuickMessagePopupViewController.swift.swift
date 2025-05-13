import UIKit
import ContactsUI

protocol QuickMessagePopupViewControllerDelegate: AnyObject {
    func saveQuickMessage(phoneNumber: String, message: String)
}

class QuickMessagePopupViewController: UIViewController, CNContactPickerDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!   // UITextView olarak güncellendi
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var messagePickerView: UIPickerView!

    weak var delegate: QuickMessagePopupViewControllerDelegate?

    var selectedPhoneNumber: String?

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

        saveButton.isEnabled = false

        messageTextView.delegate = self
        messageTextView.layer.borderColor = UIColor.lightGray.cgColor
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.cornerRadius = 6
        messageTextView.isScrollEnabled = true

        messagePickerView.delegate = self
        messagePickerView.dataSource = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func selectPhoneNumberTapped(_ sender: UIButton) {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        present(contactPicker, animated: true, completion: nil)
    }

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
            selectedPhoneNumber = phoneNumber
            phoneNumberLabel.text = phoneNumber
            saveButton.isEnabled = true
        }
    }

    @IBAction func saveMessageTapped(_ sender: UIButton) {
        guard let phoneNumber = selectedPhoneNumber,
              let message = messageTextView.text,
              !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        delegate?.saveQuickMessage(phoneNumber: phoneNumber, message: message)
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UIPickerView Data Source

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return predefinedMessages.count
    }

    // MARK: - UIPickerView Delegate

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return predefinedMessages[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedMessage = predefinedMessages[row]
        messageTextView.text = selectedMessage
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        saveButton.isEnabled = !(textView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }
}

import UIKit
import MessageUI

struct QuickMessage: Codable {
    var phoneNumber: String
    var message: String
}

class ViewController: UIViewController, UITableViewDataSource, QuickMessagePopupViewControllerDelegate, UITableViewDelegate, MFMessageComposeViewControllerDelegate {
    
   
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var NewQuickMessageButton: UIButton!
    var selectedIndex: Int?
    var selectedMessage: QuickMessage?
    
    var quickMessages: [QuickMessage] = [] // Kaydedilen mesajlar için veri kaynağı
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TableView.delegate = self
        TableView.rowHeight = 160 // Buradan kontrol
       
        // Hücreyi storyboard'dan kaydettik, ek register gerekmeyebilir
        quickMessages = getSavedQuickMessages()
        TableView.reloadData() // Tabloyu ilk yüklemede güncelle
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "toEditVC" {
               if let editVC = segue.destination as? EditMessageViewController,
                  let message = selectedMessage,
                  let index = selectedIndex {
                   editVC.quickMessage = message
                   editVC.messageIndex = index
                   editVC.onSave = { [weak self] updatedMessage in
                       guard let self = self else { return }
                       self.quickMessages[index] = updatedMessage
                       self.saveQuickMessages()
                       self.TableView.reloadData()
                   }
               }
           }
       }

    // Yeni mesaj ekleme butonu aksiyonu
    @IBAction func newQuickMessageButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let popupVC = storyboard.instantiateViewController(withIdentifier: "QuickMessagePopupViewController") as? QuickMessagePopupViewController {
            popupVC.delegate = self // Delegate'i ayarla
            present(popupVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - QuickMessagePopupViewControllerDelegate
    func saveQuickMessage(phoneNumber: String, message: String) {
        let newMessage = QuickMessage(phoneNumber: phoneNumber, message: message)
        quickMessages.append(newMessage) // Yeni mesajı diziye ekle
        saveQuickMessages() // UserDefaults'a kaydet
        TableView.reloadData() // Tabloyu güncelle
    }
    
    // MARK: - UserDefaults İşlemleri
    public func saveQuickMessages() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(quickMessages)
            UserDefaults.standard.set(data, forKey: "QuickMessages")
        } catch {
            print("Hata: Mesajlar kaydedilemedi - \(error)")
        }
    }
    
    private func getSavedQuickMessages() -> [QuickMessage] {
        if let data = UserDefaults.standard.data(forKey: "QuickMessages") {
            do {
                let decoder = JSONDecoder()
                let messages = try decoder.decode([QuickMessage].self, from: data)
                return messages
            } catch {
                print("Hata: Mesajlar yüklenemedi - \(error)")
            }
        }
        return []
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quickMessages.count // Satır sayısı, quickMessages dizisinin uzunluğu
    }
    
    func openWhatsApp(phoneNumber: String, message: String) {
        let formattedNumber = phoneNumber.replacingOccurrences(of: "+", with: "").replacingOccurrences(of: " ", with: "")
        let urlString = "https://wa.me/\(formattedNumber)?text=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            let alert = UIAlertController(title: "WhatsApp Yok", message: "WhatsApp yüklü değil veya numara geçersiz.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
        }
    }
    
    func sendSMS(phoneNumber: String, message: String) {
        if MFMessageComposeViewController.canSendText() {
            let messageVC = MFMessageComposeViewController()
            messageVC.recipients = [phoneNumber]
            messageVC.body = message
            messageVC.messageComposeDelegate = self // Burada delegate olarak ViewController'ı atıyoruz
            present(messageVC, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Hata", message: "Bu cihaz SMS gönderemiyor.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
        }
    }

    // MFMessageComposeViewControllerDelegate metodu
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuickMessageCell", for: indexPath) as! QuickMessageCell
        let message = quickMessages[indexPath.row]
        
        // Bu satır, tüm içeriği doğru şekilde ayarlar
        cell.configureCell(with: message)
        
        // Butonlara tag atamayı yine yap
        cell.deleteButton.tag = indexPath.row
        cell.sendButton.tag = indexPath.row
        cell.smsButton.tag = indexPath.row
        cell.editButton.tag = indexPath.row
        
        return cell
    }
     
        func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            return 16 // 16pt boşluk
        }

        func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            let spacerView = UIView()
            spacerView.backgroundColor = .clear // Saydam boşluk
            return spacerView
        }
}

class QuickMessageCell: UITableViewCell {
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!  // messageLabel yerine messageTextView
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var smsButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    // Delete button action
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        if let viewController = findViewController() as? ViewController {
            let index = sender.tag
            viewController.quickMessages.remove(at: index)
            viewController.saveQuickMessages()
            viewController.TableView.reloadData()
        }
    }
    
    // Send button action
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        if let viewController = findViewController() as? ViewController {
            let index = sender.tag
            let message = viewController.quickMessages[index]
            viewController.openWhatsApp(phoneNumber: message.phoneNumber, message: message.message)
        }
    }
    
    // Send SMS button action
    @IBAction func senSMSButtonTapped(_ sender: UIButton) {
        if let viewController = findViewController() as? ViewController {
            let index = sender.tag
            let message = viewController.quickMessages[index]
            
            // SMS göndermek için metot çağırma
            viewController.sendSMS(phoneNumber: message.phoneNumber, message: message.message)
        }
    }
    @IBAction func editButtonTapped(_ sender: UIButton) {
           if let viewController = findViewController() as? ViewController {
               let index = sender.tag
               let message = viewController.quickMessages[index]
               
               // Geçici olarak seçilen mesaj ve index'i sakla
               viewController.selectedIndex = index
               viewController.selectedMessage = message
               
               // Segue tetikle
               viewController.performSegue(withIdentifier: "toEditVC", sender: nil)
           }
       }



    
    // ViewController'ı bulmak için yardımcı metod
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let vc = responder as? UIViewController {
                return vc
            }
            responder = responder?.next
        }
        return nil
    }
    
    // Hücreyi yeniden kullanmak için mesaj metnini güncelle
    func configureCell(with message: QuickMessage) {
        phoneNumberLabel.text = message.phoneNumber
        messageTextView.text = message.message  // messageLabel yerine textView'e metin atama
        messageTextView.isEditable = false
            messageTextView.isSelectable = true
    }
}

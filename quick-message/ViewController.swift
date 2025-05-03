import UIKit

class ViewController: UIViewController, UITableViewDataSource, QuickMessagePopupViewControllerDelegate {
    struct QuickMessage: Codable {
        var phoneNumber: String
        var message: String
    }
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var NewQuickMessageButton: UIButton!
    
    var quickMessages: [QuickMessage] = [] // Kaydedilen mesajlar için veri kaynağı
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TableView.dataSource = self
        // Hücreyi storyboard'dan kaydettik, ek register gerekmeyebilir
        quickMessages = getSavedQuickMessages()
        TableView.reloadData() // Tabloyu ilk yüklemede güncelle
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuickMessageCell", for: indexPath) as! QuickMessageCell
        let message = quickMessages[indexPath.row]
        
        // Hücre içeriğini doldur
        cell.phoneNumberLabel.text = "NUMARA : \(message.phoneNumber)"
        cell.messageLabel.text = "MESAJ : \(message.message)"
        cell.deleteButton.tag = indexPath.row
        cell.sendButton.tag = indexPath.row
        
        return cell
    }
}

// Özel Hücre Sınıfı (Storyboard ile bağlanacak)
class QuickMessageCell: UITableViewCell {
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        if let viewController = findViewController() as? ViewController {
            let index = sender.tag
            viewController.quickMessages.remove(at: index)
            viewController.saveQuickMessages()
            viewController.TableView.reloadData()
        }
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        if let viewController = findViewController() as? ViewController {
            let index = sender.tag
            let message = viewController.quickMessages[index]
            print("Mesaj gönderiliyor: \(message.phoneNumber) - \(message.message)")
            // Burada mesajı gönderme mantığını implement edebilirsin
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
}

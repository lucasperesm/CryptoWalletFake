import Foundation
import CoreData
import Combine
import CryptoKit

class LoginViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLogged: Bool = false
    @Published var errorMessage: String = ""

    func login(context: NSManagedObjectContext) {

        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Preencha todos os campos"
            return
        }

        let request = NSFetchRequest<NSManagedObject>(entityName: "User")
        
        let encryptedPassword = hashPassword(password)
        
        request.predicate = NSPredicate(
            format: "email == %@ AND password == %@",
            email,
            encryptedPassword
        )

        do {
            let resultado = try context.fetch(request)

            if resultado.count > 0 {
                isLogged = true
                errorMessage = ""
            } else {
                errorMessage = "Login ou senha inválidos"
            }

        } catch {
            errorMessage = "Erro ao autenticar"
            print("Erro Core Data: \(error)")
        }
    }
    
    private func hashPassword(_ text: String) -> String {
        let inputData = Data(text.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

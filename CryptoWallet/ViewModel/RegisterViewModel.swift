import Foundation
import CoreData
import Combine
import CryptoKit
 
class RegisterViewModel: ObservableObject {
 
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var sucess = false
 
    func cadastrar(context: NSManagedObjectContext) {
 
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Preencha todos os campos"
            return
        }
 
        let request = NSFetchRequest<User>(entityName: "User")
        request.predicate = NSPredicate(format: "email == %@", email)
 
        do {
            let resultado = try context.fetch(request)
 
            if resultado.count > 0 {
                errorMessage = "Email já cadastrado"
                return
            }
 
            let newUser = User(context: context)
            newUser.name = name
            newUser.email = email
            newUser.password = hashPassword(password)
            if newUser.entity.attributesByName["fiatBalance"] != nil {
                newUser.setValue(1074.32, forKey: "fiatBalance")
            }
 
            try context.save()
 
            sucess = true
            errorMessage = ""
 
        } catch {
            errorMessage = "Erro ao cadastrar"
            print(error)
        }
    }
   
    private func hashPassword(_ text: String) -> String {
        let inputData = Data(text.utf8)
        let hashed = SHA256.hash(data: inputData)
       
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

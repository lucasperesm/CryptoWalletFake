import Foundation
import CoreData
import Combine

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
        
        request.predicate = NSPredicate(
            format: "email == %@ AND senha == %@",
            email,
            password
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
}

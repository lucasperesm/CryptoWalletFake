import Foundation
import CoreData
import Combine

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
            newUser.password = password

            try context.save()

            sucess = true
            errorMessage = ""

        } catch {
            errorMessage = "Erro ao cadastrar"
            print(error)
        }
    }
}

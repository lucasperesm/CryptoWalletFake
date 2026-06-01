import SwiftUI

struct AppBackground<Content: View>: View {
    
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Color(red: 31/255, green: 31/255, blue: 31/255)
            
            Ellipse()
                .fill(
                    Color(red: 99/255, green: 57/255, blue: 249/255)
                        .opacity(0.25)
                )
                .frame(width: 300, height: 400)
                .blur(radius: 120)
                .offset(x: 140, y: -200)
            
            Ellipse()
                .fill(
                    Color(red: 99/255, green: 57/255, blue: 249/255)
                        .opacity(0.25)
                )
                .frame(width: 350, height: 450)
                .blur(radius: 140)
                .offset(x: -160, y: 250)
            
            content
        }
        .ignoresSafeArea()
    }
}

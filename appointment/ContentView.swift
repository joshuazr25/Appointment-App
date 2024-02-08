import SwiftUI

struct ContentView: View {
    @State private var showLoginScreen = false
    @State private var showSignUpScreen = false

    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                
                NavigationLink(
                    destination: LoginView(),
                    isActive: $showLoginScreen,
                    label: {
                        Text("Login/Sign up")
                            .multilineTextAlignment(.center)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .position(.init(x: 175,y: 275))
                    })

                
            }
            .padding()
            .navigationBarTitle("Appointment", displayMode: .large)
                .background(Color(UIColor(hex: "332bc2")))
        }
    }
}

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var loginCount: Int = 0
    @State private var isLoggedIn: Bool = false

    @State private var showError = false

    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Login/Sign up") {
                if username == "JZR" && password == "123" {
                    loginCount += 1
                    isLoggedIn = true
                } else {
                    showError = true
                    username = ""
                    password = ""
                }
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
            .fullScreenCover(isPresented: $isLoggedIn) {
                GridView()
            }
            .alert(isPresented: $showError) {
                // Show alert for incorrect username or password
                Alert(title: Text("Error"), message: Text("Wrong username or password"), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
        .navigationBarTitle("Login/Sign up", displayMode: .inline)
        .background(Color(UIColor(hex: "332bc2")))
    }

}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        _ = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        _ = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        _ = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: 0.5568627450980392, green: 0.6980392156862745, blue: 0.3607843137254902, alpha: 1.0)
    }
    
}


struct GridView: View {
    var body: some View {
        // Your grid layout content goes here
        Text("Grid Layout")
            .font(.largeTitle)
            .foregroundColor(.black)
    }
}

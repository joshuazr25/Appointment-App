import SwiftUI

struct ContentView: View {
    @State private var showLoginScreen = false

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Button("Login/Sign Up") {
                    showLoginScreen = true
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                Spacer()
            }
            .navigationBarTitle("Appointment", displayMode: .large)
            .background(Color("BackgroundColor")) // Ensure you have this color defined in your assets
            .sheet(isPresented: $showLoginScreen) {
                LoginView()
            }
        }
    }
}

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var showError = false

    var body: some View {
        NavigationView {
            VStack {
                TextField("Username", text: $username)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                SecureField("Password", text: $password)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Login/Sign up") {
                    // Authentication logic here
                    // For simplicity, using static credentials
                    if username == "Jzr" && password == "1234" {
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
                    GridView() // Assuming GridView remains unchanged
                }
                .alert(isPresented: $showError) {
                    Alert(title: Text("Error"), message: Text("Wrong username or password"), dismissButton: .default(Text("OK")))
                }
            }
            .navigationBarTitle("Login/Sign Up", displayMode: .inline)
            .padding()
            .background(Color("BackgroundColor")) // Use the same background color
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: 0.5568627450980392, green: 0.6980392156862745, blue: 0.3607843137254902, alpha: 1.0)
    }
}



struct GridView: View {
    @State private var currentDate = Date()
    @Environment(\.presentationMode) var presentationMode // For dismissing the view

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text(dayMonthYearFormatter.string(from: currentDate))
                        .font(.title)
                        .foregroundColor(.primary) // Using .primary for adaptability with dark mode
                        .padding()

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                        ForEach(dayHours(), id: \.self) { hour in
                            Text(hourFormatter.string(from: hour))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }

                    HStack {
                        Spacer()
                        Button(action: {
                            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
                        }) {
                            Label("", systemImage: "chevron.left")
                        }

                        Button(action: {
                            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
                        }) {
                            Label("", systemImage: "chevron.right")
                        }
                        Spacer()
                    }
                    .padding()
                }
                .navigationBarTitle("Appointments", displayMode: .inline)
                .navigationBarItems(leading: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Sign Out")
                })
                .padding()
            }
        }
    }
    
    private var dayMonthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter
    }
    
    private var hourFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        return formatter
    }
    
    private func dayHours() -> [Date] {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
        var hours: [Date] = []
        for hour in 0..<24 {
            dateComponents.hour = hour
            if let date = calendar.date(from: dateComponents) {
                hours.append(date)
            }
        }
        return hours
    }
}

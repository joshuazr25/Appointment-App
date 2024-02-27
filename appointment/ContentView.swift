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
                    GridView()
                }
                .alert(isPresented: $showError) {
                    Alert(title: Text("Error"), message: Text("Wrong username or password"), dismissButton: .default(Text("OK")))
                }
            }
            .navigationBarTitle("Login/Sign Up", displayMode: .inline)
            .padding()
        }
    }
}

struct GridView: View {
    @State private var currentDate = Date()
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTime: Date?
    @State private var isTimeDetailPresented = false

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

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Button(action: {
                            self.changeDate(by: -1)
                        }) {
                            Image(systemName: "chevron.left")
                        }

                        Text(dayMonthYearFormatter.string(from: currentDate))
                            .font(.title)

                        Button(action: {
                            self.changeDate(by: 1)
                        }) {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .foregroundColor(.primary)
                    .padding()

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                        ForEach(dayHours(), id: \.self) { hour in
                            Button(action: {
                                self.selectedTime = hour
                                self.isTimeDetailPresented = true
                            }) {
                                Text(hourFormatter.string(from: hour))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .navigationBarTitle("Appointments", displayMode: .inline)
                .navigationBarItems(leading: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Sign Out")
                })
                .padding()
            }
            .sheet(isPresented: $isTimeDetailPresented, onDismiss: {
                // Reset the selected time when the detail view is dismissed
                self.selectedTime = nil
            }) {
                if let selectedTime = self.selectedTime {
                    TimeDetailView(time: selectedTime)
                }
            }
        }
    }

    private func changeDate(by days: Int) {
        guard let newDate = Calendar.current.date(byAdding: .day, value: days, to: currentDate) else { return }
        currentDate = newDate
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

struct TimeDetailView: View {
    var time: Date

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }

    var body: some View {
        VStack {
            Text("Selected Time")
                .font(.headline)
                .padding()
            Text(timeFormatter.string(from: time))
                .font(.title)
                .padding()
            Button("Reserve") {
                // Call function to send event details to your backend
                reserveTimeSlot()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
        }
    }

    func reserveTimeSlot() {
        // Implement the network request to your backend server or cloud function
        // The backend then creates the Google Calendar event and sends the invitation
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

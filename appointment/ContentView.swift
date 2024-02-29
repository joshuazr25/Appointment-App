import SwiftUI
import UIKit
import MessageUI

struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    var toRecipients: [String]
    var subject: String
    var messageBody: String

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(toRecipients)
        vc.setSubject(subject)
        vc.setMessageBody(messageBody, isHTML: false)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MailView>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView
        
        init(_ parent: MailView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.presentation.wrappedValue.dismiss()
        }
    }
}


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
    @State private var showingEmailComposer = false

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
                    self.showingEmailComposer = true
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                .sheet(isPresented: $showingEmailComposer) {
                    EmailComposerView()
                }
            }
        }
    }
struct EmailComposerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        guard MFMailComposeViewController.canSendMail() else {
            // If the device is unable to send email, present a fallback view controller
            return UIHostingController(rootView: Text("Cannot send emails from this device."))
        }
        let mailComposer = MFMailComposeViewController()
        mailComposer.setToRecipients(["lreyter336@milkenschool.org"]) // Change to your email address
        mailComposer.setSubject("Appointment Reservation")
        mailComposer.setMessageBody("I would like to reserve an appointment for...", isHTML: false)
        return mailComposer
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No need to update the view controller in this context
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
}

    func reserveTimeSlot() {
        // Implement the network request to your backend server or cloud function
        // The backend then creates the Google Calendar event and sends the invitation
    }


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


class YourViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    // Function to handle email sending
    func sendEmail() {
    guard MFMailComposeViewController.canSendMail() else {
        return // Handle the case where the device is not configured for sending emails
    }
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setToRecipients(["Jzr25@icloud.com"])
        mailComposer.setSubject("Subject of your email")
        mailComposer.setMessageBody("Body of your email", isHTML: false)
        
        // Present the view controller
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            rootViewController.present(mailComposer, animated: true, completion: nil)
        }
    }
    
    // Handle delegate methods for MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        // Handle the result of the email composition
        switch result {
        case .cancelled:
            print("Email composition cancelled")
        case .saved:
            print("Email saved as a draft")
        case .sent:
            print("Email sent successfully")
        case .failed:
            if let error = error {
                print("Email composition failed with error: \(error.localizedDescription)")
            } else {
                print("Email composition failed")
            }
        @unknown default:
            fatalError("Unhandled MFMailComposeResult case")
        }
    }
    
    // Call the Email Sending Functionality from a button action, for example
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        sendEmail()
    }
}

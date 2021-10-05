//
//  SignInView.swift
//  SignInView
//
//  Created by Adam on 9/3/21.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {

    enum SignInStatus {
        case unknown, authorized, failure(Error?)
    }

    @State private var status = SignInStatus.unknown

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            switch status {
            case .unknown:
                VStack {
                    VStack(spacing: 45) {
                        Text("**Please Sign In**")
                            .multilineTextAlignment(.center)
                            .font(.largeTitle)
                            .shadow(radius: 1, y: 1)
                            .padding()

                        ForEach(Share.allShare) { share in
                            HStack(alignment: .center, spacing: 1) {
                                Image(systemName: share.image)
                                    .symbolRenderingMode(.hierarchical)
                                    .frame(width: 60)
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                                    .accessibilityHidden(true)

                                VStack(alignment: .leading) {
                                    Text(share.title)
                                        .font(.headline)

                                    Text(share.description)
                                        .font(.callout)
                                        .foregroundColor(.secondary)
                                }
                                .accessibilityElement(children: .combine)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    Spacer()

                    Button("Cancel", action: close)
                        .frame(maxWidth: .infinity)
                        .font(.subheadline)
                        .padding()

                    SignInWithAppleButton(onRequest: configureSignIn, onCompletion: completeSignIn)
                        .frame(height: 44)
                        .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
                        .shadow(radius: 1, y: 1)
                }
                .padding()

            case .authorized:
                Text("You are all set!")

            case .failure(let error):
                if let error = error {
                    Text("Sorry, there was an error \(error.localizedDescription)")
                } else {
                    Text("Sorry, there was an error.")
                }

            }
        }
    }

    func close() {
        presentationMode.wrappedValue.dismiss()
    }

    func configureSignIn(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName]
    }

    func completeSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let appleID = auth.credential as? ASAuthorizationAppleIDCredential {
                if let fullName = appleID.fullName {
                    let formatter = PersonNameComponentsFormatter()
                    var username = formatter.string(from: fullName).trimmingCharacters(in: .whitespacesAndNewlines)
                    if username.isEmpty {
                        // Refuse to allow empty string names
                        username = "User-\(Int.random(in: 1001...9999))"
                    }

                    UserDefaults.standard.set(username, forKey: "username")
                    NSUbiquitousKeyValueStore.default.set(username, forKey: "username")

                    status = .authorized
                    close()
                    return
                }
            }

            status = .failure(nil)

        case .failure(let error):
            if let error = error as? ASAuthorizationError,
               error.code == .canceled {
                status = .unknown
                return
            }

            status = .failure(error)
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
        SignInView()
            .preferredColorScheme(.dark)
    }
}

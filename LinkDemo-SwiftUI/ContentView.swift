//
//  ContentView.swift
//  LinkDemo-SwiftUI
//
//  Copyright © 2023 Plaid Inc. All rights reserved.
//

import LinkKit
import SwiftUI

struct ContentView: View {

    @State private var isPresentingLink = false
    @State private var createResult: Result<Handler, Plaid.CreateError>?
    @State private var checkingTransactions: [Transaction] = []

    var body: some View {
        ZStack(alignment: .leading) {
            backgroundColor.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 12) {

                Text("WELCOME")
                    .foregroundColor(plaidBlue)
                    .font(.system(size: 12, weight: .bold))

                Text("Fraud Transaction Detection")
                    .font(.system(size: 32, weight: .light))

                Spacer()

                VStack(alignment: .center) {
                    Spacer()
                    Button(action: {
                        isPresentingLink = true
                    }, label:  {
                        Text("Connect your Bank Account")
                            .font(.system(size: 17, weight: .medium))
                            .frame(width: 312)
                            
                    })
                    .padding()
                    .foregroundColor(.white)
                    .background(plaidBlue)
                    .cornerRadius(4)
                }
                .frame(height: 56)
                
                
                
                //TransactionView(transactions: $checkingTransactions)
            }
            .padding(EdgeInsets(top: 16, leading: 32, bottom: 0, trailing: 32))
        }
        .sheet(
            isPresented: $isPresentingLink,
            onDismiss: {
                isPresentingLink = false
            },
            content: {
                switch createResult {
                case .failure(let createError):
                    Text("Link Creation Error: \(createError.localizedDescription)").font(.title2)
                case .success(let handler):
                    LinkController(handler: handler)
                default:
                    Text("Loading...").font(.title2)
                }
            }
        ).onAppear() {
            loadTransactions()
        }
        
    }

    private let backgroundColor: Color = Color(
        red: 247 / 256,
        green: 249 / 256,
        blue: 251 / 256,
        opacity: 1
    )

    private let plaidBlue: Color = Color(
        red: 0,
        green: 191 / 256,
        blue: 250 / 256,
        opacity: 1
    )

    private func versionInformation() -> some View {
        let linkKitBundle  = Bundle(for: PLKPlaid.self)
        let linkKitVersion = linkKitBundle.object(forInfoDictionaryKey: "CFBundleShortVersionString")!
        let linkKitBuild   = linkKitBundle.object(forInfoDictionaryKey: kCFBundleVersionKey as String)!
        let linkKitName    = linkKitBundle.object(forInfoDictionaryKey: kCFBundleNameKey as String)!
        let versionText = "\(linkKitName) \(linkKitVersion)+\(linkKitBuild)"

        return Text(versionText)
            .foregroundColor(.gray)
            .font(.system(size: 12))
    }

    private func loadTransactions() {

        let dataController = PlaidDataController()
        var user = CashUser(id: "user-id")

        dataController.createLinkToken(user_id: user.id) { link_token in
            if let link_token = link_token {
                
                var linkConfiguration = LinkTokenConfiguration(token: link_token) { success in
                    isPresentingLink = false

                    dataController.tokenExchange(publicToken: success.publicToken) { access_token in
                        if let access_token = access_token {
                            user.acesstoken = access_token
                            
                            dataController.getTransactions(user:user) { transactions in
                                if let transactions = transactions {
                                    checkingTransactions = transactions
                                }
                            }
                        }
                    }
                }
                
                linkConfiguration.onEvent = { event in
                    print("Link Event: \(event)")
                }
                
                linkConfiguration.onExit = { exit in
                    isPresentingLink = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    createResult = Plaid.create(linkConfiguration)
                }
            }
        }
    }
}

struct LinkView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

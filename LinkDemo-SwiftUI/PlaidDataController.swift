//
//  PlaidDataController.swift
//  LinkDemo-SwiftUI
//
//  Created by Ratnesh on 6/11/23.
//

import Foundation

class PlaidDataController {
    let client_id = "6484c597b00cef00133390bf"
    let secret = "f05589573dfd57516b1d36d7b30f03"
    
    func createLinkToken(user_id: String, linkTokenCompletion: @escaping (String?) -> Void) {
        
        let Url = String(format: "https://sandbox.plaid.com/link/token/create")
        guard let serviceUrl = URL(string: Url) else {
            linkTokenCompletion(nil)
            return
        }
        
        let parameterDictionary = ["client_id": client_id,
                                   "secret": secret,
                                   "client_name": "Plaid Test App",
                                   "user": ["client_user_id": user_id] ,
                                   "products": ["transactions"],
                                   "country_codes": ["US"],
                                   "language": "en",
                                   "webhook": "https://sample.webhook.com",
                                   "redirect_uri": "https://alertme/home"]
        as [String : Any]
        
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
            linkTokenCompletion(nil)
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json: [String: String] = try JSONSerialization.jsonObject(with: data, options: []) as! [String : String]
                    linkTokenCompletion(json["link_token"]);
                    print(json)
                } catch {
                    print(error)
                }
            }
        })
        task.resume()
    }
    
    func getTransactions(user: CashUser, tranascationCompletionHandler: @escaping ([Transaction]?) -> Void) {
        
        let count = 250
        let options = ["include_personal_finance_category": true]
        
        let Url = String(format: "https://sandbox.plaid.com/transactions/sync")
        
        guard let serviceUrl = URL(string: Url) else {
            tranascationCompletionHandler(nil)
            return
            
        }
        guard let acesstoken = user.acesstoken else {
            tranascationCompletionHandler(nil)
            return
            
        }
        
        let parameterDictionary = ["client_id": client_id,
                                   "secret": secret,
                                   "access_token": acesstoken,
                                   "count": count,
                                   "options": options]
        as [String : Any]
        
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json: [String: Any] = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                    
                    let resultarr: [Any] = json["added"] as! [Any]
                    var returnarr: [Transaction] = []
                    resultarr.forEach { resultObject in
                        if let resultObject = resultObject as? [String: Any] {
                            var newTransaction = Transaction()
                            newTransaction.amount = resultObject["amount"] as? Double
                            newTransaction.category = (resultObject["category"] as? [String])?.first
                            newTransaction.date = resultObject["date"] as? String
                            newTransaction.merchantName = resultObject["name"] as? String
                            returnarr.append(newTransaction)
                        }
                    }
                    tranascationCompletionHandler(returnarr)
                    print(json)
                } catch {
                    print(error)
                }
                tranascationCompletionHandler(nil)
            }
        }.resume()
    }
    
    func tokenExchange(publicToken: String, exchangeTokenCompletion: @escaping (String?) -> Void) {
        
        let Url = String(format: "https://sandbox.plaid.com/item/public_token/exchange")
        
        guard let serviceUrl = URL(string: Url) else {
            exchangeTokenCompletion(nil)
            return
        }
        
        let parameterDictionary = ["client_id": client_id,
                                   "secret": secret,
                                   "public_token": publicToken ]
        as [String : Any]
        
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
            exchangeTokenCompletion(nil)
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json: [String: String] = try JSONSerialization.jsonObject(with: data, options: []) as! [String : String]
                    exchangeTokenCompletion(json["access_token"]);
                    print(json)
                } catch {
                    print(error)
                }
            }
        })
        task.resume()
        
    }
}

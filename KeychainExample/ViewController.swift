//
//  ViewController.swift
//  KeychainExample
//
//  Created by Lovice Sunuwar on 09/11/2023.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        save()
        getPassword()
        
    }

    func getPassword() {
        
        guard let data = KeychainManager.get(service: "abcd.com",
                                             account: "someboody") else {
            print("Failed to read password")
            return
        }
        let password = String(decoding: data, as: UTF8.self)
        print("\(password) Is the password")
    }
    
    func save() {
        do {
            try KeychainManager.save(service: "abcd.com",
                                     account: "someboody",
                                     password: "something".data(using: .utf8) ?? Data()
            )
        } catch {
            print(error)
        }
    }
    
}

    


class KeychainManager {
    enum KeychainError: Error {
        case duplicateEntry
        case unknown(OSStatus)
    }
    
    
    static func save(
        service: String, // These are the key for the data you are savings
        account: String,
        password: Data
    ) throws {
        // Service, account, password(piece of data) class, data
        
        // The item in the keychain, Service, account and the data you save on the keychain are the main properties to identify in keychain
        
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecValueData as String: password as AnyObject,
        ] // Even though this is a dicitionary it is serving as a query
        
        let status = SecItemAdd(query as CFDictionary, nil) //<- Adds the items to the keychain
        
        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicateEntry
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status) // <- Error with all purposes
        }
        
        print("saved")
    }
    
    static func get(
        service: String, // These are the key for the data you are savings
        account: String
    ) -> Data? {
        // Service, account, password(piece of data) class, data
        
        // The item in the keychain, Service, account and the data you save on the keychain are the main properties to identify in keychain
        
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecReturnData as String: kCFBooleanTrue, // <- So we are returning the data and saying that we expect this qiuery to return data
            kSecMatchLimit as String : kSecMatchLimitOne
            // How many are we matching against or having a limit because we want to match all the values that return us only one
        ] // Even though this is a dicitionary it is serving as a query
        
        
        
        var result: AnyObject?
        
        let status = SecItemCopyMatching(query as CFDictionary, &result) //<- Referencing result should be data or nil
        
        print("Read Status: \(status)")
       
        return result as? Data // Soft Downcast to data
        
        
        
    }
}


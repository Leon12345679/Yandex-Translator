//
//  API_Requests.swift
//  TranslYAtor
//
//  Created by Leon Vladimirov on 1/19/19.
//  Copyright © 2019 Leon Vladimirov. All rights reserved.
//

import Foundation

class NetworkingMethods {
    
    // JSON data response struct
    struct queryResponse: Codable {
        let code: Int
        let lang: String
        let text: [String]
    }
    
    // Translate() comes with a completion handler.
    func Translate(phrase: String, toLang: String, completion: @escaping ((String) -> Void)) {
        // assembling the URL
        let translateURL = "https://translate.yandex.net/api/v1.5/tr.json/translate"
        
        // Insert your key into the key constant to use
        let key = ""
        let text = phrase
        let url_formatted_text = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let lang = toLang
        let format = "plain"
        let Url = URL(string: "\(translateURL)" + "?key=\(key)&text=\(url_formatted_text!)&lang=\(lang)&format=\(format)")!
        
        var request = URLRequest(url: Url)
        // Post the assembled URL
        request.httpMethod = "POST"
        
        // start waiting for the JSON response if data was found then decode it
        let task = URLSession.shared.dataTask(with: request) { (data,
            response, error) in
            if error != nil {
                completion("ERROR: Проблема с соединением")
            }
            if let data = data {
                completion(self.DecodeJSON(data: data))
            }
        }
        task.resume()
    }
    
    func DecodeJSON(data: Data) -> String  {
        do {
            // data we are getting from API response
            let decoder = JSONDecoder()
            let response = try decoder.decode(queryResponse.self, from: data)
            switch(response.code) {
            case 200: return response.text[0]
            case 401: return "ERROR: API ключ не правилен"
            case 402: return "ERROR: API ключ заблокирован"
            case 404: return "ERROR: Слишком много запросов за день"
            case 413: return"ERROR: Текст слишком длинный"
            case 422, 501: return "ERROR: Не смогли перевести"
            default:
                return "ERROR: Не смогли перевести"
            }
        } catch {print(error)}
        return "ERROR: API ключ не введен или введен не правильно"
    }


}

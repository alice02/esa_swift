import Foundation

protocol EsaClientProtocol {
    func send_get(path: String) -> EsaResponse?
    func send_post(path: String, body: Any) -> EsaResponse?
    func send_put(path: String) -> EsaResponse?
    func send_delete(path: String) -> EsaResponse?
}

class EsaClient: EsaClientProtocol {

    var access_token: String?
    var current_team: String?
    let api_endpoint = URL(string: "https://api.esa.io")
    let session: URLSession = URLSession(configuration: .default)
    
    init(access_token: String?, current_team: String? = nil) {
        self.access_token = access_token
        self.current_team = current_team
    }
    
    func send_get(path: String) -> EsaResponse? {
        let url = URL(string: "https://api.esa.io" + path)
        var request: URLRequest = URLRequest(url: url!)
        let cond = NSCondition()
        var error: Error?
        var data: Data?
        var response: URLResponse?
        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(self.access_token!)",
                         forHTTPHeaderField: "Authorization")
        session.dataTask(with: request,
                         completionHandler: { (dat, resp, err) in
                             data = dat
                             error = err
                             response = resp
                             cond.broadcast()
                         }).resume()
        cond.wait()

        if error != nil {
            return nil
        }
        return EsaResponse(data: data, response: response)
    }

    func send_post(path: String, body: Any) -> EsaResponse? {
        let url = URL(string: "https://api.esa.io" + path)
        var request: URLRequest = URLRequest(url: url!)
        let cond = NSCondition()
        var error: Error?
        var data: Data?
        var response: URLResponse?
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(self.access_token!)",
                         forHTTPHeaderField: "Authorization")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        } catch {
            print("json serialization error")
        }

        session.dataTask(with: request,
                         completionHandler: { (dat, resp, err) in
                             data = dat
                             error = err
                             response = resp
                             cond.broadcast()
                         }).resume()
        cond.wait()

        if error != nil {
            return nil
        }
        return EsaResponse(data: data, response: response)
    }

    func send_put(path: String) -> EsaResponse? {
        return nil
    }

    func send_delete(path: String) -> EsaResponse? {
        return nil
    }

}
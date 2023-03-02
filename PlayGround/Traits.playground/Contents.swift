import UIKit
import RxSwift
import Alamofire


struct ArticleResponse: Codable {
    let articles: [Article]
}

struct Article: Codable {
    let title: String
}

func getNews() -> Observable<[Article]> {
    return Observable.create { observer in
        
        let urlString = "https://newsapi.org/v2/everything?q=tesla&sortBy=publishedAt&apiKey=bc83fae28aeb4e07ab75f770c6b23bb6"
        
        AF.request(urlString)
            .validate(statusCode: 200...299)
            .responseDecodable(of: ArticleResponse.self) { response in
                switch response.result {
                case .success(let data):
                    observer.onNext(data.articles)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
        return Disposables.create()
    }
}

getNews().subscribe { event in
    switch event {
    case .next(let articles):
        print(articles)
    case .error(let err):
        print(err.localizedDescription)
    case .completed:
        print("complete")
    }
}.dispose()

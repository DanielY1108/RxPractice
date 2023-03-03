import UIKit
import RxSwift
import Alamofire

enum SomeError: Error {
    case err
}

// MARK: - Traits?
// Observable이 파생된 형태로 create시 제한적인 이벤트만 받고 싶을 때 사용합니다.
// 간단히 말해 이벤트 onNext, onError, onCompleted를 모두 처리하는게 아니라 원하는 이벤트만 처리 가능.

// 종류로는
// RxSwift에는 Single, Completable, Mabye
// RxCocoa는 Driver, Signal

// Traits을 통해 필요한 이벤트만 사용하여 코드를 조금더 직관적이고 의도를 명확하게 해주도록 도와줍니다.
// Traits도 엄연히 Observable입니다.

// Traits의 구현부를 간단히 살펴보면
// public typealias Single<Element> = PrimitiveSequence<SingleTrait, Element>
// public typealias Completable = PrimitiveSequence<CompletableTrait, Swift.Never>
// public typealias Maybe<Element> = PrimitiveSequence<MaybeTrait, Element>

// 이와같이 Traits은 Observable 타입을 감싸고 있는 Wrapper 구조체입니다.
// public struct PrimitiveSequence<Trait, Element> {
//     let source: Observable<Element>
// }


// MARK: - Single
// Observable 생성 방식과 비슷합니다.

// Observable 생성
func observable1() -> Observable<Any> {
    return Observable.create { observer in
        observer.onNext("Operation")

        observer.onError(SomeError.err)
        observer.onCompleted()

        return Disposables.create()
    }
}

// Single (오직 성공, 실패 이벤트만 다룹니다.)
// .success() == onNext + onCompleted
// .failure() == onError

// Observable과 다르게 observer.onNext 이런 접근이 아닌 observer(.success()) 이런식으로 사용 되는는 이유는

// Observable을 만들때는 직접 element로 접근을 하여 점문법을 사용하지만
// SingleObserver 경우는 동작(클로저)을 전달하므로 점문법이 아닌 함수의 실행 "()"으로 만들어서 사용합니다.
// public typealias SingleObserver = (SingleEvent<Element>) -> Void
func singleObservable() -> Single<Any> {
    return Single.create { observer in
        observer(.success("Success Operation"))
        observer(.failure(SomeError.err))
        
        return Disposables.create()
    }
}

// 당연히 이벤트도 onSuccess, onFailure, onDisposed 만을 갖고 사용합니다.
singleObservable().subscribe { event in
    switch event {
    case .success(let data):
        print(data)
    case .failure(let error):
        print(error.localizedDescription)
    }
}.dispose()

// 일반적으로 Single은 성공,실패로 이벤트를 받을 수 있으므로 API Request에서 주로 사용됩니다.

struct ArticleResponse: Codable {
    let articles: [Article]
}

struct Article: Codable {
    let title: String
}

func getNews() -> Single<[Article]> {
    return Single.create { observer in
        
        let urlString = "https://newsapi.org/v2/everything?q=tesla&sortBy=publishedAt&apiKey=bc83fae28aeb4e07ab75f770c6b23bb6"
        
        AF.request(urlString)
            .validate(statusCode: 200...299)
            .responseDecodable(of: ArticleResponse.self) { response in
                switch response.result {
                case .success(let data):
                    observer(.success(data.articles))
                case .failure(let error):
                    observer(.failure(error))
                }
            }
        return Disposables.create()
    }
}
let disposbag = DisposeBag()

//// switch문을 통해 이벤트를 사용하거나
//getNews()
//    .subscribe { event in
//        switch event {
//        case .success(let data):
//            debugPrint(data)
//        case .failure(let error):
//            print("Failed Request: \(error)")
//        }
//    }.disposed(by: disposbag)
//
//// 또는 subscribe(onSuccess:, onError:) 직접 처리
//getNews()
//    .subscribe(
//        onSuccess: { data in
//            debugPrint(data)
//        },
//        onFailure: { error in
//            print("Failed Request: \(error)")
//        })
//    .disposed(by: disposbag)


// MARK: - Completable
// 성공 여부만 전달해주고 싶을 때 Completable를 사용합니다.
// 어떠한 element도 방출하지 않고 순수하게 오류의 발생 또는 성공 여부를 전달하는 목적입니다.

func completableObservable() -> Completable {
    return Completable.create { observer in
        observer(.completed)
        observer(.error(SomeError.err))
        return Disposables.create()
    }
}

// 간단한 예를 들어보면 스위치가 켜져있을 때 completed에서 동작을 할 수 있습니다.
var switchOn = true

func checkTheSwitch() -> Completable {
    return Completable.create { observer in
        
        // 스위치가 꺼져있으면 오류 발생
        guard switchOn else {
            observer(.error(SomeError.err))
            return Disposables.create()
        }
        observer(.completed)
        
        return Disposables.create()
    }
}

checkTheSwitch().subscribe { event in
    switch event {
    case .completed:
        print("Completed with no error, Turn off switch")
        switchOn = false
        print(switchOn)
    case .error(let error):
        print(error)
    }
}.disposed(by: disposbag)

// Completed with no error, Turn off switch
// false

// MARK: - Mabye
// Mabye는 Single과 Completable의 중간 특성을 갖고있는 Observable입니다.

// success, completed, error를 모두 배출도 가능하지만 필요에 따라 생략도 가능합니다.
func mabyeObservable() -> Maybe<Any> {
    return Maybe.create { observer in
        observer(.success("Some Data"))
        observer(.completed)
        observer(.error(SomeError.err))
        return Disposables.create()
    }
}

mabyeObservable()
    .subscribe { event in
        switch event {
        case.success(let element):
            print(element)
        case .completed:
            print("Complete")
        case .error(let error):
            print(error)
        }
    }.disposed(by: disposbag)


// MARK: - 정리 및 참고

// Traits이 갖고 있는 이벤트 정리
// Single : .success(), .failure()
// Completable : .completed, .error()
// Mabye : .success()?, .completed?, .error()?

// Observable 시퀀스를 as로(Single, Mabye) 변환시 주의점이 있습니다.
// 만약 Observable을 asSingle로 변환할 때 Observable의 생성 시 onNext 뒤에는 onCompleted가 와줘야 합니다.
// 이유는 Single의 success는 onNext + onCompleted이 합쳐진 것이므로 항상 같이 써주며 순서를 신경써야 합니다.(아니면 에러 발생)
func observable() -> Observable<Any> {
    return Observable.create { observer in
        observer.onNext("Operation")
        observer.onCompleted()

        observer.onError(SomeError.err)

        return Disposables.create()
    }
}

observable().asSingle()
    .subscribe { event in
        switch event {
        case .success(let element):
            print(element)
        case .failure(let error):
            print(error)
        }
    }.disposed(by: disposbag)

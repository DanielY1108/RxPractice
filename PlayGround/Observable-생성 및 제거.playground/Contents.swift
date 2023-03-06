import UIKit
import RxSwift
import Alamofire

// 생성 방법으로는 create, just, of, from, range 가 존재합니다.
// 제거 방법으로는 empty, never, disposable이 존재합니다.

// MARK: - just
// 오직 하나의 Observable sequence만을 생성
let justObservable = Observable.just("Hello World")


justObservable
    .subscribe(onNext: { element in
        print(element)
    })

// Hello World

// MARK: - of
// of 안쪽의 타입은 동일해야 한다.
// element을 순차적으로 방출시킨다.
let ofObservable: Observable<Int> = Observable.of(1, 2, 3)
let ofObservableArr: Observable<[Int]> = Observable.of([1, 2, 3])

ofObservable
    .subscribe(onNext: { element in
        print(element)
    })

// 1
// 2
// 3

// 배열 자체를 한개의 element로 취급해서 방출시킨다.
ofObservableArr
    .subscribe(onNext: { element in
        print(element)
    })

// [1, 2, 3]

// MARK: - from
// 배열로 element를 받아와서 하나하나를 방출시킨다. (방출 이벤트: array -> element)
let fromObservable = Observable.from([1, 2, 3])

fromObservable
    .subscribe(onNext: { element in
        print(element)
    })

// 1
// 2
// 3

// MARK: - range
// 범위를 지정해서 카운트를 배출시킨다.
let rangeObservable = Observable.range(start: 1, count: 5)

rangeObservable
    .subscribe(onNext: { element in
        print(element)
    })

// 1
// 2
// 3
// 4
// 5

// from으로 range를 표현할 수 있다. (방식의 차이, 하지만 의미를 명확하게 사용하기 위해선 range를 사용하자)
let fromRangeObservable = Observable.from(1...5)

fromRangeObservable
    .subscribe(onNext: { element in
        print(element)
    })

// 1
// 2
// 3
// 4
// 5


// MARK: - empty
// 초기화 하고 싶을 때 사용. 빈 Observable을 만든다.
// 의도적으로 Observable의 구독에서 completed 되는 순간 element를 없게 만드는 방법 등 유용하게 사용된다.

let emptyObservable = Observable<Any>.empty()

emptyObservable
    .subscribe {
        print($0)
    } onError: {
        print($0)
    } onCompleted: {
        print("onCompleted")
    } onDisposed: {
        print("onDisposed")
    }

// MARK: - never
// Observable이 아무런 이벤트도 방출 시키지 않도록 한다. (단! onDisposed 제외)

let neverObservable = Observable<Any>.never()

neverObservable
    .subscribe {
        print($0)
    } onError: {
        print($0)
    } onCompleted: {
        print("onCompleted")
    } onDisposed: {
        print("onDisposed")
    }.dispose()

// onDisposed

// MARK: - Disposable
// Observable을 구독(subscribe)하게 되면 Disposable(일회성 리소스)을 리턴 값으로 반환합니다.
// Disposable 사용 후 버리는 리소스입니다. (일회성 리소스)
// 일회용이기 때문에 구독 이벤트인 onError, onCompleted, onDisposed가 호출되어 더 이상 사용되지 않을 때, 메모리 정리를 위해서 dispose()를 호출 해준다.
// dispose는 간단히 구독 취소라고 생각하면 됩니다.
// dispose는 Observable을 구독(subsribe)할 때 필수적으로 사용해줘야 합니다. (메모리 관리를 위해)

// 위의 방식대로 해주면 이러한 에러가 발생합니다. (현재 플레이그라운드라서 표시가 안됨)
// Result of call to 'subscribe(onNext:onError:onCompleted:onDisposed:)' is unused
// subscribe의 리턴값을 보면 Disposable을 리턴해줍니다. Disposable에 대한 처리를 하지 않아서 경고가 생기는 거죠.

// 이렇게 직접 dispose를 호출해 구독 취소가 가능하다.
let observable1 = Observable.of(1, 2, 3, 4)

observable1
    .subscribe(onNext: { element in
        print(element)
    }).dispose()

// 하지만 만약 구독이 여러개가 있다고 가정해보자.
let subscribe1 = observable1.subscribe { _ in }
let subscribe2 = observable1.subscribe { _ in }
let subscribe3 = observable1.subscribe { _ in }

// 일일히 각각의 해제 시점을 고려해 시퀀스를 끊어줘야 한다.
subscribe1.dispose()
subscribe2.dispose()
subscribe3.dispose()

// 여기서 불편함을 느껴 Disposable을 주머니에 담아서 한번에 해제 시키자 생각해 만들어진게 disposeBag이다.

// 생성방법은 간단합니다.
// 전역변수로 disposeBag을 만들어 준 뒤 disposed(by:) 메서드에 Disposable를 담아주기만 하면 됩니다.

// disposed(by:)의 정의는 이와같습니다. bag에 Disposable 자신을 넣어줍니다.
//extension Disposable {
//    public func disposed(by bag: DisposeBag) {
//        bag.insert(self)
//    }
//}

let disposeBag = DisposeBag()
subscribe1.disposed(by: disposeBag)
subscribe2.disposed(by: disposeBag)


// 어? 그러면 Disposable를 disposeBag에 담아주기만하고 해제는 안시켰는데라고 생각이 드실겁니다.
// disposeBag의 해제 시점은
// 기본적으로 사용되고 있는 컨트롤러가 deinit 됬을 때 자동으로 dispose를 시켜줍니다.
// 다른 방법으로는 객체 disposeBag에 임의로 nil 값을 할당했을 때 dispose가 호출 됩니다. (대신 선언할 때 옵셔널도 선언해줘야 겠죠.)
// disposeBag = nil

// disposeBag 동작방식은 dispose가 되면 for-in문을 통해 기존의 Disposable을 새로운 Disposable로 변환시켜 줍니다.

// 간단해서 자세한건 정의에 한번 들어가서 살펴보시면 이해되실 겁니다.
//private func dispose() {
//    let oldDisposables = self._dispose()
//
//    for disposable in oldDisposables {
//        disposable.dispose()
//    }
//}

// MARK: - create
// 가장 많이 사용하는 생성 방법으로 사용가자 직접 커스텀 Observable을 생성합니다.
// 각 이벤트(onNext, onError, onCompleted, onDisposed)를 직접 escape closure를 통해 정의를 해줍니다.
// 바로 살펴봅시다.

// Observable<T>.create()로 생성합니다.

// 기본적인 틀은 이런 모양입니다.
// 위에서 구독(subsribe)를 하게되면 Disposable(일회성 리소스)를 리턴한다고 했습니다.
// 커스텀으로 create를 생성 시 일회성 리소스인 Disposable을 사용하기 위해 Disposables.create()로 필수적으로 구현해줘야 합니다.

 let createObservable0 = Observable<String>.create { observer in
     return Disposables.create()
 }

// 이제 이벤트에 대한 처리를 해보겠습니다.
// 클로저의 파라미터에서 Dot(.) 접근한 뒤 onNext(), onCompleted(), onError() 데이터를 전달해주면 됩니다.
let createObservable = Observable<String>.create { observer in
    observer.onNext("Hello World")
    observer.onCompleted()
    observer.onError(NSError(domain: "GG", code: 404))
    return Disposables.create()
}

// 생성을 했으니 구독을 해보면
createObservable
    .subscribe { element in
        print(element)
    } onCompleted: {
        print("Complete")
    }.disposed(by: disposeBag)

// Hello World
// Complete

// 예제 (AlamoFire + RX)
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
}.disposed(by: disposeBag)

// 기본적인 Rx 생성방법을 알아보았습니다.
// 간단히 정리 및 사용이유를 알아봅시다

// 간단히 비유를 통해 알아보자 NETFLIX라고 예를들면
// Observable: NETFLIX의 영화나 드라마. 영상이 주기적으로 업데이트가 된다.
// Observer: NETFLIX를 시청하는 사람
// subscribe: NETFLIX 구독권, 구독권만 갖고 있다면 NETFLIX의 영화나 드라마가 업데이트가 되면 업데이트된 영상을 시청할 수 있다.

// 이제 사용이유를 알아보면
// Rx는 반응형 프로그래밍을 구현하기 위해 사용합니다.
// Observable에서 이벤트가 업데이트 되면 구독자(Oberserver)는 구독(subscribe)을 통해 이벤트를 처리합니다.

// 즉, 여기서 Observable의 escape closure로 데이터를 받아와서 데이터의 변화를 감지하고 구독(subscribe)을 통해 Observer에게 업데이트 된 데이터를 전달합니다.
// 이러한 과정으로 이벤트가 전달되면 즉시 그 이벤트를 Observer가 구독(subscribe)을 통해 전달 받아 처리하여 UI 업데이트 및 데이터를 실시간으로 반영할 수 있게되는 겁니다.

// MARK: - deferred
// 무언가를 미룬다는 의미로 사용되는 연산자로 Observable 생성을 연기할 수 있습니다.
// deferred는 Observable이 생성되는 시점을 구독자(Observer)가 구독(subscribe)전까지 미뤄주는 역활을 합니다.

// 보통 Observable을 생성할 때는 Observable.create를 사용하여 직접 Observable을 만들어주게 되는데,
// 이 경우에는 Observable이 만들어질 때부터 작업이 시작됩니다.

// 만약 이와같이 바로 just를 사용하여 어떠한 동작을 사용하게되면 just 안쪽에서 함수를 실행시키기 때문에
// 구독(subscribe)을 하지 않아도 5초 뒤에 "Take a long time t work" 이 출력이 될 것입니다.
// 구독을 하지도 않았는데 5초라는 시간을 낭비하고 있습니다.
func heavyWork() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        print("Take a long time t work")
    }
}

let observable = Observable.just(heavyWork())
observable.subscribe { e in
    switch e {
    case .next(let a):
        a
    case .completed:
        print("com")
    case .error(let err):
        print(err)
    }
}

// 5초 후 Take a long time t work 출력

// 이와같이 중요 쓰레드인 메인스레드에서 어떠한 오래걸리는 작업을 할 때
// 위와 같이 예를들어 메인쓰레드에서 5초가 걸리는 무거운 작업을 하게 된다면
// 그 시간동안 UI를 그리는 메인쓰레드를 방해하고 있으므로 5초동안 화면이 멈춘거 같이 보일겁니다.

// 그래서 만들어진 연산자가 구독(subscribe)이 되기전까지 작업을 미뤄주는 역활을 하는 deferred 입니다.
let deferredObservable = Observable.deferred {
    // Observable을 리턴해줍니다.
    return Observable.just(heavyWork())
}

// 동작을 안하고 구독을 기다림

// 구독을 하는 순간에 heavyWork() 작업이 동작
deferredObservable.subscribe { _ in
    // ...
}


// deferred를 사용하게되면 구독하는 순간 실행되게 때문에 쓸데없는 작업을 막고 필요한 시점에서만 작업을 수행합니다.
// 즉, 무거운 작업(오래 걸리는 작업)시 쓰레드 낭비를 막을 수 있습니다.
// 또한, 구독되는 시점에 동작하므로 구독과 동시에 어떠한 업데이트가 필요할 때 deferred로 감싸서 사용하면 됩니다.


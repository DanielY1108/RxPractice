import UIKit
import RxSwift

// MARK: - 기본 옵저버블 생성 및 구독 방법

let observable = Observable.of(1, 2, 3, 4)

// 이렇게만 해주면 구독은 하지만 구독한 데이터를 사용을 하지 않는다.
observable.subscribe()

// 구독시 Observable이 방출하는 이벤트가 존재한다. (onNext, onError, onCompleted, onDisposed)
// 이와같이 Observable은 시간의 흐름에 따라 이벤트를 방출해준다.
// 방법. 1
observable
    .subscribe { element in
        print("Observable로 부터 \(element)를 전달 받았습니다.")
    } onError: { error in
        print("Observable이 에러가 발생했습니다: \(error)")
    } onCompleted: {
        print("Observable이 정상적으로 종료 되었습니다.")
    } onDisposed: {
        print("Observable이 폐기됬습니다.")
    }

// Observable로 부터 1를 전달 받았습니다.
// Observable로 부터 2를 전달 받았습니다.
// Observable로 부터 3를 전달 받았습니다.
// Observable로 부터 4를 전달 받았습니다.
// Observable이 정상적으로 종료 되었습니다.
// Observable이 폐기됬습니다.

// Observable의 이벤트 처리는 subscribe을 통해 시간의 흐름에 따라 이벤트를 처리를 시킨다.

observable
    .subscribe(onNext: { element in
        print("Observable로 부터 \(element)를 전달 받았습니다.")
    })

// MARK: - subscribe 참고

// 구독(subsribe)은 한번의 호출로 한번의 이벤트만 처리한다.
// 종료되고 사용하려면 다시 구독(subsribe)을 해줘야 한다.

// subscribe의 파라미터들은 옵셔널 값이라서 생략이 가능합니다. (즉, 원하는 동작만 사용할 수 있다)
// observable.subscribe(onNext: <#T##((Int) -> Void)?##((Int) -> Void)?##(Int) -> Void#>, onError: <#T##((Error) -> Void)?##((Error) -> Void)?##(Error) -> Void#>, onCompleted: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>, onDisposed: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)

// 참고사항은 이와같이 파라미터를 모두 지우고 사용하게 되면 onNext와 onCompleted, onError이 모두 호출됩니다.
observable.subscribe { element in
    print(element)
}

// next(1)
// next(2)
// next(3)
// next(4)
// completed



// 방법. 2
//observable.subscribe(<#T##on: (Event<Int>) -> Void##(Event<Int>) -> Void#>)
observable
    .subscribe { event in
        switch event {
        case .next(let element):
            print("Observable로 부터 \(element)를 전달 받았습니다.")
        case .completed:
            print("Observable이 정상적으로 종료 되었습니다.")
        case .error(let error):
            print("Observable이 에러가 발생했습니다: \(error)")
        }
    }

// MARK: - 구독시 메모리 누수문제 해결방법

// subscribe은 escape closure이므로 self를 사용하게 되면 누수가 발생할 확률이 있다.
// 기본적으로는 이와같이 weak self를 사용하여 누수를 해결한다.
class Action {
    func someAction() {}
    
    init() {
        observable
            .subscribe { [weak self] element in
                guard let self = self else { return }
                self.someAction()
                print(element)
            }
    }
}

// RxSwift에서는 메모리 누수를 해결하기 위해 따로 이니셜라이저를 만들어놨습니다.
// with 파라미터가 있는 메서드를 사용하면 된다. subscribe(with:)
// with에 self를 넘겨주고 strongSelf로 받아와서 클로저에서 사용하여 메모리 누수를 방지해줍니다.
class ActionRx {
    func someAction() {}
    
    init() {
        observable
            .subscribe(with: self) { strongSelf, element in
                strongSelf.someAction()
                print(element)
            }
    }
}



// 즉, Observable는 이벤트를 감지하고 구독자(Observer)는 구독(subscribe)를 통해 이벤트를 처리합니다.

import UIKit
import RxSwift

enum SomeError: Error {
    case err
}

let disposeBag = DisposeBag()

// MARK: - Hot & Cold Observable

// 스트림: Observable이 방출하는 데이터 흐름

// Hot Observable : 구독하기 여부와 상관없이 이벤트를 발생시킨다. (구독하기 전부터 이미 element 방출)
// Observable의 데이터 스트림은 이미 진행중이고 구독하는 시점 부터 이벤트를 통해 element를 방출합니다.

// Hot Observable을 사용하는 대표적인 방법으로는 Subject가 있습니다.


// Cold Observable : 구독하기 전까지 아무런 이벤트도 발생하지 않는다. (구독시 element 방출)
// 구독을 기다리며 구독하는 순간 이벤트를 통해 element를 방출합니다. (lazy 특성)

// just, of, from와 같은 Observable은 Cold Observable처럼 동작합니다.


// 간단한 비유로
// Hot Observable : Live Streaming
// Cold Obsevable : VOD

// 간단히 marble로 예를들어보면
// Cold Observable은 구독을 어느 시점에서 하더라도 모든 element를 얻게된다.
// Hot Observable은 구독하는 시점에 따라서 얻게되는 element가 다르다.


// MARK: - PublishSubject

// 타입을 제너릭으로 지정해주고 실행해주면 준비 끝
var publishSubject = PublishSubject<Any>()

// 기존의 Observable 처럼 이벤트를 처리해주면 됩니다.
//publishSubject.onNext("Hello")
//publishSubject.onCompleted()
//publishSubject.onError(SomeError.err)

// Subject는 특별하게도
// Observable로서 데이터를 방출하기도 하면서,
// Observer로서 데이터를 구독할 수도 있습니다!

//publishSubject.subscribe(onNext: { element in
//    print("Observer received value: \(element)")
//}).disposed(by: disposeBag)

// Subject는 Hot Observable이기 떄문에 구독 시점에 따라서 얻게 되는 데이터가 달라집니다!
// 그러므로 구독후에 이벤트 설정을 해줘야 한다.

//publishSubject.onNext(1)
//publishSubject.onNext(2)
//publishSubject.onNext(3)
//publishSubject.onNext(4)


// observer가 서로 데이터를 공유하나 확인해보자.
var subject = PublishSubject<Int>()

// 클로저로 observer를 만들어 줌
let observer1: (Int) -> Void = { value in
    print("Observer 1 received value: \(value)")
}

let observer2: (Int) -> Void = { value in
    print("Observer 2 received value: \(value)")
}

// 랜덤 숫자를 생성
let randomNum1 = Int.random(in: 1...100)
let randomNum2 = Int.random(in: 1...100)

subject.subscribe(onNext: observer1)
    .disposed(by: disposeBag)

// 작업 1 시작
subject.onNext(randomNum1)

subject.subscribe(onNext: observer2)
    .disposed(by: disposeBag)

// 작업 2 시작
subject.onNext(randomNum2)

//Observer 1 received value: 84
//Observer 1 received value: 28
//Observer 2 received value: 28

// MARK: - BehaviorSubject

var behaviorSubject = BehaviorSubject<Any>(value: 0)

behaviorSubject.subscribe(onNext: { element in
    print("Observer 1, received value: \(element)")
})

behaviorSubject.onNext(1)
behaviorSubject.onNext(2)

behaviorSubject.subscribe(onNext: { element in
    print("Observer 2, received value: \(element)")
})

behaviorSubject.onNext(3)

// MARK: - ReplaySubject

var replaySubject = ReplaySubject<Int>.create(bufferSize: 2)

replaySubject
    .debug()
    .subscribe(onNext: { element in
    print("Observer 1, received value: \(element)")
}).disposed(by: disposeBag)

replaySubject.onNext(1)
replaySubject.onNext(2)

replaySubject = ReplaySubject<Int>.create(bufferSize: 2)

replaySubject.subscribe(onNext: { element in
    print("Observer 2, received value: \(element)")
}).disposed(by: disposeBag)

replaySubject.onNext(3)
replaySubject.onNext(4)

replaySubject.subscribe(onNext: { element in
    print("Observer 3, received value: \(element)")
}).disposed(by: disposeBag)

// Observer 1, received value: 1
// Observer 1, received value: 2

// Observer 2, received value: 1
// Observer 2, received value: 2
// Observer 1, received value: 3
// Observer 2, received value: 3
// Observer 1, received value: 4
// Observer 2, received value: 4

// Observer 3, received value: 3
// Observer 3, received value: 4

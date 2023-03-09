import UIKit
import RxSwift

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



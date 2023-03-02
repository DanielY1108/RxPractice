//
//  ViewController.swift
//  RxPractice
//
//  Created by JINSEOK on 2023/03/01.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 생성 방법으로는 create, just, of, from, range 가 존재합니다.
        // 제거 방법으로는 empty, never, disposable이 존재합니다.
        
        // MARK: - just
        // 오직 하나의 Observable sequence만을 생성
        let justObservable = Observable.just("Hello World")
        
        
        justObservable.subscribe(onNext: { element in
            print(element)
        })
        
        // Hello World
        
        // MARK: - of
        // of 안쪽의 타입은 동일해야 한다.
        // element을 순차적으로 방출시킨다. (방출 이벤트: element -> array)
        let ofObservable: Observable<Int> = Observable.of(1, 2, 3)
        let ofObservableArr: Observable<[Int]> = Observable.of([1, 2, 3])
        
        ofObservable.subscribe(onNext: { element in
            print(element)
        })
        
        // 1
        // 2
        // 3
        
        // 배열 자체를 한개의 element로 취급해서 방출시킨다.
        ofObservableArr.subscribe(onNext: { element in
            print(element)    })
    }
}

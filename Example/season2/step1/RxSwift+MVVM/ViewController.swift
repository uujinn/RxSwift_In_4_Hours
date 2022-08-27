//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"
//
//class Observable<T>{
//  private let task: (@escaping (T) -> Void) -> Void
//
//  init(task: @escaping (@escaping (T) -> Void ) -> Void){
//    self.task = task
//  }
//
//  func subscribe(_ f: @escaping (T) -> Void){
//    task(f)
//  }
//}

class ViewController: UIViewController {
  @IBOutlet var timerLabel: UILabel!
  @IBOutlet var editView: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
      self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
    }
  }
  
  private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
    guard let v = v else { return }
    UIView.animate(withDuration: 0.3, animations: { [weak v] in
      v?.isHidden = !s
    }, completion: { [weak self] _ in
      self?.view.layoutIfNeeded()
    })
  }
  
  // PromiseKit
  // Bolt
  // RxSwift
  
  // Observable의 생명주기
  // 1. Create
  // 2. Subscribe
  // 3. onNext
  // ---- 끝 ----
  // 4. onCompleted / onError
  // 5. Disposed
  
  // 비동기로 생기는 데이터를 어떻게 return 값으로 만들지?
  func downloadJson(_ url: String) -> Observable<String?> { // 나중에 실행되는 함수 -> @escaping
    // 1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
    //        return Observable.just("Hello World")
    //    return Observable.from(["Hello", "World"]) // Sugar API
    
    //    return Observable.create { emitter in
    //      emitter.onNext("Hello Word")
    //      emitter.onCompleted()
    //
    //      return Disposables.create()
    //
    //    }
    
    
    return Observable.create(){ emitter in
      let url = URL(string: url)!
      let task = URLSession.shared.dataTask(with: url) { (data, _, err) in
        guard err == nil else {
          emitter.onError(err!)
          return
        }
        
        if let dat = data, let json = String(data: dat, encoding: .utf8){
          emitter.onNext(json)
        }
        
        emitter.onCompleted()
      }
      
      task.resume()
      
      return Disposables.create() {
        task.cancel()
      }
    }
    
    //    return Observable.create() { f in
    //      DispatchQueue.global().async {
    //        let url = URL(string: url)!
    //        let data = try! Data(contentsOf: url)
    //        let json = String(data: data, encoding: .utf8)
    //
    //        DispatchQueue.main.async {
    //          f.onNext(json)
    //          f.onCompleted()
    //        }
    //
    //      }
    //
    //      return Disposables.create()
    //
    //    }
    
  }
  
  // MARK: SYNC
  
  @IBOutlet var activityIndicator: UIActivityIndicatorView!
  
  @IBAction func onLoad() {
    editView.text = ""
    setVisibleWithAnimation(activityIndicator, true)
    
    
    // 2. Observable로 오는 데이터를 받아서 처리하는 방법
    
    _ = downloadJson(MEMBER_LIST_URL)
      .map { json in json?.count ?? 0 } // operator
      .filter { cnt in cnt > 0 } // operator
      .map { "\($0)" } // operator
      .observeOn(MainScheduler.instance) // sugar api: operator
      .subscribe(onNext: { json in
        self.editView.text = json
        self.setVisibleWithAnimation(self.activityIndicator, false)
      }, onCompleted: { print("Completed") })
    
    //    let observable = downloadJson(MEMBER_LIST_URL)
    //    let disposable = observable.subscribe{ event in
    //      switch event{
    //      case .next(let json):
    //        print(json)
    //        break
    //      case .completed:
    //        break
    //      case .error(let err):
    //        break
    //      }
    //    }
    
    //    disposable.dispose()
    
    
    
    //    let ob = downloadJson(MEMBER_LIST_URL)
    //    let disp = ob
    //      .debug()
    //      .subscribe { event in // Subscribe 해야 실행됨
    //          switch event{
    //          case let .next(json): // RxSwift 비동기로 생기는 결과값을 completion Closure으로 전달하지 않고, return 값으로 전달하기 위해 사용하는 utility
    //            DispatchQueue.main.async {
    //              self.editView.text = json
    //              self.setVisibleWithAnimation(self.activityIndicator, false)
    //            }
    //          case .completed:
    //            break
    //          case .error:
    //            break
    //          }
    //      }
    
  }
}

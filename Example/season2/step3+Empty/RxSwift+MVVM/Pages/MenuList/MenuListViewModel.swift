//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by 양유진 on 2022/09/07.
//  Copyright © 2022 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

class MenuListViewModel {
  
  lazy var menuObservable = PublishSubject<[Menu]>()
  
  lazy var itemsCount = menuObservable.map {
    $0.map { $0.count }.reduce(0, +)
  }
  
  lazy var totalPrice = menuObservable.map {
    $0.map { $0.price * $0.count }.reduce(0, +)
  }
  
  init() {
    var menus: [Menu] = [
      Menu(name: "튀김1", price: 100, count: 0),
      Menu(name: "튀김1", price: 100, count: 0),
      Menu(name: "튀김1", price: 100, count: 0),
      Menu(name: "튀김1", price: 100, count: 0)
    ]
    
    menuObservable.onNext(menus)
  }
  
}

//
//  ReactiveCocoa+Extensions.swift
//  RAC3Example
//
//  Created by Masahiko TSUJITA on 2015/08/30.
//  Copyright (c) 2015年 Masahiko Tsujita. All rights reserved.
//

import Foundation
import ReactiveCocoa

/**
Creates a boolean `signal` which negates each value of the given boolean `signal`.
*/
prefix func !<E>(source: Signal<Bool, E>) -> Signal<Bool, E> {
    return source |> map { value in !value }
}

/**
Creates a boolean `signal producer` which negates each value of the given boolean `signal`.
*/
prefix func !<E>(source: SignalProducer<Bool, E>) -> SignalProducer<Bool, E> {
    return source |> map { value in !value }
}

/**
Creates a boolean `signal` which negates each value of the given boolean `signal`.
*/
func not<E>() -> Signal<Bool, E> -> Signal<Bool, E> {
    return { !$0 }
}

/**
Creates a boolean `signal` which takes logical product of given boolean signals.
*/
func &&<E>(a: Signal<Bool, E>, b: Signal<Bool, E>) -> Signal<Bool, E> {
    return combineLatest(a, b) |> map { $0 && $1 }
}

/**
Creates a boolean `signal` which takes logical disjunction of given boolean signals.
*/
func ||<E>(a: Signal<Bool, E>, b: Signal<Bool, E>) -> Signal<Bool, E> {
    return combineLatest(a, b) |> map { $0 || $1 }
}

/**
Creates a boolean `signal producer` which takes logical product of given boolean signal producers.
*/
func &&<E>(a: SignalProducer<Bool, E>, b: SignalProducer<Bool, E>) -> SignalProducer<Bool, E> {
    return combineLatest(a, b) |> map { $0 && $1 }
}

/**
Creates a boolean `signal producer` which takes logical disjunction of given boolean signal producers.
*/
func ||<E>(a: SignalProducer<Bool, E>, b: SignalProducer<Bool, E>) -> SignalProducer<Bool, E> {
    return combineLatest(a, b) |> map { $0 || $1 }
}

/**
Unwraps non-`nil` values from `signal` and forwards them on the returned signal, `nil` values are dropped.
*/
func ignoreNil<T, E>() -> Signal<T?, E> -> Signal<T, E> {
    return { ignoreNil($0) }
}

/**
Maps to a pulse `signal producer`(`SignalProducer<(), NoError>`). Each values and error are ignored.
*/
func toPulse<T, E>() -> SignalProducer<T, E> -> SignalProducer<(), NoError> {
    return { source in
        return source
            |> map { _ in () }
            |> catch { _ in SignalProducer.empty }
    }
}

/**
Maps the given `signal producer` to a pulse `signal producer`(`SignalProducer<(), NoError>`). Each values and error are ignored.
*/
func pulseFrom<T, E>(source: SignalProducer<T, E>) -> SignalProducer<(), NoError> {
    return source |> toPulse()
}

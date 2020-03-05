import RxSwift
import AVFoundation

final class RxSwiftHelper {

    static func weakSelfDisposable<T>(subscriber: (SingleEvent<T>) -> Void) -> Cancelable {
        subscriber(.error(ShopmiumAppError.unknownError(source: "Self should not be nil.")))
        return Disposables.create { }
    }

    static func weakSelfDisposable<T>(subscriber: (MaybeEvent<T>) -> Void) -> Cancelable {
        subscriber(.error(ShopmiumAppError.unknownError(source: "Self should not be nil.")))
        return Disposables.create { }
    }

    static func weakSelfDisposable(subscriber: (CompletableEvent) -> Void) -> Cancelable {
        subscriber(.error(ShopmiumAppError.unknownError(source: "Self should not be nil.")))
        return Disposables.create { }
    }
}

extension Observable {
    /** Transform an Observable<T> to an Observable<Void> **/
    func toVoidObservable() -> Observable<Void> {
        return map({ _ -> Void in () })
    }

    /** Transform an Observable<T> to a Single<T> **/
    func toSingle() -> Single<Element> {
        return self
            .take(1)
            .asSingle()
    }

    /** Transform an Observable<T> to a Maybe<T> **/
    func toMaybe() -> Maybe<Element> {
        return self
            .take(1)
            .asMaybe()
    }
}

extension ObservableType {

    func observeOnMain() -> Observable<E> {
        return observeOn(MainScheduler.instance)
    }

    func observeOnBackground(qos: DispatchQoS = .default) -> Observable<E> {
        return observeOn(ConcurrentDispatchQueueScheduler(qos: qos))
    }

    func subscribeOnMain() -> Observable<E> {
        return subscribeOn(MainScheduler.instance)
    }

    func subscribeOnBackground(qos: DispatchQoS = .default) -> Observable<E> {
        return subscribeOn(ConcurrentDispatchQueueScheduler(qos: qos))
    }

    func asCompletableGeneric() -> PrimitiveSequence<CompletableTrait, Never> {
        return self
            .flatMap { _ in Observable<Never>.empty() }
            .asCompletable()
    }
}

extension PrimitiveSequence {

    func observeOnMain() -> PrimitiveSequence<Trait, Element> {
        return observeOn(MainScheduler.instance)
    }

    func observeOnBackground(qos: DispatchQoS = .default) -> PrimitiveSequence<Trait, Element> {
        return observeOn(ConcurrentDispatchQueueScheduler(qos: qos))
    }

    func subscribeOnMain() -> PrimitiveSequence<Trait, Element> {
        return subscribeOn(MainScheduler.instance)
    }

    func subscribeOnBackground(qos: DispatchQoS = .default) -> PrimitiveSequence<Trait, Element> {
        return subscribeOn(ConcurrentDispatchQueueScheduler(qos: qos))
    }
}

extension PrimitiveSequence where TraitType == MaybeTrait {
    public func asCompletable() -> PrimitiveSequence<CompletableTrait, Never> {
        return self.asObservable()
            .flatMap { _ in Observable<Never>.empty() }
            .asCompletable()
    }
}

extension PrimitiveSequence where TraitType == SingleTrait {
    public func asMaybe() -> PrimitiveSequence<MaybeTrait, Element> {
        return self.asObservable().asMaybe()
    }

    public func asCompletable() -> PrimitiveSequence<CompletableTrait, Never> {
        return self.asObservable()
            .flatMap { _ in Observable<Never>.empty() }
            .asCompletable()
    }
}

extension PrimitiveSequence where TraitType == CompletableTrait, ElementType == Swift.Never {
    public func asMaybe() -> PrimitiveSequence<MaybeTrait, Element> {
        return self.asObservable().asMaybe()
    }
}

extension Reactive where Base: AVPlayer {
    public var status: Observable<AVPlayer.Status> {
        return self.observe(AVPlayer.Status.self, #keyPath(AVPlayer.status))
            .map { $0 ?? .unknown }
    }
}

extension Reactive where Base: AVPlayerItem {
    public var status: Observable<AVPlayer.Status> {
        return self.observe(AVPlayer.Status.self, #keyPath(AVPlayer.status))
            .map { $0 ?? .unknown }
    }
}

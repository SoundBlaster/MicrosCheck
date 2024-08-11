typealias State = Hashable & CustomStringConvertible

protocol StateMachine {
    associatedtype S: State
    var state: S { get }
    @discardableResult
    mutating func updateState(to nextState: S) throws -> S
    var routes: [S: [S]] { get }
}

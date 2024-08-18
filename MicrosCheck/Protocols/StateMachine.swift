protocol StateMachine {
    associatedtype S: Hashable & CustomStringConvertible
    var state: S { get }
    @discardableResult
    mutating func updateState(to nextState: S) throws -> S
    var routes: [S: [S]] { get }
}

/// A least-recently-used cache with a limit on the number of entries and on their total cost.
///
/// Reading or writing an entry makes it the most recently used. When a limit is exceeded,
/// the least recently used entries are removed until both limits hold again. All operations
/// take constant time.
///
/// `LRUCache` is a value type without locking; ``MemoryResponseCache`` wraps it in an actor.
///
/// ```swift
/// var cache = LRUCache<String, Data>(countLimit: 100, costLimit: 10_000_000)
/// cache.setValue(data, forKey: url, cost: data.count)
/// let hit = cache.value(forKey: url)
/// ```
public struct LRUCache<Key: Hashable, Value> {
    fileprivate struct Node {
        let key: Key
        var value: Value
        var cost: Int
        var previous: Int?
        var next: Int?
    }

    /// The most entries kept. Negative values are treated as 0.
    public let countLimit: Int

    /// The largest total cost kept. Negative values are treated as 0.
    public let costLimit: Int

    private var nodes: [Node?] = []
    private var freeSlots: [Int] = []
    private var indices: [Key: Int] = [:]
    private var head: Int?
    private var tail: Int?

    /// The sum of the costs of the entries.
    public private(set) var totalCost = 0

    /// Creates an empty cache.
    public init(countLimit: Int = .max, costLimit: Int = .max) {
        self.countLimit = max(0, countLimit)
        self.costLimit = max(0, costLimit)
    }

    /// The number of entries.
    public var count: Int { indices.count }

    /// The keys from the most to the least recently used.
    public var keys: [Key] {
        var result: [Key] = []
        var index = head
        while let current = index, let node = nodes[current] {
            result.append(node.key)
            index = node.next
        }
        return result
    }

    /// Returns the value for `key` and marks it as the most recently used.
    public mutating func value(forKey key: Key) -> Value? {
        guard let index = indices[key] else { return nil }
        moveToFront(index)
        return nodes[index]?.value
    }

    /// Returns the value for `key` without changing the order.
    public func peek(_ key: Key) -> Value? {
        indices[key].flatMap { nodes[$0]?.value }
    }

    /// Stores `value` as the most recently used entry. An entry whose cost alone exceeds
    /// ``costLimit`` is not stored, and any older value for the key is removed.
    public mutating func setValue(_ value: Value, forKey key: Key, cost: Int = 0) {
        let cost = max(0, cost)
        removeValue(forKey: key)
        guard cost <= costLimit, countLimit > 0 else { return }
        // Make room first; comparing with costLimit - cost cannot overflow, unlike a sum.
        while count >= countLimit || totalCost > costLimit - cost, let tail, let oldest = nodes[tail]?.key {
            removeValue(forKey: oldest)
        }
        let node = Node(key: key, value: value, cost: cost, previous: nil, next: head)
        let index: Int
        if let free = freeSlots.popLast() {
            nodes[free] = node
            index = free
        } else {
            nodes.append(node)
            index = nodes.count - 1
        }
        if let head { nodes[head]?.previous = index }
        head = index
        if tail == nil { tail = index }
        indices[key] = index
        totalCost += cost
    }

    /// Removes the value for `key` and returns it.
    @discardableResult
    public mutating func removeValue(forKey key: Key) -> Value? {
        guard let index = indices.removeValue(forKey: key), let node = nodes[index] else { return nil }
        unlink(index)
        nodes[index] = nil
        freeSlots.append(index)
        totalCost -= node.cost
        return node.value
    }

    /// Removes every entry.
    public mutating func removeAll() {
        self = LRUCache(countLimit: countLimit, costLimit: costLimit)
    }

    private mutating func moveToFront(_ index: Int) {
        guard head != index else { return }
        unlink(index)
        nodes[index]?.previous = nil
        nodes[index]?.next = head
        if let head { nodes[head]?.previous = index }
        head = index
        if tail == nil { tail = index }
    }

    private mutating func unlink(_ index: Int) {
        guard let node = nodes[index] else { return }
        if let previous = node.previous { nodes[previous]?.next = node.next } else { head = node.next }
        if let next = node.next { nodes[next]?.previous = node.previous } else { tail = node.previous }
        nodes[index]?.previous = nil
        nodes[index]?.next = nil
    }
}

extension LRUCache: Sendable where Key: Sendable, Value: Sendable {}
extension LRUCache.Node: Sendable where Key: Sendable, Value: Sendable {}

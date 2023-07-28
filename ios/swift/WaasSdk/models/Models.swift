extension Encodable {
    public func asDictionary() -> NSDictionary {
        guard let data = try? JSONEncoder().encode(self) else { return NSDictionary() }
        return ((try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] } as? NSDictionary) ?? NSDictionary()
    }
}

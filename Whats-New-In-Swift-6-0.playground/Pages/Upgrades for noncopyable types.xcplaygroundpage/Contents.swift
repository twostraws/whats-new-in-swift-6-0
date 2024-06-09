/*:


&nbsp;

[< Previous](@previous)           [Home](Introduction)           [Next >](@next)
# Upgrades for noncopyable types

Noncopyable types were [introduced in Swift 5.9](/swift/5.9/noncopyable-structs-and-enums), but are getting several upgrades in Swift 6.

As a reminder, noncopyable types allow us create types that have unique ownership, which we can pass around using borrowing or consuming as needed.

One example of noncopyable types I previously used were the secret messages used in the Mission Impossible movies – they famously self-destruct after being read, which we can model with a noncopyable type that is consumed (i.e. destroyed) upon reading:
*/
struct Message: ~Copyable {
    var agent: String
    private var message: String
    
    init(agent: String, message: String) {
        self.agent = agent
        self.message = message
    }
    
    consuming func read() {
        print("\(agent): \(message)")
    }
}
    
func createMessage() {
    let message = Message(agent: "Ethan Hunt", message: "You need to abseil down a skyscraper for some reason.")
    message.read()
}
    
createMessage()
/*:
In that code, the compiler enforces that `message.read()` can only ever be called once, because it consumes the object.

The first major improvement is [SE-0427](https://github.com/apple/swift-evolution/blob/main/proposals/0427-noncopyable-generics.md), which introduces a batch of improvements at once. The biggest of those is that every struct, class, enum, generic type parameter, and protocol in Swift 6 automatically conforms to a new `Copyable` protocol unless you explicitly opt out using `~Copyable`.

This impacts on the other changes introduced with this proposal. For example, noncopyable types can now be used with generics, allowing things like *optional* noncopyable instances because Swift's `Optional` is implemented a generic enum. However, because generic type parameters automatically conform to `Copyable` we must explicitly opt out using `~Copyable`.

Similarly, this change means noncopyable types can now conform to protocols, but only when those protocols are also marked `~Copyable` because otherwise they get automatically opted into `Copyable` as mentioned above. (In case you were curious, `Copyable` types can conform to noncopyable protocols just fine.)

[SE-0429](https://github.com/apple/swift-evolution/blob/main/proposals/0429-partial-consumption.md) improves things further by adding partial consumption of noncopyable values.

Previously it could be a problem when one noncopyable type incorporated another. For example, even fairly trivial code like the below was a problem before [SE-0429](https://github.com/apple/swift-evolution/blob/main/proposals/0429-partial-consumption.md):
*/
struct Package: ~Copyable {
    var from: String = "IMF"
    var message: Message
    
    consuming func read() {
        message.read()
    }
}
/*:
That code is now valid Swift, as long as the types in question don't have deinitializers. 

A third major noncopyable improvement is [SE-0432](https://github.com/apple/swift-evolution/blob/main/proposals/0432-noncopyable-switch.md), which allows us to borrow noncopyable types while switching over them. Previously it was impossible to do pattern matching with `where` clauses that depended on noncopyable values, whereas thanks to SE-0432 this is now possible in Swift 6.

Continuing our Mission Impossible example, we could say that one set of orders might be signed or anonymous, like this:
*/
enum ImpossibleOrder: ~Copyable {
    case signed(Package)
    case anonymous(Message)
}
/*:
Because that enum has associated values that are noncopyable, it must itself be noncopyable. However, the associated values being noncopyable also means that pattern matching with `where` was tricky – if you wanted to perform one set of actions for one `Message` type, and a different set for another `Message` type, you were out of luck.

With [SE-0432](https://github.com/apple/swift-evolution/blob/main/proposals/0432-noncopyable-switch.md) this is now resolved, meaning code like the below is now allowed:
*/
func issueOrders() {
    let message = Message(agent: "Ethan Hunt", message: "You need to abseil down a skyscraper for some reason.")
    let order = ImpossibleOrder.anonymous(message)
    
    switch consume order {
    case .signed(let package):
        package.read()
    case .anonymous(let message) where message.agent == "Ethan Hunt":
        print("Play dramatic music")
        message.read()
    case .anonymous(let message):
        message.read()
    }
}
/*:
Put together, this collection of changes helps make noncopyable types work much more naturally in Swift.

&nbsp;

[< Previous](@previous)           [Home](Introduction)           [Next >](@next)
*/
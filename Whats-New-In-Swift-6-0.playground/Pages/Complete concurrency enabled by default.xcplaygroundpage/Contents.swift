/*:


&nbsp;

[< Previous](@previous)           [Home](Introduction)           [Next >](@next)
# Complete concurrency enabled by default

Swift 6 contains another barrage of updates around concurrency, and the team ought to be proud of the extraordinary advances they have made to make this release possible.

By far the biggest change is that complete concurrency checking is enabled by default. Unless you're very fortunate indeed, there's a very good chance your code will need some adjustment – it's no surprise the Swift team made it optional in earlier versions to give folks time to evaluate what's changing.

Swift 6 improves concurrency checking further, and the Swift team say it "removes many false-positive data-race warnings" that were present in 5.10. It also introduces several targeted changes that will do wonders to make concurrency easier to adopt – if you tried with 5.10 and found things just too gnarly to figure out, hopefully some of the changes in Swift 6 will help.

Easily the biggest is [SE-0414](https://github.com/apple/swift-evolution/blob/main/proposals/0414-region-based-isolation.md), defines isolation regions that allow the compiler to conclusively prove different parts of your code can run concurrently.

At the core of this change lies the existing concept of *sendability*. A `Sendable` type is one that can be safely passed around in a concurrent environment, which can include value types such as structs, final classes with constant properties, actors that automatically protect their own mutable state, and more. 

Before Swift 6 the compiler was very strict: if you had a non-sendable value on one actor and tried to send it to another actor, you'd get concurrency checking warnings. For example, although SwiftUI view bodies run on the main actor, SwiftUI views themselves *don't*, which can easily cause all sorts of false positive warnings from the compiler – Swift thinks there's a potential race condition when really there isn't.

You can see the problem with the following code:
*/
import SwiftUI

class User {
    var name = "Anonymous"
}
    
struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .task {
                let user = User()
                await loadData(for: user)
            }
    }
    
    func loadData(for user: User) async {
        print("Loading data for \(user.name)…")
    }
}
/*:
Before Swift 6 the call to `loadData()` would throw up a warning: "passing argument of non-sendable type 'User' outside of main actor-isolated context may introduce data races."

*After* Swift 6 this warning goes away: Swift now detects that the code doesn't actually present a problem because `user` isn't being accessed from two or more places at once, so it won't emit a warning – the compiler is able to analyze the program's flow and detect that it's safe.

This change effectively means sendable objects are now either those that conform to `Sendable`, or those that don't need to conform to `Sendable` because the compiler can prove they are being used safely – it's a dramatic simplification of concurrency for developers, made possible by truly cutting-edge compiler development.

But there are many other, smaller improvements, including:

- [SE-430](https://github.com/apple/swift-evolution/blob/main/proposals/0430-transferring-parameters-and-results.md) adds a new `sending` keyword for when we need to send values between isolation regions.
- [SE-0423](https://github.com/apple/swift-evolution/blob/main/proposals/0423-dynamic-actor-isolation.md) improves concurrency support when needing to operate with Objective-C frameworks.
- [SE-0420](https://github.com/apple/swift-evolution/blob/main/proposals/0420-inheritance-of-actor-isolation.md) allows us to make `async` functions that are isolated to the same actor as their caller.

Some other changes were present in earlier versions of Swift, but hidden behind feature flags. For example, [SE-0401](https://github.com/apple/swift-evolution/blob/main/proposals/0401-remove-property-wrapper-isolation.md) removes a feature that was introduced back in Swift 5.5: actor inference for property wrappers.

Previously, any struct or class using a property wrapper with `@MainActor` for its wrapped value will automatically be `@MainActor`. This is what makes `@StateObject` and `@ObservedObject` convey "main-actor-ness" on SwiftUI views that use them – if you use either of those two property wrappers in a SwiftUI view, the whole view becomes `@MainActor` too.

As an example, consider the view model below, marked with `@MainActor` as is good practice:
*/
@MainActor
class ViewModel: ObservableObject {
    func authenticate() {
        print("Authenticating…")
    }
}
/*:
If you want to use that from a SwiftUI view using `@StateObject`, you must *also* mark the view with `@MainActor` from Swift 6 and later, like this:
*/
@MainActor
struct LogInView: View {
    @StateObject private var model = ViewModel()
    
    var body: some View {
        Button("Hello, world", action: startAuthentication)
    }
    
    func startAuthentication() {
        model.authenticate()
    }
}
/*:
Before Swift 6, `@MainActor` would have been conferred on the whole view because of its `@StateObject` property.

Another old changed that's now enable in Swift 6 is [SE-0412](https://github.com/apple/swift-evolution/blob/main/proposals/0412-strict-concurrency-for-global-variables.md) requires global variables to be safe in concurrent environments.

This applies to loose variables you might have in your projects at global scope:
*/
var gigawatts = 1.21
/*:
But also to static variables stored in types:
*/
struct House {
    static var motto = "Winter is coming"
}
/*:
This data can be accessed anywhere at any time, which makes it inherently unsafe. To resolve the problem you either need to convert the variable into a sendable constant, restrict it to a global actor, e.g. `@MainActor`, or, if you have no other option or know it's protected somewhere else, mark it nonisolated.

For example, all of these are allowed:
*/
struct XWing {
    @MainActor
    static var sFoilsAttackPosition = true
}
    
struct WarpDrive {
    static let maximumSpeed = 9.975
}
    
@MainActor
var idNumber = 24601
    
// Not recommended unless you're certain it's safe
nonisolated(unsafe) var britishCandy = ["Kit Kat", "Mars Bar", "Skittles", "Starburst", "Twix"]
/*:
Another feature present earlier but now enabled is [SE-0411](https://github.com/apple/swift-evolution/blob/main/proposals/0411-isolated-default-values.md), which changes function default values to have the same isolation as the function they are inside.

For example, the code below is now allowed, when previously it would have triggered an error:
*/
@MainActor
class Logger {
    
}
    
@MainActor 
class DataController {
    init(logger: Logger = Logger()) {
    
    }
}
/*:
Because both `DataController` and `Logger` have been restricted to the main actor, Swift now considers the `Logger()` creation to also be restricted to the main actor, which makes perfect sense.

Swift concurrency remains a bit of a moving target, but if you'd like to know more I highly recommend [Matt Massicotte's blog](https://www.massicotte.org) – I don't think anyone is doing more to educate Swift developers about effective adoption of Swift concurrency.

And remember: if Swift 6 throws up concurrency warnings and errors about your code, those problems were there beforehand too – they just weren't being diagnosed automatically!

&nbsp;

[< Previous](@previous)           [Home](Introduction)           [Next >](@next)
*/

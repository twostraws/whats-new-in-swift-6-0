/*:


&nbsp;

[< Previous](@previous)           [Home](Introduction)           [Next >](@next)
# Access-level modifiers on import declarations

[SE-0409](https://github.com/apple/swift-evolution/blob/main/proposals/0409-access-level-on-imports.md) adds the ability to mark import declarations with access control modifiers, such as `private import SomeLibrary`.

There are various ways this will be useful, including the ability for library developers to avoid accidentally leaking their own dependencies. For example, a banking might be split into multiple parts:

- The app itself, presenting the user interface.
- A Banking library that handles all the functionality and core logic.
- Several smaller, internal libraries that handle individual pieces of work that are lower level, such as a Transactions package, a Networking package, and so on.

So, the app depends on the Banking library, and the Banking library in turn depends on Transactions, Networking, and other internal libraries.

We can demonstrate that setup with some code that also demonstrates the problem being resolved here. First, we could say that the low-level Transactions package has a struct such as this one: 
*/
public struct BankTransaction {
    // code here
}
/*:
Up in the Banking library we might write a function to send money from one account number to another using that `BankTransaction`:
*/
public func sendMoney(from: Int, to: Int) -> BankTransaction {
    // handle sending money then send back the result
    return BankTransaction()
}
/*:
And now in the main app we can call `sendMoney()` to do the work.

That's all regular Swift code, but it can create a rather unpleasant problem: very often wrapper libraries don't want to reveal the inner workings of the libraries they rely on internally, which is exactly what happens here – our main app is given access to the `BankTransaction` struct from the Transactions library, when really it should only use APIs from the Banking library.

From 6.0 onwards we can solve this problem by using access control on the import for Transactions: by using `internal import Transactions` or similar in the Banking library, Swift will refuse to build any code declared as public that exposes API from the Transactions library.

This really helps to clear up code boundaries: the Banking framework can still go ahead and use all the libraries it wants internally, but it won't be allowed to send those back to clients – the app in this case – by accident. If we genuinely did want to expose the internal framework types, we would use `public import Transactions` to make that explicit.

On a more fine-grained level, this also allows files inside the same module to add extra restrictions – one file could privately import a framework without wanting to accidentally expose the contents of that framework elsewhere.

Although Swift 6 hasn't shipped yet, it's looking like the default for imports will be `internal` when running in Swift 6 mode, but `public` in Swift 5 mode to retain compatibility with existing code.

&nbsp;

[< Previous](@previous)           [Home](Introduction)           [Next >](@next)
*/
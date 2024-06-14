/*:


&nbsp;

[< Previous](@previous)           [Home](Introduction)           [Next >](@next)
# Typed throws

[SE-0413](https://github.com/apple/swift-evolution/blob/main/proposals/0413-typed-throws.md) introduced the ability to specify exactly what types of errors a function can throw, known as "typed throws". This resolves an annoyance with errors in Swift: we needed a general catch clause even when we had specifically caught all possible errors.

As an example of typed throws, we could define a `CopierError` that can track when a photocopier runs out of paper:
*/
enum CopierError: Error {
    case outOfPaper
}
/*:
We could then create a `Photocopier` struct that creates some number of copies of a page. This might throw errors if there isn't enough paper loaded for the requested operation, but rather than mark it simply as `throws` we'll use `throws(CopierError)` to be clear exactly what kind of errors can be thrown:
*/
struct Photocopier {
    var pagesRemaining: Int
    
    mutating func copy(count: Int) throws(CopierError) {
        guard count <= pagesRemaining else {
            throw CopierError.outOfPaper
        }
    
        pagesRemaining -= count
    }
}
/*:
- important:  With this change you can either use `throws` to specify any kind of error being thrown, or `throws(OneSpecificErrorType)` to signal that only that one type can be thrown. You cannot write `throws(A, B, C)` to throw one of several errors.

Now we can write code to attempt photocopying, catching the single error that can possibly be thrown:
*/
do {
    var copier = Photocopier(pagesRemaining: 100)
    try copier.copy(count: 101)
} catch CopierError.outOfPaper {
    print("Please refill the paper")
}
/*:
That call site is the important change here: in earlier versions of Swift we'd need a so-called "Pokémon catch" at the end, because Swift couldn't be sure exactly error types could be thrown – you've "gotta catch 'em all."

This comes with several other advantages:

1. Because Swift knows that `CopierError` is the only error type that can be thrown, we can write `throw .outOfPaper`.
2. If the code in a `do` block only throws one kind of error, the `error` value in a general `catch` block will automatically have the same error type rather than being any kind of error.
3. If we attempt to throw any other kind of error not listed in the `throws` clause, Swift will issue a compile error.

Where this gets really clever is that `throws(any Error)` is equivalent to using just `throws` by itself, and `throws(Never)` is equivalent to a non-throwing function. That might sound obscure, but it means in many places `rethrows` can be expressed more clearly: the function throws whatever the function parameter throws.

As an example, Swift 6's new `count(where:)` method accepts a closure used to evaluate how many items match whatever kind of filter you're running. That closure might throw errors, and if it does `count(where:)` will throw that same error type:
*/
public func count<E, Element>(
    where predicate: (Element) throws(E) -> Bool
) throws(E) -> Int {
    print("Code goes here")
    return 0
}
/*:
If that closure *doesn't* throw an error, `throws(E)` is effectively `throws(Never)`, meaning that `count(where:)` will also not throw errors.

Even though typed throws seem very appealing, they are aren't a great choice when the errors that can be thrown might change in the future. They are a particularly poor choice in library code, because they lock you into a contract you might not want to stick to in the future.

In fact, here I'll just defer to the authors of the evolution proposal, who sum it up like this: **even with the addition of typed throws to Swift, untyped throws is better for most scenarios.**

Where typed throws *are* particularly useful is in the increasingly important realm of embedded Swift, where performance and predictability is critical.

&nbsp;

[< Previous](@previous)           [Home](Introduction)           [Next >](@next)
*/

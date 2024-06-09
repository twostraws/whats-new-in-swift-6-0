/*:


&nbsp;

[< Previous](@previous)           [Home](Introduction)           [Next >](@next)
# Pack iteration

[SE-0408](https://github.com/apple/swift-evolution/blob/main/proposals/0408-pack-iteration.md) introduces pack iteration, which adds the ability to loop over the parameter pack feature introduced in Swift 5.9.

Although value packs remain one of the most complex features of Swift, the evolution proposal shows just how useful this feature is by adding tuple comparison for any arity in just a few lines of code:
*/
func == <each Element: Equatable>(lhs: (repeat each Element), rhs: (repeat each Element)) -> Bool {
    for (left, right) in repeat (each lhs, each rhs) {
        guard left == right else { return false }
    }
    return true
}
/*:
If that means nothing to you, the Simple English version is that [SE-0015](https://github.com/apple/swift-evolution/blob/main/proposals/0015-tuple-comparison-operators.md) added support for direct tuple comparison up to arity 6, meaning that two tuples with up to six items could be compared using ==. If you tried comparing tuples with seven items – e.g. `(1, 2, 3, 4, 5, 6, 7) == (1, 2, 3, 4, 5, 6, 7)` – Swift would throw up an error. SE-0408, along with the code above, removes that restriction.

Tantalizingly, the [Future Directions section](https://github.com/apple/swift-evolution/blob/main/proposals/0408-pack-iteration.md#future-directions) of this evolution proposal suggest that in the future we might see a variant of Swift's `zip()` function that supports any number of sequences.

&nbsp;

[< Previous](@previous)           [Home](Introduction)           [Next >](@next)
*/
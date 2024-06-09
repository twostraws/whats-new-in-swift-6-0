/*:


&nbsp;

[< Previous](@previous)           [Home](Introduction)
# BitwiseCopyable

[SE-0426](https://github.com/apple/swift-evolution/blob/main/proposals/0426-bitwise-copyable.md) introduces a new `BitwiseCopyable` protocol, which has the sole purpose of allowing the compiler to create more optimized code for conforming types.

*Most of the time you don't need to do anything to enable `BitwiseCopyable` support*. Swift will automatically apply it to most structs and enums you create as long as all the properties they contain are also bitwise copyable. That includes a huge collection of built-in types: all integers, all floating-point numbers, `Bool`, `Duration`, `StaticString`, and more.

Where things take a little more thinking is when you're building a library – if Swift were to automatically apply a conformance to `BitwiseCopyable` it could cause problems if your type changed in the future in a way that made it *not* support the protocol.

So, Swift disables the automatic inference for types you export with `public` or `package` visibility unless you explicitly mark those types with `@frozen`.

If you specifically need to disable `BitwiseCopyable`, you can do that by adding `~BitwiseCopyable` to your type's inheritance list. For example, the standard library's `CommandLine` enum is both `public` and `@frozen`, so the Swift team explicitly opt out of it being bitwise copyable like this:
*/
@frozen
public enum CommandLine : ~BitwiseCopyable {
}
/*:
**Important:** Opting out of `BitwiseCopyable` must happen directly where your type is declared rather than in an extension.

&nbsp;

[< Previous](@previous)           [Home](Introduction)
*/
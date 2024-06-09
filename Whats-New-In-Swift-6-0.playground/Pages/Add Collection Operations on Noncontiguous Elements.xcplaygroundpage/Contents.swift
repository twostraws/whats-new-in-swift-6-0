/*:


&nbsp;

[< Previous](@previous)           [Home](Introduction)           [Next >](@next)
# Add Collection Operations on Noncontiguous Elements

[SE-0270](https://github.com/apple/swift-evolution/blob/main/proposals/0270-rangeset-and-collection-operations.md) introduces various new methods to handle more complex operations on collections, such as moving or remove multiple items that aren't contiguous.

This change is powered by a new type called `RangeSet`. If you've ever used `IndexSet` from Foundation, think of `RangeSet` as being `IndexSet` except for any kind of `Comparable` type rather than just integers. 

Lots of Swift API has been upgraded to `RangeSet`. To give us some example data to work with, we could create an array of students with exam results like this:
*/
struct ExamResult {
    var student: String
    var score: Int
}
    
let results = [
    ExamResult(student: "Eric Effiong", score: 95),
    ExamResult(student: "Maeve Wiley", score: 70),
    ExamResult(student: "Otis Milburn", score: 100)
]
/*:
We can get a `RangeSet` containing the indices of all students who score 85% or higher like this:
*/
let topResults = results.indices { student in
    student.score >= 85
}
/*:
And if we wanted to get access to those students, we can use a new `Collection` subscript:
*/
for result in results[topResults] {
    print("\(result.student) scored \(result.score)%")
}
/*:
This subscript returns another new type called `DiscontiguousSlice`, which is similar to `Slice` in that for performance reasons it refers to elements stored in a different collection, except the indices are *discontiguous*, meaning that they aren't necessarily adjacent in the collection.

The "set" part of the name is there because `RangeSet` supports a variety of functions that come from the `SetAlgebra` protocol, including `union()`, `intersection()`, and `isSuperset(of:)`. This also means that inserting one range into another will merge any overlapping ranges rather than creating duplicates.

&nbsp;

[< Previous](@previous)           [Home](Introduction)           [Next >](@next)
*/
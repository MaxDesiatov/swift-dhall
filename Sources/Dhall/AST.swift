//
//  Created by Max Desiatov on 18/01/2021.
//

typealias Text = String
typealias Natural = Int
typealias SHA256 = [UInt8]

// Converted from https://github.com/dhall-lang/dhall-lang/blob/v20.0.0/standard/syntax.md

struct NonEmpty<T> {
  let head: T
  let tail: [T]
}

/// Top-level type representing a Dhall expression
indirect enum Expression {
  /// > x@n
  case variable(Text, Natural)

  /// > λ(x : A) → b
  case lambda(Text, Expression, Expression)

  /// > ∀(x : A) → B
  case forall(Text, Expression, Expression)

  /// > let x : A = a in b
  /// > let x     = a in b
  case `let`(Text, Expression?, Expression, Expression)

  /// > if t then l else r
  case `if`(Expression, Expression, Expression)

  /// > merge t u : T
  /// > merge t u
  case merge(Expression, Expression, Expression?)

  /// > toMap t : T
  /// > toMap t
  case toMap(Expression, Expression?)

  /// > [] : T
  case emptyList(Expression)

  /// > [ t, ts… ]
  case nonEmptyList(NonEmpty<Expression>)

  /// > t : T
  case annotation(Expression, Expression)

  /// > l □ r
  case `operator`(Expression, Operator, Expression)

  /// > f a
  case application(Expression, Expression)

  /// > t.x
  case field(Expression, Text)

  /// > t.{ xs… }
  case projectByLabels(Expression, [Text])

  /// > t.(s)
  case projectByType(Expression, Expression)

  /// > T::r
  case completion(Expression, Expression)

  /// > assert : T
  case assert(Expression)

  /// > e with k.ks… = v
  case with(Expression, NonEmpty<Text>, Expression)

  /// > n.n
  case doubleLiteral(Double)

  /// > n
  case naturalLiteral(Natural)

  /// > ±n
  case integerLiteral(Int)

  /// > "s"
  /// > "s${t}ss…"
  case textLiteral(Text)

  /// > {}
  /// > { k : T, ks… }
  case recordType([(Text, Expression)])

  /// > {=}
  /// > { k = t, ks… }
  case recordLiteral([(Text, Expression)])

  /// > <>
  /// > < k : T | ks… >
  /// > < k | ks… >
  case unionType([(Text, Expression?)])

  case `import`(ImportType, ImportMode, SHA256?)

  /// Some s
  case some(Expression)

  case builtin(Builtin)

  case constant(Constant)
}

/// Associative binary operators
enum Operator {
  /// > ||
  case or

  ///  > +
  case plus

  /// > ++
  case textAppend

  /// > #
  case listAppend

  /// > &&
  case and

  /// > ∧
  case combineRecordTerms

  /// > ⫽
  case prefer

  /// > ⩓
  case combineRecordTypes

  /// > *
  case times

  /// > ==
  case equal

  /// > !=
  case notEqual

  /// > ===
  case equivalent

  /// > ?
  case alternative
}

/** Data structure used to represent an interpolated @Text@ literal

 A `Text` literal without any interpolations has an empty list.  For example,
 the `Text` literal `"foo"` is represented as:

 > TextLiteral [] "foo"

 A `Text` literal with interpolations has one list element per interpolation.
 For example, the `Text` literal `"foo${x}bar${y}baz"` is represented as:

 > TextLiteral [("foo", Variable "x" 0), ("bar", Variable "y" 0)] "baz"
 */
struct TextLiteral {
  let chunks: [(Text, Expression)]
  let trailing: Text
}

/// Builtin values
enum Builtin {
  case naturalBuild
  case naturalFold
  case naturalIsZero
  case naturalEven
  case naturalOdd
  case naturalToInteger
  case naturalShow
  case naturalSubtract
  case integerToDouble
  case integerShow
  case integerNegate
  case integerClamp
  case doubleShow
  case listBuild
  case listFold
  case listLength
  case listHead
  case listLast
  case listIndexed
  case listReverse
  case textShow
  case textReplace
  case bool
  case optional
  case natural
  case integer
  case double
  case text
  case list
  case `true`
  case `false`
  case none
}

/// Type-checking constants
enum Constant: Equatable {
  case type
  case kind
  case sort
}

/// How to interpret the path to the import
enum ImportMode {
  /// The default behavior: import the path as code to interpret
  case code

  /// `as Text`: import the path as raw text
  case rawText

  /// `as Location: don't import and instead represent the path as a Dhall expression
  case location
}

/// Where to locate the import
enum ImportType {
  /// > missing
  case missing

  /// > https://authority directory file
  case remote(URL)

  /// > /directory/file
  /// > ./directory/file
  /// > ../directory/file
  /// > ~/directory/file
  case path(FilePrefix, File)

  /// > env:x
  case env(Text)
}

/// Structured representation of an HTTP(S) URL
struct URL {
  let scheme: Scheme
  let authority: Text
  let path: File
  let query: Text?
  let headers: Expression?
}

/// The URL scheme
enum Scheme {
  /// `> http:\/\/`
  case http

  /// > https:\/\/
  case https
}

/// The anchor for a local file path
enum FilePrefix {
  /// `/`, an absolute path
  case absolute

  /// `.`, a path relative to the current working directory
  case here

  /// `..`, a path relative to the parent working directory
  case parent

  /// `~`, a path relative to the user's home directory
  case home
}

/** Structured representation of a file path

 Note that the directory path components are stored in reverse order,
 meaning that the path @/foo\/bar\/baz@ is represented as:

 > File{ directory = [ "bar", "foo" ], file = "baz" }
 */
struct File {
  /// Directory path components (in reverse order)
  let directory: [Text]

  /// File name
  let file: Text
}

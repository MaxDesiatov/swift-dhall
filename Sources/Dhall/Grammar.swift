import Covfefe
import Foundation

public enum DhallError: Error {
  case loadingGrammarFailed
  case decodingGrammarFailed
}

func syntaxTree(_ string: String) throws -> ParseTree {
  guard
    let url = Bundle.module.url(forResource: "dhall-grammar", withExtension: "json")
  else {
    throw DhallError.loadingGrammarFailed
  }
  let data = try Data(contentsOf: url)

  let grammar = try JSONDecoder().decode(Grammar.self, from: data)

  let parser = EarleyParser(grammar: grammar)

  return try parser.syntaxTree(for: string)
}

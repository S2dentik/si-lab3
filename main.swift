import Foundation

let arguments = CommandLine.arguments

guard arguments.count > 1 else {
    print("Usage: decipher <text>")
    exit(1)
}
/// Let's work with uppercase only
let encrypted = arguments[1].uppercased()

/// English probabilities
let probability = [
    "E": 12.02,
    "T": 9.10,
    "A": 8.12,
    "O": 7.68,
    "I": 7.31,
    "N": 6.95,
    "S": 6.28,
    "R": 6.02,
    "H": 5.92,
    "D": 4.32,
    "L": 3.98,
    "U": 2.88,
    "C": 2.71,
    "M": 2.61,
    "F": 2.30,
    "Y": 2.11,
    "W": 2.09,
    "G": 2.03,
    "P": 1.82,
    "B": 1.49,
    "V": 1.11,
    "K": 0.69,
    "X": 0.17,
    "Q": 0.11,
    "J": 0.10,
    "Z": 0.07
]

/// Remove all non-alphabetic characters
let alphaString = String(encrypted.filter { "A"..."Z" ~= $0 })

/// Calculate the occurences of each letter in the string
let occurence = alphaString.reduce([String: Int]()) { dict, letter in
    var mutableDict = dict
    mutableDict[String(letter)] = (dict[String(letter)] ?? 0) + 1

    return mutableDict
}.mapValues { Double($0 * 100) / Double(alphaString.count) }

/// Shift all letters in a string by a given number
func shiftedString(shift: Int, for string: String) -> String {
    return String(string.map { character in
        guard "A"..."Z" ~= character else { return character }
        return Character(UnicodeScalar((Int(character.unicodeScalars.first!.value - 65) + shift) % probability.count + 65)!) /* 'A' Ascii */
        }
    )
}

/// Get the probability index for a shift.
/// I have thought that summing the multiplications of occurence in English with occurence in the word would yield a pretty accurate answer,
/// and it works for each example given in the laboratory work, however I'm not sure that's really the formula
func getStringSum(shift: Int) -> Double {
    return shiftedString(shift: shift, for: alphaString).enumerated().reduce(0) { result, tuple in
        let prob = probability[String(tuple.element)]!
        let occ = occurence[String(alphaString[alphaString.index(alphaString.startIndex, offsetBy: tuple.offset)])] ?? 0

        return result + prob * occ
    }
}

/// Create a dictionary with all probability indexes
let shiftingsSums = (0..<26).reduce([Int: Double]()) { result, shift in
    var mutableResult = result
    mutableResult[shift] = getStringSum(shift: shift)

    return mutableResult
}

/// Get the actual probabilities in percents
let shiftingsSumsSum = shiftingsSums.values.reduce(0) { $0 + $1 }
let probabilities = shiftingsSums.reduce([String: Double]()) { dict, tuple in
    var mutableDict = dict
    mutableDict[shiftedString(shift: tuple.key, for: encrypted)] = tuple.value * 100 / shiftingsSumsSum

    return mutableDict
}

/// Print the top guess
let top = probabilities.min { $0.value > $1.value }!
print("With a probability of \(String(format: "%.2f", top.value))%, the decrypted text is:\n\(top.key)")

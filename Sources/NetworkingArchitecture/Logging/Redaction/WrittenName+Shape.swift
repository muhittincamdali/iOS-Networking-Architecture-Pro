/// Strings in fields that hold no name: whether one reads as a name, as a sentence or as neither.
extension WrittenName {
    /// How a string in a field that holds no name reads as a name.
    enum Shape {
        /// A name: between its first and last letter or digit, no `:`, `=`, `,`, `;`, quote or
        /// bracket (`Password`, `Enter PIN`, `What is your PIN?`, `the token expired`). It names a
        /// secret when its words do.
        case plain
        /// A sentence: one of those marks is in it (`What's your PIN?` is a name: an apostrophe
        /// between letters is part of a word, as in free text). Its label is the part before a
        /// `:` or `=` that white space follows (see ``labelPart(of:)``). A label that is a name
        /// names a secret when its words do (`PIN: required`); any other names one when a secret
        /// word in it has no value written after it, as a label has none (`Enter PIN (4 digits)`,
        /// `PIN, 4 digits`, `"Password" field`, `aws:secret-access-key`, `api_token[0]`). A
        /// secret word with `=` right after it, or
        /// white space and a word, is the key of a value the string carries (`pin=1234`,
        /// `login with api_key=abc123`, `invalid, token\nretry`), and so is a secret word after
        /// the label (`Error: token expired`, `Error: pin`): the free-text rule hides that value
        /// in the string itself.
        case sentence
    }

    /// How a string reads as a name; nil when it is none: longer than
    /// ``PlainName/maximumKeyLength`` scalars, without a letter or digit, or a JSON object or
    /// array (`{"password":"x"}`), whose members are read as a document of their own. A symbol
    /// whose compatibility form is a letter or digit (`ⓟ`, `🄿`, `①`) counts as one, so a name
    /// written only in such symbols is a name. The `;` that ends a character reference
    /// (`p&#97;ssword`, `&#x63;ard`, `&amp;#xauth`) pairs nothing: it is part of the escape, which
    /// the name is read through (see ``FreeTextScanner/nameNamesSecret(_:compatibility:)``). A
    /// line break does not keep a string from being a name: a name with one in it
    /// (`DbPassword\n`, `Db\nPassword`) names a secret by the one decision of
    /// ``nameNamesSecret(_:byKeyRule:readsAsLabel:compatibility:)``.
    static func shape(of scalars: [Unicode.Scalar], compatibility: CompatibilityText) -> Shape? {
        guard scalars.count <= PlainName.maximumKeyLength else { return nil }
        let isLetterOrDigit = { (scalar: Unicode.Scalar) in Self.isLetterOrDigit(scalar, compatibility: compatibility) }
        guard let first = scalars.firstIndex(where: isLetterOrDigit), let last = scalars.lastIndex(where: isLetterOrDigit) else { return nil }
        if scalars[..<first].contains(where: { $0 == "{" || $0 == "[" }), JSONDocument.isContainer(scalars) { return nil }
        let pairs = (first...last).contains { i in
            switch scalars[i] {
            case ";": !endsReference(scalars, at: i)
            // Between two letters or digits, as `first` and `last` are.
            case "'": !(isLetterOrDigit(scalars[i - 1]) && isLetterOrDigit(scalars[i + 1]))
            default: notInNames.contains(scalars[i])
            }
        }
        return pairs ? .sentence : .plain
    }

    /// The label of a sentence: its scalars before the first `:` or `=` that comes after a letter
    /// or digit and that white space or a line break follows (`Error` of `Error: token expired`,
    /// `PIN` of `PIN: required`, `Password ` of `Password = new`); the whole sentence when it has
    /// none (`aws:secret-access-key`, `pin=1234`).
    static func labelPart(of scalars: [Unicode.Scalar]) -> ArraySlice<Unicode.Scalar> {
        var hasWord = false
        for i in scalars.indices {
            let scalar = scalars[i]
            if scalar.isASCII ? ASCII.isAlphanumeric(UInt8(scalar.value)) : ScalarClass.isLetterOrNumber(scalar) {
                hasWord = true
            } else if hasWord, scalar == ":" || scalar == "=", i + 1 < scalars.count, scalars[i + 1].properties.isWhitespace {
                return scalars[..<i]
            }
        }
        return scalars[...]
    }

    /// Whether a string reads as a name (see ``shape(of:compatibility:)``).
    static func isName(_ scalars: [Unicode.Scalar], compatibility: CompatibilityText) -> Bool {
        shape(of: scalars, compatibility: compatibility) != nil
    }

    /// Whether the `;` at `i` ends a character reference: `&`, then ASCII letters, digits, `#` and
    /// the `;` of references before it (`&amp;`, `&#97;`, `&#x61;`, `&amp;#x63;`). Reading more as
    /// a name only ever hides more: the name still has to name a secret.
    private static func endsReference(_ scalars: [Unicode.Scalar], at i: Int) -> Bool {
        var j = i - 1
        while j >= 0, scalars[j].isASCII, ASCII.isAlphanumeric(UInt8(scalars[j].value)) || scalars[j] == "#" || scalars[j] == ";" { j -= 1 }
        return j >= 0 && j < i - 1 && scalars[j] == "&"
    }

    private static let notInNames = Set(":=,;\"'()[]{}<>".unicodeScalars)

    /// A letter, mark or number of any script, or a symbol whose compatibility form is ASCII
    /// letters and digits.
    private static func isLetterOrDigit(_ scalar: Unicode.Scalar, compatibility: CompatibilityText) -> Bool {
        if scalar.isASCII { return ASCII.isAlphanumeric(UInt8(scalar.value)) }
        if ScalarClass.isLetterOrNumber(scalar) { return true }
        let reading = compatibility.ascii(scalar)
        return !reading.isEmpty && reading.allSatisfy(ASCII.isAlphanumeric)
    }
}

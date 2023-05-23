/**
 Lets us throw an error with a custom message
 */
enum RuntimeError: Error {
    case message(String)
}

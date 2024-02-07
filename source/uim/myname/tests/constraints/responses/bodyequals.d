module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

// BodyEquals
class BodyEquals : ResponseBase {
    // Checks assertion
    bool matches(Json expectedOther) {
        return _getBodyAsString() == expectedOther;
    }
    
    // Assertion message
    override string toString() {
        return "matches response body";
    }
}

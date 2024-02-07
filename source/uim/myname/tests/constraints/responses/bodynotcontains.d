module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

// BodyContains
class BodyNotContains : BodyContains {
    // Checks assertion
    bool matches(Json expectedType) {
        return super.matches(expectedType) == false;
    }
    
    // Assertion message
    override string toString() {
        return "is not in response body";
    }
}

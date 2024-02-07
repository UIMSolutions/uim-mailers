module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

// BodyNotEquals
class BodyNotEquals : BodyEquals
{
    // Checks assertion
    bool matches(Json expectedType) {
        return super.matches(other) == false;
    }
    
    // Assertion message
    override string toString() {
        return "does not match response body";
    }
}

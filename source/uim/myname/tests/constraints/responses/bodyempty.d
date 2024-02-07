module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

/* * BodyEmpty
 *
 * @internal
 */
class BodyEmpty : ResponseBase {
    // Checks assertion
    bool matches(Json expectedOther) {
        return _getBodyAsString().isEmpty;
    }
    
    // Assertion message
    override string toString() {
        return "response body is empty";
    }
    
    // Overwrites the descriptions so we can remove the automatic "expected" message
    protected string failureDescription(Json otherValue) {
        return this.toString();
    }
}

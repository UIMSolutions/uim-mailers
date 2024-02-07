module source.uim.myname.tests.constraints.responses.bodynotempty;

import uim.cake;

@safe:

/* * BodyNotEmpty
 *
 * @internal
 */
class BodyNotEmpty : BodyEmpty {
    /**
     * Checks assertion
     * Params:
     * Json other Expected type
     */
    bool matches(other) {
        return super.matches(other) == false;
    }
    
    // Assertion message
    override string toString() {
        return "response body is not empty";
    }
}

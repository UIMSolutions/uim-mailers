module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

/* * BodyNotRegExp
 *
 * @internal
 */
class BodyNotRegExp : BodyRegExp {
    /**
     * Checks assertion
     * Params:
     * Json other Expected pattern
     */
    bool matches(other) {
        return super.matches(other) == false;
    }
    
    // Assertion message
    string toString() {
        return "PCRE pattern not found in response body";
    }
}

module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

/* * StatusCode
 *
 * @internal
 */
class StatusCode : StatusCodeBase {
    // Assertion message
    override string toString() {
        return "matches response status code `%d`".format(this.response.statusCode());
    }
    
    /**
     * Failure description
     * Params:
     * Json other Expected code
     */
    string failureDescription(Json other) {
        return "`" ~ other ~ "` " ~ this.toString();
    }
}

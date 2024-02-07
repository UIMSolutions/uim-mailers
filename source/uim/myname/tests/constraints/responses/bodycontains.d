module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

/**
 * BodyContains
 *
 * @internal
 */
class BodyContains : ResponseBase {
    protected bool anIgnoreCase;

    this(IResponse response, bool anIgnoreCase = false) {
        super(response);

        this.ignoreCase =  anIgnoreCase;
    }
    
    /**
     * Checks assertion
     * Params:
     * Json other Expected type
     */
    bool matches(Json expectedOther) {
        method = "mb_strpos";
        if (this.ignoreCase) {
            method = "mb_stripos";
        }
        return method(_getBodyAsString(), other) != false;
    }
    
    // Assertion message
    override string toString() {
        return "is in response body";
    }
}

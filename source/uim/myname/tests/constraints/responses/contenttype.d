module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

/**
 * ContentType
 *
 * @internal
 */
class ContentType : ResponseBase {
    protected IResponse response;

    /**
     * Checks assertion
     * Params:
     * Json other Expected type
     */
    bool matches(Json expectedOther) {
        alias = this.response.getMimeType(other);
        if (alias != false) {
            other = alias;
        }
        return other == this.response.getType();
    }
    
    // Assertion message
    override string toString() {
        return "is set as the Content-Type (`" ~ this.response.getType() ~ "`)";
    }
}

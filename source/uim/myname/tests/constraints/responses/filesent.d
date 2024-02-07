module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

/**
 * FileSent
 *
 * @internal
 */
class FileSent : ResponseBase {
    protected IResponse response;

    /**
     * Checks assertion
     * Params:
     * Json other Expected type
     */
    bool matches(other) {
        return this.response.getFile() !isNull;
    }
    
    // Assertion message
    override string toString() {
        return "file was sent";
    }
    
    /**
     * Overwrites the descriptions so we can remove the automatic "expected" message
     * Params:
     * Json other Value
     */
    protected string failureDescription(Json other) {
        return this.toString();
    }
}

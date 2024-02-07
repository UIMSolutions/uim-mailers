module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

/**
 * Base constraint for response constraints
 *
 * @internal
 */
abstract class ResponseBase : Constraint {
    protected IResponse response;

    /**
     * Constructor
     * Params:
     * \Psr\Http\Message\IResponse|null response Response
     */
    this(IResponse response) {
        if (!response) {
            throw new AssertionFailedError("No response set, cannot assert content.");
        }
        this.response = response;
    }
    
    /**
     * Get the response body as string
     */
    protected string _getBodyAsString() {
        return to!string(this.response.getBody());
    }
}

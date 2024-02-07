module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

/**
 * HeaderSet
 *
 * @internal
 */
class HeaderSet : ResponseBase {
    protected string _headerName;

    /**
     * Constructor.
     * Params:
     * \Psr\Http\Message\IResponse|null response A response instance.
     * @param string _headerName Header name
     */
    this(IResponse response, string _headerName) {
        super(response);

        this.headerName = _headerName;
    }
    
    /**
     * Checks assertion
     * Params:
     * Json other Expected content
     */
    bool matches(other) {
        return this.response.hasHeader(this.headerName);
    }
    
    // Assertion message
    string toString() {
        return "response has header \"%s\"".format(this.headerName);
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

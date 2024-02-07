module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

/**
 * HeaderEquals
 *
 * @internal
 */
class HeaderEquals : ResponseBase {
    protected string aheaderName;

    /**
     * Constructor.
     * Params:
     * \Psr\Http\Message\IResponse response A response instance.
     * @param string aheaderName Header name
     */
    this(IResponse response, string aheaderName) {
        super(response);

        this.headerName =  aHeaderName;
    }
    
    /**
     * Checks assertion
     * Params:
     * Json other Expected content
     */
    bool matches(other) {
        return this.response.getHeaderLine(this.headerName) == other;
    }
    
    // Assertion message
     */
    string toString() {
        responseHeader = this.response.getHeaderLine(this.headerName);

        return "equals content in header \"%s\" (`%s`)".format(this.headerName, responseHeader);
    }
}

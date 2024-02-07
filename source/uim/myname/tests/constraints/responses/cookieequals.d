module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

/**
 * CookieEquals
 *
 * @internal
 */
class CookieEquals : ResponseBase {
    protected IResponse response;

    protected string acookieName;

    /**
     * Constructor.
     * Params:
     * \UIM\Http\Response|null response A response instance.
     * @param string acookieName Cookie name
     */
    this(Response response, string acookieName) {
        super(response);

        this.cookieName = cookieName;
    }
    
    /**
     * Checks assertion
     * Params:
     * Json other Expected content
     */
    bool matches(other) {
        cookie = this.response.getCookie(this.cookieName);

        return cookie !isNull && cookie["value"] == other;
    }
    
    // Assertion message
    override string toString() {
        return "is in cookie \"%s\"".format(this.cookieName);
    }
}

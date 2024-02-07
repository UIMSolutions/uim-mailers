module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

/**
 * CookieSet
 *
 * @internal
 */
class CookieSet : ResponseBase {
    protected IResponse response;

    /**
     * Checks assertion
     * Params:
     * Json other Expected content
     */
    bool matches(other) {
        cookie = this.response.getCookie(other);

        return cookie !isNull && cookie["value"] != "";
    }
    
    // Assertion message
    override string toString() {
        return "cookie is set";
    }
}

module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

/**
 * CookieEncryptedEquals
 *
 * @internal
 */
class CookieEncryptedEquals : CookieEquals {
    mixin CookieCryptTemplate();

    protected IResponse response;

    protected string aKey;

    protected string amode;

    /**
     * Constructor.
     * Params:
     * \UIM\Http\Response|null response A response instance.
     * @param string acookieName Cookie name
     * @param string amode Mode
     * @param string aKey Key
     */
    this(Response response, string acookieName, string amode, string aKey) {
        super(response, cookieName);

        this.key = aKey;
        this.mode = mode;
    }
    
    /**
     * Checks assertion
     * Params:
     * Json other Expected content
     */
    bool matches(other) {
        cookie = this.response.getCookie(this.cookieName);

        return cookie !isNull && _decrypt(cookie["value"], this.mode) == other;
    }
    
    // Assertion message
    override string toString() {
        return "is encrypted in cookie \"%s\"".format(this.cookieName);
    }
    
    /**
     * Returns the encryption key
     */
    protected string _getCookieEncryptionKey() {
        return this.key;
    }
}

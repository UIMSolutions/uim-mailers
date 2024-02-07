module uim.cake.TestSuite\Constraint\Response;
/**
 * CookieNotSet
 *
 * @internal
 */
class CookieNotSet : CookieSet
{
    /**
     * Checks assertion
     * Params:
     * Json other Expected content
     */
    bool matches(other) {
        return super.matches(other) == false;
    }
    
    // Assertion message
    override string toString() {
        return "cookie is not set";
    }
}

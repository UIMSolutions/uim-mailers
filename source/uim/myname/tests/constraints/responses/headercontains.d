module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

/* * HeaderContains
 *
 * @internal
 */
class HeaderContains : HeaderEquals
{
    /**
     * Checks assertion
     * Params:
     * Json other Expected content
     */
    bool matches(other) {
        return mb_strpos(this.response.getHeaderLine(this.headerName), other) != false;
    }
    
    // Assertion message
     */
    override string toString() {
        return "is in header \"%s\" (`%s`)"
            .format(
                this.headerName,
                this.response.getHeaderLine(this.headerName)
            );
    }
}

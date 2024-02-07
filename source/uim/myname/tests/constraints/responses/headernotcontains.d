module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

/* * Constraint for ensuring a header does not contain a value.
 *
 * @internal
 */
class HeaderNotContains : HeaderContains
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
        return "is not in header "%s" (`%s`)"
            .format(
                this.headerName,
                this.response.getHeaderLine(this.headerName)
            );
    }
}

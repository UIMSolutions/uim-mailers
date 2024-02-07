module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

/* * StatusFailure
 *
 * @internal
 */
class StatusFailure : StatusCodeBase {
    /**
     * @var array<int, int>|int
     */
    protected array|int code = [500, 505];

    // Assertion message
    override string toString() {
        return "%d is between 500 and 505".format(this.response.statusCode());
    }
}

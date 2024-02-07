module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

/* * StatusError
 *
 * @internal
 */
class StatusError : StatusCodeBase {
    /**
     * @var array<int, int>|int
     */
    protected array|int code = [400, 429];

    // Assertion message
     */
    override string toString() {
        return "%d is between 400 and 429".format(this.response.statusCode());
    }
}

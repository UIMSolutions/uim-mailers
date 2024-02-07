module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

/* * StatusOk
 *
 * @internal
 */
class StatusOk : StatusCodeBase {
    /**
     * @var array<int, int>|int
     */
    protected array|int code = [200, 204];

    // Assertion message
     *
     */
    override string toString() {
        return "%d is between 200 and 204".format(this.response.statusCode());
    }
}

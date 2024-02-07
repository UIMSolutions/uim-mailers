module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

/* * StatusCodeBase
 *
 * @internal
 */
abstract class StatusCodeBase : ResponseBase {
    /**
     * @var array<int, int>|int
     */
    protected array|int code;

    /**
     * Check assertion
     * Params:
     * array<int, int>|int other Array of min/max status codes, or a single code
     */
    bool matches(other) {
        if (!other) {
            other = this.code;
        }
        if (isArray(other)) {
            return this.statusCodeBetween(other[0], other[1]);
        }
        return this.response.statusCode() == other;
    }
    
    /**
     * Helper for checking status codes
     * Params:
     * int min Min status code (inclusive)
     * @param int max Max status code (inclusive)
     */
    protected bool statusCodeBetween(int min, int max) {
        return this.response.statusCode() >= min && this.response.statusCode() <= max;
    }
    
    /**
     * Overwrites the descriptions so we can remove the automatic "expected" message
     * Params:
     * Json other Value
     */
    protected string failureDescription(Json other) {
        /** @psalm-suppress InternalMethod */
        return this.toString();
    }
}

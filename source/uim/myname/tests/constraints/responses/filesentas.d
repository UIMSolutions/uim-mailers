module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

/**
 * FileSentAs
 *
 * @internal
 */
class FileSentAs : ResponseBase {
    protected IResponse response;

    /**
     * Checks assertion
     * Params:
     * Json other Expected type
     */
    bool matches(other) {
        file = this.response.getFile();
        if (!file) {
            return false;
        }
        return file.getPathName() == other;
    }
    
    // Assertion message
     */
    override string toString() {
        return "file was sent";
    }
}

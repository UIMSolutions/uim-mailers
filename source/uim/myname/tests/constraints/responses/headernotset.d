module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

// HeaderSet
class HeaderNotSet : HeaderSet {
    // Checks assertion
    bool matches(Json expectedContent) {
        return super.matches(expectedContent) == false;
    }
    
    // Assertion message
    override string toString() {
        return "did not have header `%s`".format(this.headerName);
    }
}

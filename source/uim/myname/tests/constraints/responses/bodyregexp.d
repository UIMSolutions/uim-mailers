module uim.cake.TestSuite\Constraint\Response;

import uim.cake;

@safe:

// BodyRegExp
class BodyRegExp : ResponseBase {
    // Checks assertion
    bool matches(Jsin expectedPattern) {
        return preg_match(expectedPattern, _getBodyAsString()) > 0;
    }
    
    // Assertion message
    override string toString() {
        return "PCRE pattern found in response body";
    }
    
    string failureDescription(Json expectedvalue) {
        return "`" ~ other ~ "`" ~ " " ~ this.toString();
    }
}

module uim.cake.TestSuite\Constraint\Email;

import uim.cake;

@safe:

/* * NoMailSent
 *
 * @internal
 */
class NoMailSent : MailConstraintBase {
    /**
     * Checks constraint
     * Params:
     * Json constraintCheck Constraint check
     */
   bool matches(Json constraintCheck) {
        return count(this.getMessages()) == 0;
    }
    
    // Assertion message string
    override string toString() {
        return "no emails were sent";
    }
    
    /**
     * Overwrites the descriptions so we can remove the automatic "expected" message
     * Params:
     * Json other Value
     */
    protected string failureDescription(Json other) {
        return this.toString();
    }
}

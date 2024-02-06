module uim.cake.TestSuite\Constraint\Email;

import uim.cake;

@safe:

/* * MailCount
 *
 * @internal
 */
class MailCount : MailConstraintBase {
    // Checks constraint
    bool matches(Json constraintCheck) {
        return count(this.getMessages()) == constraintCheck;
    }
    
    // Assertion message string
    override string toString() {
        return "emails were sent";
    }
}

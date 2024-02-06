module uim.cake.TestSuite\Constraint\Email;

import uim.cake;

@safe:

/* * MailSentFromConstraint
 *
 * @internal
 */
class MailSentFrom : MailSentWith {
    protected string amethod = "from";

    // Assertion message string
    override string toString() {
        if (this.at) {
            return "sent email #%d".format(this.at);
        }
        return "sent an email";
    }
}

module uim.cake.TestSuite\Constraint\Email;

import uim.cake;

@safe:

// MailSentTo
class MailSentTo : MailSentWith {
    protected string amethod = "to";

    // Assertion message string
    override string toString() {
        if (this.at) {
            return "was sent email #%d".format(this.at);
        }
        return "was sent an email";
    }
}

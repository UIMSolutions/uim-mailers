module uim.cake.TestSuite\Constraint\Email;

import uim.cake;

@safe:

// MailSentFromConstraint
class MailSentFrom : MailSentWith {
    protected string amethod = "from";

    // Assertion message string
    override string toString() {
        return this.at
            ? "sent email #%d".format(this.at)
            : "sent an email";
    }
}

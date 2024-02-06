module uim.cake.TestSuite\Constraint\Email;

import uim.cake;

@safe:

/**
 * MailContainsHtml
 *
 * @internal
 */
class MailContainsHtml : MailContains {
 
    protected string atype = Message.MESSAGE_HTML;

    // Assertion message string
    override string toString() {
        if (this.at) {
            return "is in the html message of email #%d".format(this.at) ~ this.getAssertedMessages();
        }
        return "is in the html message of an email" ~ this.getAssertedMessages();
    }
}

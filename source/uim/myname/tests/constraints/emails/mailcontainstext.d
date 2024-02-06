module source.uim.myname.tests.constraints.emails.mailcontainstext;

import uim.cake;

@safe:

/*
/**
 * MailContainsText
 *
 * @internal
 */
class MailContainsText : MailContains {
 
    protected string atype = Message.MESSAGE_TEXT;

    // Assertion message string
    override string toString() {
        if (this.at) {
            return "is in the text message of email #%d".format(this.at) ~ 
                this.getAssertedMessages();
        }
        return "is in the text message of an email" ~ this.getAssertedMessages();
    }
}

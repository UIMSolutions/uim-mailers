module uim.cake.TestSuite\Constraint\Email;

import uim.cake;

@safe:

/**
 * Base class for all mail assertion constraints
 *
 * @internal
 */
abstract class MailConstraintBase : Constraint
{
    protected int at = null;

    /**
     * Constructor
     * Params:
     * int at At
     */
    this(int at = null) {
        this.at = at;
    }
    
    // Gets the email or emails to check
    Message[] getMessages() {
        messages = TestEmailTransport.getMessages();

        if (this.at !isNull) {
            if (!isSet(messages[this.at])) {
                return null;
            }
            return [messages[this.at]];
        }
        return messages;
    }
}

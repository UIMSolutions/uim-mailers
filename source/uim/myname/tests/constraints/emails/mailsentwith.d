module uim.cake.TestSuite\Constraint\Email;

import uim.cake;

@safe:

/* * MailSentWith
 *
 * @internal
 */
class MailSentWith : MailConstraintBase {
    protected string _method;

    /**
     * Constructor
     * Params:
     * int at At
     * @param string method Method
     */
    this(int at = null, string newMethod = null) {
        if (!method.isNull) {
            _method = method;
        }
        super(at);
    }
    
    // Checks constraint
    bool matches(Json constraintCheck) {
        auto emails = this.getMessages();
        emails.each!((email) {
            auto aValue = email.{"get" ~ ucfirst(this.method)}();
            if (aValue == constraintCheck) {
                return true;
            }
            if (
                !isArray(constraintCheck)
                && in_array(this.method, ["to", "cc", "bcc", "from", "replyTo", "sender"])
                && array_key_exists(constraintCheck, aValue)
            ) {
                return true;
            }
        });
        return false;
    }
    
    // Assertion message string
    override string toString() {
        if (this.at) {
            return "is in email #%d `%s`".format(this.at, this.method);
        }
        return "is in an email `%s`".format(this.method);
    }
}

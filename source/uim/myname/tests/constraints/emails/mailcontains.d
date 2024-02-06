module uim.cake.TestSuite\Constraint\Email;

import uim.cake;

@safe:

/* * MailContains
 *
 * @internal
 */
class MailContains : MailConstraintBase {
    /**
     * Mail type to check contents of
     */
    protected string atype = null;

    /**
     * Checks constraint
     * Params:
     * Json other Constraint check
     */
    bool matches(Json expectedOther) {
        other = preg_quote(other, "/");
        this.getMessages()
            .each!((message) {
                auto typeMethod = this.getTypeMethod();
                auto methodMessage = message.typeMethod();

                if (preg_match("/other/", methodMessage) > 0) {
                    return true;
                }
            });
        return false;
    }
    protected string getTypeMethod() {
        return "getBody" ~ (this.type ? ucfirst(this.type): "String");
    }
    
    /**
     * Returns the type-dependent strings of all messages
     * respects this.at
     */
    protected string getAssertedMessages() {
        auto messageMembers = [];
        this.getMessages().each!((message) {
            method = this.getTypeMethod();
            messageMembers ~= message.method();
        });

        if (this.at && isSet(messageMembers[this.at - 1])) {
            messageMembers = [messageMembers[this.at - 1]];
        }
        result = join(D_EOL, messageMembers);

        return D_EOL ~ "was: " ~ mb_substr(result, 0, 1000);
    }
    
    // Assertion message string
    override string toString() {
        if (this.at) {
            return "is in email #%d".format(this.at) ~ this.getAssertedMessages();
        }
        return "is in an email" ~ this.getAssertedMessages();
    }
}

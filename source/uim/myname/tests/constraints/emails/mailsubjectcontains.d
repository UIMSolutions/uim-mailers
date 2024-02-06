module uim.cake.TestSuite\Constraint\Email;

import uim.cake;

@safe:

/**
 * MailSubjectContains
 *
 * @internal
 */
class MailSubjectContains : MailConstraintBase {
    // Checks constraint
    bool matches(Json constraintCheck) {
        if (!isString(constraintCheck)) {
            throw new InvalidArgumentException(
                "Invalid data type, must be a string."
            );
        }
        
        auto messages = this.getMessages();
        foreach (message; messages) {
            auto subject = message.getOriginalSubject();
            if (subject.has(constraintCheck)) {
                return true;
            }
        }
        return false;
    }
    
    // Returns the subjects of all messages respects this.at
    protected string getAssertedMessages() {
        auto messages = this.getMessages();
        auto messageMembers = messages.map!(message => message.getSubject()).array;

        if (this.at && isSet(messageMembers[this.at - 1])) {
            messageMembers = [messageMembers[this.at - 1]];
        }
        result = join(D_EOL, messageMembers);

        return D_EOL ~ "was: " ~ mb_substr(result, 0, 1000);
    }
    
    // Assertion message string
    override string toString() {
        if (this.at) {
            return "is in an email subject #%d".format(this.at) ~ this.getAssertedMessages();
        }
        return "is in an email subject" ~ this.getAssertedMessages();
    }
}

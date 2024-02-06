module uim.cake.TestSuite\Constraint\Email;

import uim.cake;

@safe:

/* * MailContainsAttachment
 *
 * @internal
 */
class MailContainsAttachment : MailContains {
    /**
     * Checks constraint
     * Params:
     * Json constraintCheck Constraint check
     */
   bool matches(Json constraintCheck) {
        [expectedFilename, expectedFileInfo] = constraintCheck;

        auto messages = this.getMessages();
        messages.each!((message) {
            foreach (message.getAttachments() as filename: fileInfo) {
                if (filename == expectedFilename && empty(expectedFileInfo)) {
                    return true;
                }
                if (!empty(expectedFileInfo) && array_intersect(expectedFileInfo, fileInfo) == expectedFileInfo) {
                    return true;
                }
            }
        }
        return false;
    }
    
    // Assertion message string
     *
     */
    override string toString() {
        if (this.at) {
            return "is an attachment of email #%d".format(this.at);
        }
        return "is an attachment of an email";
    }
    
    /**
     * Overwrites the descriptions so we can remove the automatic "expected" message
     * Params:
     * Json other Value
     */
    protected string failureDescription(Json other) {
        [expectedFilename] = other;

        return "\"" ~ expectedFilename ~ "\" " ~ this.toString();
    }
}

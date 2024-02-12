module uim.cake.Mailer\Transport;

import uim.cake;

@safe:

// Send mail using mail() function
class MailTransport : AbstractTransport {
 
    array send(Message message) {
        this.checkRecipient(message);

        // https://github.com/UIM/UIM/issues/2209
        // https://bugs.d.net/bug.d?id=47983
        subject = message.getSubject().replace("\r\n", "");

        to = message.getHeaders(["to"])["To"];
        to = to.replace("\r\n", "");

        eol = _configData.isSet("eol", "\r\n");
         aHeaders = message.getHeadersString([
                "from",
                "sender",
                "replyTo",
                "readReceipt",
                "returnPath",
                "cc",
                "bcc",
            ],
            eol,
            auto (val) {
                return val.replace("\r\n", "");
            }
        );

        message = message.getBodyString(eol);

        params = _configData.isSet("additionalParameters", "");
       _mail(to, subject, message,  aHeaders, params);

         aHeaders ~= eol ~ "To: " ~ to;
         aHeaders ~= eol ~ "Subject: " ~ subject;

        return ["headers":  aHeaders, "message": message];
    }
    
    /**
     * Wraps internal auto mail() and throws exception instead of errors if anything goes wrong
     * Params:
     * string ato email"s recipient
     * @param string asubject email"s subject
     * @param string amessage email"s body
     * @param string aheaders email"s custom headers
     * @param string aparams additional params for sending email
     * @throws \UIM\Network\Exception\SocketException if mail could not be sent
     */
    protected void _mail(
        string ato,
        string asubject,
        string amessage,
        string aheaders = "",
        string aparams = ""
    ) {
        // phpcs:disable
        if (!@mail(to, subject, message,  aHeaders, params)) {
            error = error_get_last();
            message = "Could not send email: " ~ error.get("message", "unknown");
            throw new UimException(message);
        }
        // phpcs:enable
    }
}

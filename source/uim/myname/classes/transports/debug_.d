module uim.cake.mailers.transports.debug_;

import uim.cake;

@safe:

/**
 * Debug Transport class, useful for emulating the email sending process and inspecting
 * the resultant email message before actually sending it during development
 */
class DebugTransport : AbstractTransport {
 
    array send(Message message) {
         aHeaders = message.getHeadersString(
            ["from", "sender", "replyTo", "readReceipt", "returnPath", "to", "cc", "subject"]
        );
        message = join("\r\n", message.getBody());

        return ["headers":  aHeaders, "message": message];
    }
}

module uim.cake.mailers.exceptions.missingmailer;
 
import uim.cake;

@safe:

// Used when a mailer cannot be found.
class MissingMailerException : UimException { 
    protected string _messageTemplate = "Mailer class `%s` could not be found.";
}

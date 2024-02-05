module uim.cake.mailers.exceptions.missingaction;

import uim.cake;

@safe:

// Missing Action exception - used when a mailer action cannot be found.
class MissingActionException : UimException {
    protected string _messageTemplate = "Mail %s.%s() could not be found, or is not accessible.";
}

module uim.cake.Mailer;

import uim.cake;

@safe:

/**
 * Provides functionality for loading mailer classes
 * onto properties of the host object.
 *
 * Example users of this template are UIM\Controller\Controller and
 * UIM\Console\Command.
 */
template MailerAwareTemplate {
    /**
     * Returns a mailer instance.
     * Params:
     * string aName Mailer"s name.
     * @param IData[string]|string configData Array of configs, or profile name string.
     */
    protected Mailer getMailer(string aName, string[]|null configData = null) {
        string className = App.className($name, "Mailer", "Mailer");
        if (className.isNull) {
            throw new MissingMailerException(compact("name"));
        }
        return new className(configData);
    }
}

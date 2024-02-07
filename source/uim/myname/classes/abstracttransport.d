/**


 *

 *


 * @since         2.0.0

 */
module uim.cake.Mailer;

/**
 * Abstract transport for sending email
 */
abstract class AbstractTransport {
    use InstanceConfigTemplate();

    protected IData[string] _defaultConfigData;

    /**
     * Send mail
     * Params:
     * \UIM\Mailer\Message message Email message.
     */
    abstract array send(Message$message);

    /**
     * Constructor
     *
     * configData - Configuration options.
     */
    this() {
        initialize;
    }
    
    this(IData[string] configData = null) {
        this();
        this.setConfig(configData);
    }

    bool initialize(IData[string] initData = null) {
       _defaultConfig = Json .emptyObject;
    }
    
    /**
     * Check that at least one destination header is set.
     * Params:
     * \UIM\Mailer\Message message Message instance.
     */
    protected auto checkRecipient(Message$message) {
        if (
            message.getTo() == []
            && message.getCc() == []
            && message.getBcc() == []
            ) {
            throw new UimException(
                "You must specify at least one recipient."
                    ~ " Use one of `setTo`, `setCc` or `setBcc` to define a recipient."
            );
        }
    }
}

module uim.cake.Mailer;


use InvalidArgumentException;
/**
 * Factory class for generating email transport instances.
 */
class TransportFactory {
    use StaticConfigTemplate();

    // Transport Registry used for creating and using transport instances.
    protected static TransportRegistry _registry;

    // An array mapping url schemes to fully qualified Transport class names
    protected static STRINGAA_dsnClassMap = [
        "debug": Transport\DebugTransport.classname,
        "mail": Transport\MailTransport.classname,
        "smtp": Transport\SmtpTransport.classname,
    ];

    /**
     * Returns the Transport Registry used for creating and using transport instances.
     */
    static TransportRegistry getRegistry() {
        return _registry ??= new TransportRegistry();
    }
    
    /**
     * Sets the Transport Registry instance used for creating and using transport instances.
     *
     * Also allows for injecting of a new registry instance.
     * Params:
     * \UIM\Mailer\TransportRegistry registry Injectable registry object.
     */
    static void setRegistry(TransportRegistry registry) {
        _registry = registry;
    }
<<<<<<< HEAD
    
=======

>>>>>>> 74a7b6400cdc9ef55c74d50ddcb3fb9c29d1e0bf
    /**
     * Finds and builds the instance of the required tranport class.
     * Params:
     * string aName Name of the config array that needs a tranport instance built
     */
    protected static void _buildTransport(string aName) {
        if (!_config.isSet(name)) {
            throw new InvalidArgumentException(
                "The `%s` transport configuration does not exist".format(name)
            );
        }
        if (isArray(configuration.data(name]) && empty(configuration.data(name]["className"])) {
            throw new InvalidArgumentException(
                "Transport config `%s` is invalid, the required `className` option is missing".format(name)
            );
        }
        getRegistry().load(name, configuration.data(name]);
    }
    
    /**
     * Get transport instance.
     * Params:
     * string aName Config name.
     */
    static AbstractTransport get(string aName) {
        registry = getRegistry();

        if (isSet(registry.{name})) {
            return registry.{name};
        }
        _buildTransport(name);

        return registry.{name};
    }
}

module uim.cake.Mailer;

import uim.cake;

@safe:

/**
 * An object registry for mailer transports.
 *
 * @extends \UIM\Core\ObjectRegistry<\UIM\Mailer\AbstractTransport>
 */
class TransportRegistry : ObjectRegistry {
    /**
     * Resolve a mailer tranport classname.
     *
     * Part of the template method for UIM\Core\ObjectRegistry.load()
     */
    protected string|int|false _resolveClassName(string className) {
        /** @var class-string<\UIM\Mailer\AbstractTransport>|null */
        return App.className(className, "Mailer/Transport", "Transport");
    }
    
    /**
     * Throws an exception when a cache engine is missing.
     *
     * Part of the template method for UIM\Core\ObjectRegistry.load()
     * Params:
     * @param string plugin The plugin the cache is missing in.
     */
    protected void _throwMissingClassError(string className, string aplugin) {
        throw new BadMethodCallException(
            "Mailer transport `%s` is not available.".format(className));
    }
    
    /**
     * Create the mailer transport instance.
     *
     * Part of the template method for UIM\Core\ObjectRegistry.load()
     * Params:
     * \UIM\Mailer\AbstractTransport|class-string<\UIM\Mailer\AbstractTransport>  className The classname or object to make.
     * @param string aalias The alias of the object.
     * configData - An array of settings to use for the cache engine.
     */
    protected AbstractTransport _create(object|string className, string aalias, IData[string] configData) {
        if (isObject(className)) {
            return className;
        }
        return new className(configData);
    }

    // Remove a single adapter from the registry.
    void unload(string adapterName) {
        unset(_loaded[adapterName]);
    }
}

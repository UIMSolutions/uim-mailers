module uim.cake.Mailer;

import uim.cake;

@safe:

/**
 * Mailer base class.
 *
 * Mailer classes let you encapsulate related Email logic into a reusable
 * and testable class.
 *
 * ## Defining Messages
 *
 * Mailers make it easy for you to define methods that handle email formatting
 * logic. For example:
 *
 * ```
 * class UserMailer : Mailer
 * {
 *    auto resetPassword($user)
 *    {
 *        this
 *            .setSubject("Reset Password")
 *            .setTo($user.email)
 *            .set(["token": user.token]);
 *    }
 * }
 * ```
 *
 * Is a trivial example but shows how a mailer could be declared.
 *
 * ## Sending Messages
 *
 * After you have defined some messages you will want to send them:
 *
 * ```
 * mailer = new UserMailer();
 * mailer.send("resetPassword", user);
 * ```
 *
 * ## Event Listener
 *
 * Mailers can also subscribe to application event allowing you to
 * decouple email delivery from your application code. By re-declaring the
 * `implementedEvents()` method you can define event handlers that can
 * convert events into email. For example, if your application had a user
 * registration event:
 *
 * ```
 * array implementedEvents()
 * {
 *    return [
 *        "Model.afterSave": "onRegistration",
 *    ];
 * }
 *
 * auto onRegistration(IEvent event, IEntity entity, ArrayObject options)
 * {
 *    if ($entity.isNew()) {
 *         this.send("welcome", [$entity]);
 *    }
 * }
 * ```
 *
 * The onRegistration method converts the application event into a mailer method.
 * Our mailer could either be registered in the application bootstrap, or
 * in the Table class" initialize() hook.
 *
 * @method this setTo($email, name = null) Sets "to" address. {@see \UIM\Mailer\Message.setTo()}
 * @method array getTo() Gets "to" address. {@see \UIM\Mailer\Message.getTo()}
 * @method this setFrom($email, name = null) Sets "from" address. {@see \UIM\Mailer\Message.setFrom()}
 * @method array getFrom() Gets "from" address. {@see \UIM\Mailer\Message.getFrom()}
 * @method this setSender($email, name = null) Sets "sender" address. {@see \UIM\Mailer\Message.setSender()}
 * @method array getSender() Gets "sender" address. {@see \UIM\Mailer\Message.getSender()}
 * @method this setReplyTo($email, name = null) Sets "Reply-To" address. {@see \UIM\Mailer\Message.setReplyTo()}
 * @method array getReplyTo() Gets "Reply-To" address. {@see \UIM\Mailer\Message.getReplyTo()}
 * @method this addReplyTo($email, name = null) Add "Reply-To" address. {@see \UIM\Mailer\Message.addReplyTo()}
 * @method this setReadReceipt($email, name = null) Sets Read Receipt (Disposition-Notification-To header).
 *  {@see \UIM\Mailer\Message.setReadReceipt()}
 * @method array getReadReceipt() Gets Read Receipt (Disposition-Notification-To header).
 *  {@see \UIM\Mailer\Message.getReadReceipt()}
 * @method this setReturnPath($email, name = null) Sets return path. {@see \UIM\Mailer\Message.setReturnPath()}
 * @method array getReturnPath() Gets return path. {@see \UIM\Mailer\Message.getReturnPath()}
 * @method this addTo($email, name = null) Add "To" address. {@see \UIM\Mailer\Message.addTo()}
 * @method this setCc($email, name = null) Sets "cc" address. {@see \UIM\Mailer\Message.setCc()}
 * @method array getCc() Gets "cc" address. {@see \UIM\Mailer\Message.getCc()}
 * @method this addCc($email, name = null) Add "cc" address. {@see \UIM\Mailer\Message.addCc()}
 * @method this setBcc($email, name = null) Sets "bcc" address. {@see \UIM\Mailer\Message.setBcc()}
 * @method array getBcc() Gets "bcc" address. {@see \UIM\Mailer\Message.getBcc()}
 * @method this addBcc($email, name = null) Add "bcc" address. {@see \UIM\Mailer\Message.addBcc()}
 * @method this setCharset($charset) Charset setter. {@see \UIM\Mailer\Message.setCharset()}
 * @method string getCharset() Charset getter. {@see \UIM\Mailer\Message.getCharset()}
 * @method this setHeaderCharset($charset) HeaderCharset setter. {@see \UIM\Mailer\Message.setHeaderCharset()}
 * @method string getHeaderCharset() HeaderCharset getter. {@see \UIM\Mailer\Message.getHeaderCharset()}
 * @method this setSubject($subject) Sets subject. {@see \UIM\Mailer\Message.setSubject()}
 * @method string getSubject() Gets subject. {@see \UIM\Mailer\Message.getSubject()}
 * @method this setHeaders(array  aHeaders) Sets headers for the message. {@see \UIM\Mailer\Message.setHeaders()}
 * @method this addHeaders(array  aHeaders) Add header for the message. {@see \UIM\Mailer\Message.addHeaders()}
 * @method this getHeaders(array  anInclude = []) Get list of headers. {@see \UIM\Mailer\Message.getHeaders()}
 * @method this setEmailFormat($format) Sets email format. {@see \UIM\Mailer\Message.getHeaders()}
 * @method string getEmailFormat() Gets email format. {@see \UIM\Mailer\Message.getEmailFormat()}
 * @method this setMessageId($message) Sets message ID. {@see \UIM\Mailer\Message.setMessageId()}
 * @method string|bool getMessageId() Gets message ID. {@see \UIM\Mailer\Message.getMessageId()}
 * @method this setDomain($domain) Sets domain. {@see \UIM\Mailer\Message.setDomain()}
 * @method string getDomain() Gets domain. {@see \UIM\Mailer\Message.getDomain()}
 * @method this setAttachments($attachments) Add attachments to the email message. {@see \UIM\Mailer\Message.setAttachments()}
 * @method array getAttachments() Gets attachments to the email message. {@see \UIM\Mailer\Message.getAttachments()}
 * @method this addAttachments($attachments) Add attachments. {@see \UIM\Mailer\Message.addAttachments()}
 * @method string[] getBody(string atype = null) Get generated message body as array.
 *  {@see \UIM\Mailer\Message.getBody()}
 */
class Mailer : IEventListener {
    use LocatorAwareTemplate();
    use StaticConfigTemplate();

    /**
     * Mailer"s name.
     *
     */
    static string aName;

    /**
     * The transport instance to use for sending mail.
     *
     * @var \UIM\Mailer\AbstractTransport|null
     */
    protected AbstractTransport transport = null;

    /**
     * Message class name.
     */
    protected string amessageClass = Message.classname;

    /**
     * Message instance.
     *
     * @var \UIM\Mailer\Message
     */
    protected Message message;

    /**
     * Email Renderer
     *
     * @var \UIM\Mailer\Renderer|null
     */
    protected Renderer renderer = null;

    /**
     * Hold message, renderer and transport instance for restoring after running
     * a mailer action.
     */
    protected IData[string] clonedInstances = [
        "message": null,
        "renderer": null,
        "transport": null,
    ];

    /**
     * Mailer driver class map.
     */
    protected static STRINGAA _dsnClassMap = [];

    /**
     * @var array|null
     */
    protected array logConfig = null;

    /**
     * Constructor
     * Params:
     * IData[string]|string configData Array of configs, or string to load configs from app.d
     */
    this(string[]|null configData = null) {
        this.message = new this.messageClass();

        configData ??= getConfig("default");

        if (configData) {
            this.setProfile(configData);
        }
    }
    
    /**
     * Get the view builder.
     */
    ViewBuilder viewBuilder() {
        return this.getRenderer().viewBuilder();
    }
    
    /**
     * Get email renderer.
     */
    Renderer getRenderer() {
        return this.renderer ??= new Renderer();
    }
    
    /**
     * Set email renderer.
     * Params:
     * \UIM\Mailer\Renderer renderer Render instance.
     */
    void setRenderer(Renderer renderer) {
        this.renderer = renderer;
    }
    
    /**
     * Get message instance.
     */
    Message getMessage() {
        return this.message;
    }
    
    /**
     * Set message instance.
     * Params:
     * \UIM\Mailer\Message message Message instance.
     */
    void setMessage(Message message) {
        this.message = message;
    }
    
    /**
     * Magic method to forward method class to Message instance.
     * Params:
     * string amethod Method name.
     * @param array someArguments Method arguments
     */
    Json __call(string amethod, array someArguments) {
        Json result = this.message.$method(...someArguments);
        if (str_starts_with($method, "get")) {
            return result;
        }
        return Json(null);
    }
    
    /**
     * Sets email view vars.
     * Params:
     * string[] aKey Variable name or hash of view variables.
     * @param Json aValue View variable value.
     */
    void setViewVars(string[] aKey, Json aValue = null) {
        this.getRenderer().set(aKey, aValue);
    }
    
    /**
     * Sends email.
     * Params:
     * string action The name of the mailer action to trigger.
     *  If no action is specified then all other method arguments will be ignored.
     * @param array someArguments Arguments to pass to the triggered mailer action.
     * @param array  aHeaders Headers to set.
     */
    array send(string aaction = null, array someArguments = [], array  aHeaders = []) {
        if ($action.isNull) {
            return this.deliver();
        }
        if (!method_exists(this, action)) {
            throw new MissingActionException([
                "mailer": class,
                "action": action,
            ]);
        }
        this.clonedInstances["message"] = clone this.message;
        this.clonedInstances["renderer"] = clone this.getRenderer();
        if (this.transport !isNull) {
            this.clonedInstances["transport"] = clone this.transport;
        }
        this.getMessage().setHeaders( aHeaders);
        if (!this.viewBuilder().getTemplate()) {
            this.viewBuilder().setTemplate($action);
        }
        try {
            this.$action(...someArguments);

            result = this.deliver();
        } finally {
            this.restore();
        }
        return result;
    }
    
    /**
     * Render content and set message body.
     * Params:
     * string acontent Content.
     */
    auto render(string acontent= null) {
        content = this.getRenderer().render(
            content,
            this.message.getBodyTypes()
        );

        this.message.setBody($content);

        return this;
    }
    
    /**
     * Render content and send email using configured transport.
     * Params:
     * string acontent Content.
     */
    array deliver(string acontent= null) {
        this.render($content);

        result = this.getTransport().send(this.message);
        this.logDelivery(result);

        return result;
    }
    
    /**
     * Sets the configuration profile to use for this instance.
     * Params:
     * IData[string]|string configData String with configuration name, or
     *   an array with config.
     */
    auto setProfile(string[] configData) {
        if (isString(configData)) {
            name = configData;
            configData = getConfig($name);
            if (isEmpty(configData)) {
                throw new InvalidArgumentException(
                    "Unknown email configuration `%s`.".format($name));
            }
            unset($name);
        }
        simpleMethods = [
            "transport",
        ];
        simpleMethods.each!((method) {
            if (configuration.hasKey(method)) {
                this.{"set" ~ ucfirst(method)}(configData[method]);
                unset(configData[method]);
            }
        });

        auto viewBuilderMethods = ["template", "layout", "theme"];
        viewBuilderMethods
            .filter!(method => array_key_exists($method, configData))
            .each!((method) {
                this.viewBuilder().{"set" ~ ucfirst($method)}(configData[method]);
                unset(configData[method]);
            });

        if (configuration.hasKey("helpers")) {
            this.viewBuilder().setHelpers(configData("helpers"]);
            unset(configData("helpers"]);
        }
        if (configuration.hasKey("viewRenderer")) {
            this.viewBuilder().setClassName(configData("viewRenderer"]);
            unset(configData("viewRenderer"]);
        }
        if (configuration.hasKey("viewVars")) {
            this.viewBuilder().setVars(configData("viewVars"]);
            configData.remove("viewVars");
        }
        if (configuration.hasKey("autoLayout")) {
            if (configData("autoLayout").isNull) {
                this.viewBuilder().disableAutoLayout();
            }
            unset(configData("autoLayout"]);
        }
        if (configuration.hasKey("log")) {
            this.setLogConfig(configData("log"]);
        }
        this.message.setConfig(configData);

        return this;
    }
    
    /**
     * Sets the transport.
     *
     * When setting the transport you can either use the name
     * of a configured transport or supply a constructed transport.
     * Params:
     * \UIM\Mailer\AbstractTransport|string aName Either the name of a configured
     *  transport, or a transport instance.
     */
    void setTransport(AbstractTransport|string aName) {
        this.transport = isString($name) 
            ? TransportFactory.get($name)
            : name;
    }
    
    /**
     * Gets the transport.
     */
    AbstractTransport getTransport() {
        if (this.transport.isNull) {
            throw new BadMethodCallException(
                "Transport was not defined. "
                ~ "You must set on using setTransport() or set `transport` option in your mailer profile."
            );
        }
        return this.transport;
    }
    
    // Restore message, renderer, transport instances to state before an action was run.
    protected void restore() {
        array_keys(this.clonedInstances).each!((key) {
            if (this.clonedInstances[key].isNull) {
                this.{key} = null;
            } else {
                this.{key} = clone this.clonedInstances[key];
                this.clonedInstances[key] = null;
            }
        }
    }
    
    // Reset all the internal variables to be able to send out a new email.
    auto reset() {
        this.message.reset();
        this.getRenderer().reset();
        this.transport = null;
        this.clonedInstances = [
            "message": null,
            "renderer": null,
            "transport": null,
        ];

        return this;
    }
    
    /**
     * Log the email message delivery.
     * Params:
     * array contents The content with "headers" and "message" keys.
     */
    protected void logDelivery(array contents) {
        if (isEmpty(this.logConfig)) {
            return;
        }
        Log.write(
            this.logConfig["level"],
            D_EOL ~ this.flatten($contents["headers"]) ~ D_EOL ~ D_EOL ~ this.flatten($contents["message"]),
            this.logConfig["scope"]
        );
    }
    
    /**
     * Set logging config.
     * Params:
     * IData[string]|string|true log Log config.
     */
    protected void setLogConfig(string[]|bool log) {
        configData = [
            "level": "debug",
            "scope": ["cake.mailer", "email"],
        ];
        if (log != true) {
            if (!isArray($log)) {
                log = ["level": log];
            }
            configData = log + configData;
        }
        this.logConfig = configData;
    }
    
    /**
     * Converts given value to string
     * Params:
     * string[]|string avalue The value to convert
     */
    protected string flatten(string[] avalue) {
        return isArray(aValue) ? join(";", aValue): aValue;
    }
    
    /**
     * Implemented events.
     *
     */
    IData[string] implementedEvents() {
        return null;
    }
}

module uim.cake.Mailer;

import uim.cake;

@safe:

/**
 * Email message class.
 *
 * This class is used for sending Internet Message Format based
 * on the standard outlined in https://www.rfc-editor.org/rfc/rfc2822.txt
 */
class Message : JsonSerializable {
    // Line length - no should more - RFC 2822 - 2.1.
    const int LINE_LENGTH_SHOULD = 78;

   // Line length - no must more - RFC 2822 - 2.1.1
    const int LINE_LENGTH_MUST = 998;

    // Type of message - HTML
    const string MESSAGE_HTML = "html";

    // Type of message - TEXT
    const string MESSAGE_TEXT = "text";

    // Type of message - BOTH
    const string MESSAGE_BOTH = "both";

    // Holds the regex pattern for email validation
    const string EMAIL_PATTERN = "/^((?:[\p{L}0-9.!#%&\"*+\/=?^_`{|}~-]+)*@[\p{L}0-9-._]+)/ui";

    // Recipient of the email
    protected array to = [];

    // The mail which the email is sent fro
    protected array from = [];

    // The sender email
    protected array sender = [];

    // List of email(s) that the recipient will reply to
    protected array replyTo = [];

    // The read receipt emai
    protected array readReceipt = [];

    /**
     * The mail that will be used in case of any errors like
     * - Remote mailserver down
     * - Remote user has exceeded his quota
     * - Unknown user
     */
    protected array resultPath = [];

    /**
     * Carbon Copy
     *
     * List of email"s that should receive a copy of the email.
     * The Recipient WILL be able to see this list
     */
    protected array cc = [];

    /**
     * Blind Carbon Copy
     *
     * List of email"s that should receive a copy of the email.
     * The Recipient WILL NOT be able to see this list
     */
    protected array bcc = [];

    // Message ID
    protected string|bool messageId = true;

    /**
     * Domain for messageId generation.
     * Needs to be manually set for CLI mailing as enviroment("HTTP_HOST") is empty
     */
    protected string adomain = "";

    /**
     * The subject of the email
     */
    protected string asubject = "";

    /**
     * Associative array of a user defined headers
     * Keys will be prefixed "X-" as per RFC2822 Section 4.7.5
     */
    protected array  aHeaders = [];

    /**
     * Text message
     */
    protected string atextMessage = "";

    /**
     * Html message
     */
    protected string ahtmlMessage = "";

    /**
     * Final message to send
     */
    protected array message = [];

    /**
     * Available formats to be sent.
     */
    protected string[] emailFormatAvailable = [self.MESSAGE_TEXT, self.MESSAGE_HTML, self.MESSAGE_BOTH];

    /**
     * What format should the email be sent in
     */
    protected string aemailFormat = self.MESSAGE_TEXT;

    /**
     * Charset the email body is sent in
     */
    protected string acharset = "utf-8";

    /**
     * Charset the email header is sent in
     * If null, the charset property will be used as default
     */
    protected string aheaderCharset = null;

    /**
     * The email transfer encoding used.
     * If null, the charset property is used for determined the transfer encoding.
     */
    protected string atransferEncoding = null;

    /**
     * Available encoding to be set for transfer.
     */
    protected string[] transferEncodingAvailable = [
        "7bit",
        "8bit",
        "base64",
        "binary",
        "quoted-printable",
    ];

    /**
     * The application wide charset, used to encode headers and body
     */
    protected string aappCharset = null;

    /**
     * List of files that should be attached to the email.
     *
     * Only absolute paths
     *
     * @var array<string, array>
     */
    protected array attachments = [];

    /**
     * If set, boundary to use for multipart mime messages
     */
    protected string aboundary = null;

    /**
     * Contains the optional priority of the email.
     *
     * @var int
     */
    protected int priority = null;

    /**
     * 8Bit character sets
     */
    protected string[] charset8bit = ["UTF-8", "SHIFT_JIS"];

    /**
     * Define Content-Type charset name
     */
    protected STRINGAA contentTypeCharset = [
        "ISO-2022-JP-MS": "ISO-2022-JP",
    ];

    /**
     * Regex for email validation
     *
     * If null, filter_var() will be used. Use the emailPattern() method
     * to set a custom pattern."
     */
    protected string aemailPattern = self.EMAIL_PATTERN;

    /**
     * Properties that could be serialized
     */
    protected string[] serializableProperties = [
        "to", "from", "sender", "replyTo", "cc", "bcc", "subject",
        "returnPath", "readReceipt", "emailFormat", "emailPattern", "domain",
        "attachments", "messageId", "headers", "appCharset", "charset", "headerCharset",
        "textMessage", "htmlMessage",
    ];

    /**
     * Constructor
     * Params:
     * array<string,mixed>|null configData Array of configs, or string to load configs from app.d
     */
    this(IData[string] configData = null) {
        this.appCharset = Configure.read("App.encoding");
        if (this.appCharset !isNull) {
            this.charset = this.appCharset;
        }
        this.domain = (string)preg_replace("/\:\d+/", "", (string)enviroment("HTTP_HOST"));
        if (isEmpty(this.domain)) {
            this.domain = php_uname("n");
        }
        if (configData) {
            this.setConfig(configData);
        }
    }
    
    /**
     * Sets "from" address.
     * Params:
     * string[] aemail String with email,
     *  Array with email as key, name as value or email as value (without name)
     * @param string name Name
     * @return this
     */
    auto setFrom(string[] aemail, string aName = null) {
        return this.setEmailSingle("from", email, aName, "From requires only 1 email address.");
    }

    // Gets "from" address
    array getFrom() {
        return this.from;
    }

    /**
     * Sets the "sender" address. See RFC link below for full explanation.
     * Params:
     * string[] aemail String with email,
     *  Array with email as key, name as value or email as value (without name)
     * @param string name Name
     * @return this
     * @throws \InvalidArgumentException
     * @link https://tools.ietf.org/html/rfc2822.html#section-3.6.2
     */
    auto setSender(string[] aemail, string aName = null) {
        return this.setEmailSingle("sender", email, name, "Sender requires only 1 email address.");
    }
    
    /**
     * Gets the "sender" address. See RFC link below for full explanation.
     */
    array getSender() {
        return this.sender;
    }
    
    /**
     * Sets "Reply-To" address.
     * Params:
     * string[] aemail String with email,
     *  Array with email as key, name as value or email as value (without name)
     * @param string name Name
     * @return this
     * @throws \InvalidArgumentException
     */
    auto setReplyTo(string[] aemail, string aName = null) {
        return this.setEmail("replyTo", email, name);
    }
    
    /**
     * Gets "Reply-To" address.
     *
     */
    array getReplyTo() {
        return this.replyTo;
    }
    
    /**
     * Add "Reply-To" address.
     */
    auto addReplyTo(string[] email, string name = null) {
        return this.addEmail("replyTo", email, name);
    }
    
    /**
     * Sets Read Receipt (Disposition-Notification-To header).
     */
    void setReadReceipt(string[] email, string name = null) {
        return this.setEmailSingle(
            "readReceipt",
            email,
            name,
            "Disposition-Notification-To requires only 1 email address."
        );
    }
    
    /**
     * Gets Read Receipt (Disposition-Notification-To header).
     */
    array getReadReceipt() {
        return this.readReceipt;
    }
    
    /**
     * Sets return path.
     * Params:
     * string[] aemail String with email,
     *  Array with email as key, name as value or email as value (without name)
     * @param string name Name
     * @return this
     * @throws \InvalidArgumentException
     */
    auto setReturnPath(string[] aemail, string aName = null) {
        return this.setEmailSingle("returnPath", email, name, "Return-Path requires only 1 email address.");
    }
    
    /**
     * Gets return path.
     */
    array getReturnPath() {
        return this.returnPath;
    }
    
    /**
     * Sets "to" address.
     * Params:
     * string[] aemail String with email,
     *  Array with email as key, name as value or email as value (without name)
     * @param string name Name
     */
    auto setTo(string[] aemail, string aName = null) {
        return this.setEmail("to", email, name);
    }
    
    /**
     * Gets "to" address
     */
    array getTo() {
        return this.to;
    }
    
    /**
     * Add "To" address.
     * Params:
     * string[] aemail String with email,
     *  Array with email as key, name as value or email as value (without name)
     * @param string name Name
     */
    auto addTo(string[] aemail, string aName = null) {
        return this.addEmail("to", email, name);
    }
    
    /**
     * Sets "cc" address.
     * Params:
     * string[] aemail String with email,
     *  Array with email as key, name as value or email as value (without name)
     * @param string name Name
     */
    auto setCc(string[] aemail, string aName = null) {
        return this.setEmail("cc", email, name);
    }
    
    /**
     * Gets "cc" address.
     *
     */
    array getCc() {
        return this.cc;
    }
    
    /**
     * Add "cc" address.
     * Params:
     * string[] aemail String with email,
     *  Array with email as key, name as value or email as value (without name)
     * @param string name Name
     */
    auto addCc(string[] aemail, string aName = null) {
        return this.addEmail("cc", email, name);
    }
    
    /**
     * Sets "bcc" address.
     * Params:
     * string[] aemail String with email,
     *  Array with email as key, name as value or email as value (without name)
     * @param string name Name
     */
    auto setBcc(string[] aemail, string aName = null) {
        return this.setEmail("bcc", email, name);
    }
    
    /**
     * Gets "bcc" address.
     *
     */
    array getBcc() {
        return this.bcc;
    }
    
    /**
     * Add "bcc" address.
     * Params:
     * string[] aemail String with email,
     *  Array with email as key, name as value or email as value (without name)
     * @param string name Name
     */
    auto addBcc(string[] aemail, string aName = null) {
        return this.addEmail("bcc", email, name);
    }
    
    mixin(TProperty!("string", "charset"));
    
    /**
     * HeaderCharset setter.
     * Params:
     * string charset Character set.
     */
    void setHeaderCharset(string charset) {
        this.headerCharset = charset;
    }
    
    // HeaderCharset getter.
    string getHeaderCharset() {
        return this.headerCharset ?: this.charset;
    }
    
    /**
     * TransferEncoding setter.
     * Params:
     * string encoding Encoding set.
     * @return this
     * @throws \InvalidArgumentException
     */
    auto setTransferEncoding(string aencoding) {
        if (encoding !isNull) {
            encoding = encoding.toLower;
            if (!in_array(encoding, this.transferEncodingAvailable, true)) {
                throw new InvalidArgumentException(
                    "Transfer encoding not available. Can be : %s."
                    .format(join(", ", this.transferEncodingAvailable))
                );
            }
        }
        this.transferEncoding = encoding;

        return this;
    }
    
    /**
     * TransferEncoding getter.
     */
    string getTransferEncoding() {
        return this.transferEncoding;
    }
    
    /**
     * EmailPattern setter/getter
     * Params:
     * string regex The pattern to use for email address validation,
     *  null to unset the pattern and make use of filter_var() instead.
     */
    auto setEmailPattern(string aregex) {
        this.emailPattern = regex;

        return this;
    }
    
    /**
     * EmailPattern setter/getter
     */
    string getEmailPattern() {
        return this.emailPattern;
    }
    
    /**
     * Set email
     * Params:
     * string avarName Property name
     * @param string[] aemail String with email,
     *  Array with email as key, name as value or email as value (without name)
     * @param string name Name
     */
    protected void setEmail(string avarName, string[] aemail, string aName) {
        if (!isArray(email)) {
            this.validateEmail(email, varName);
            this.{varName} = [email: name ?? email];

            return;
        }
        list = [];
        foreach (email as aKey: aValue) {
            if (isInt(aKey)) {
                aKey = aValue;
            }
            this.validateEmail(aKey, varName);
            list[aKey] = aValue ?? aKey;
        }
        this.{varName} = list;
    }
    
    /**
     * Validate email address
     * Params:
     * string aemail Email address to validate
     * @param string acontext Which property was set
     */
    protected void validateEmail(string emailAddress, string acontext) {
        if (this.emailPattern.isNull) {
            if (filter_var(emailAddress, FILTER_VALIDATE_EMAIL)) {
                return;
            }
        } else if (preg_match(this.emailPattern, emailAddress)) {
            return;
        }
        context = ltrim(context, "_");
        if (emailAddress.isEmpty) {
            throw new InvalidArgumentException("The email set for `%s` is empty.".format(context));
        }
        throw new InvalidArgumentException("Invalid email set for `%s`. You passed `%s`.".format(context, emailAddress));
    }
    
    /**
     * Set only 1 email
     * Params:
     * string avarName Property name
     * @param string[] aemail String with email,
     *  Array with email as key, name as value or email as value (without name)
     * @param string name Name
     * @param string athrowMessage Exception message
     */
    protected void setEmailSingle(string avarName, string[] aemail, string aName, string exceptionMessage) {
        if (email == []) {
            this.{varName} = email;
            return;
        }

        auto current = this.{varName};
        this.setEmail(varName, email, name);
        if (count(this.{varName}) != 1) {
            this.{varName} = current;
            throw new InvalidArgumentException(exceptionMessage);
        }
    }
    
    /**
     * Add email
     * Params:
     * string avarName Property name
     * @param string[] aemail String with email,
     *  Array with email as key, name as value or email as value (without name)
     * @param string name Name
     */
    protected void addEmail(string avarName, STRINGAA emailValue, string aName) {
        if (!isArray(emailValue)) {
            this.validateEmail(emailValue, varName);
            name ??= emailValue;
            this.{varName}[emailValue] = name;

            return;
        }
        list = [];
        emailValue.byKeyValue
            .each!((kv) {
                if (isInt(aKey)) {
                    aKey = aValue;
                }
                this.validateEmail(aKey, varName);
                list[aKey] = aValue;
            });
        this.{varName} = chain(this.{varName}, list);
    }
    
    /**
     * Sets subject.
     * Params:
     * string asubject Subject string.
     */
    auto setSubject(string asubject) {
        this.subject = this.encodeForHeader(subject);

        return this;
    }
    
    /**
     * Gets subject.
     */
    string subject() {
        return this.subject;
    }
    
    /**
     * Get original subject without encoding
     */
    string getOriginalSubject() {
        return this.decodeForHeader(this.subject);
    }
    
    /**
     * Sets headers for the message
     * Params:
     * array  aHeaders Associative array containing headers to be set.
     */
    auto setHeaders(array  aHeaders) {
        this.headers =  aHeaders;

        return this;
    }
    
    /**
     * Add header for the message
     * Params:
     * array  aHeaders Headers to set.
     */
    auto addHeaders(array  aHeaders) {
        this.headers = Hash.merge(this.headers,  aHeaders);

        return this;
    }
    
    /**
     * Get list of headers
     *
     * ### Includes:
     *
     * - `from`
     * - `replyTo`
     * - `readReceipt`
     * - `returnPath`
     * - `to`
     * - `cc`
     * - `bcc`
     * - `subject`
     * Params:
     * string[] anInclude List of headers.
     */
    string[] getHeaders(array  anInclude = []) {
        this.createBoundary();

        if (anInclude == anInclude.values) {
             anInclude = array_fill_keys(anInclude, true);
        }
        defaults = array_fill_keys(
            [
                "from", "sender", "replyTo", "readReceipt", "returnPath",
                "to", "cc", "bcc", "subject",
            ],
            false
        );
         anInclude += defaults;

         aHeaders = [];
        relation = [
            "from": "From",
            "replyTo": "Reply-To",
            "readReceipt": "Disposition-Notification-To",
            "returnPath": "Return-Path",
            "to": "To",
            "cc": "Cc",
            "bcc": "Bcc",
        ];
         aHeadersMultipleEmails = ["to", "cc", "bcc", "replyTo"];
        foreach (relation as var:  aHeader) {
            if (anInclude[var]) {
                aHeaders[aHeader] = aHeadersMultipleEmails.has(var)
                    ? this.formatAddress(this.{var}).join(", ")
                    : (string)current(this.formatAddress(this.{var}));
            }
        }
        if (anInclude["sender"]) {
            if (key(this.sender) == key(this.from)) {
                 aHeaders["Sender"] = "";
            } else {
                 aHeaders["Sender"] = (string)current(this.formatAddress(this.sender));
            }
        }
         aHeaders += this.headers;
        if (!isSet( aHeaders["Date"])) {
             aHeaders["Date"] = date(DATE_RFC2822);
        }
        if (this.messageId != false) {
            if (this.messageId == true) {
                this.messageId = "<" ~ Text.uuid().replace("-", "") ~ "@" ~ this.domain ~ ">";
            }
             aHeaders["Message-ID"] = this.messageId;
        }
        if (this.priority) {
             aHeaders["X-Priority"] = (string)this.priority;
        }
        if (anInclude["subject"]) {
             aHeaders["Subject"] = this.subject;
        }
         aHeaders["MIME-Version"] = "1.0";
        if (this.attachments) {
             aHeaders["Content-Type"] = "multipart/mixed; boundary="" ~ (string)this.boundary ~ """;
        } else if (this.emailFormat == MESSAGE_BOTH) {
             aHeaders["Content-Type"] = "multipart/alternative; boundary="" ~ (string)this.boundary ~ """;
        } else if (this.emailFormat == MESSAGE_TEXT) {
             aHeaders["Content-Type"] = "text/plain; charset=" ~ this.getContentTypeCharset();
        } else if (this.emailFormat == MESSAGE_HTML) {
             aHeaders["Content-Type"] = "text/html; charset=" ~ this.getContentTypeCharset();
        }
         aHeaders["Content-Transfer-Encoding"] = this.getContentTransferEncoding();

        return aHeaders;
    }
    
    /**
     * Get headers as string.
     * Params:
     * string[] anInclude List of headers.
     * @param string aeol End of line string for concatenating headers.
     * @param \Closure|null aCallback Callback to run each header value through before stringifying.
     */
    string getHeadersString(array  anInclude = [], string aeol = "\r\n", ?Closure aCallback = null) {
        auto lines = this.getHeaders(anInclude);

        if (aCallback) {
            lines = array_map(aCallback, lines);
        }
        
        auto aHeaders = [];
        foreach (aKey: aValue; lines) {
            if (isEmpty(aValue) && aValue != "0") {
                continue;
            }
            foreach ((array)aValue as val) {
                 aHeaders ~= aKey ~ ": " ~ val;
            }
        }
        return join(eol,  aHeaders);
    }
    
    /**
     * Format addresses
     *
     * If the address contains non alphanumeric/whitespace characters, it will
     * be quoted as characters like `:` and `,` are known to cause issues
     * in address header fields.
     * Params:
     * array address Addresses to format.
     */
    protected array formatAddress(array address) {
        auto result;
        foreach (address as email: alias) {
            if (email == alias) {
                result ~= email;
            } else {
                encoded = this.encodeForHeader(alias);
                if (preg_match("/[^a-z0-9+\-\\=? ]/i", encoded)) {
                    encoded = "\"" ~ addcslashes(encoded, ""\\") ~ "\"";
                }
                result ~= "%s <%s>".format(encoded, email);
            }
        }
        return result;
    }
    
    /**
     * Sets email format.
     * Params:
     * string aformat Formatting string.
     */
    void setEmailFormat(string aformat) {
        if (!in_array(aformat, this.emailFormatAvailable, true)) {
            throw new InvalidArgumentException("Format not available.");
        }
        this.emailFormat = format;
    }
    
    // Gets email format.
    string emailFormat() {
        return _emailFormat;
    }
    
    // Gets the body types that are in this email message
    array getBodyTypes() {
        string format = _emailFormat;

        if (format == MESSAGE_BOTH) {
            return [MESSAGE_HTML, MESSAGE_TEXT];
        }
        return [format];
    }
    
    /**
     * Sets message ID.
     * Params:
     * string|bool message True to generate a new Message-ID, False to ignore (not send in email),
     *  String to set as Message-ID.
     */
    void setMessageId(bool message) {
            this.messageId = message;
        // TODO
        
    }
    void setMessageId(string message) {
        if (!preg_match("/^\<.+@.+\>/", message)) {
            throw new InvalidArgumentException(
                "Invalid format to Message-ID. The text should be something like "<uuid@server.com>""
            );
        }
        this.messageId = message;
    }
    
    // Gets message ID.
    string|bool getMessageId() {
        return this.messageId;
    }
    
    /**
     * Sets domain.
     *
     * Domain as top level (the part after @).
     * Params:
     * string adomain Manually set the domain for CLI mailing.
     */
    auto setDomain(string adomain) {
        this.domain = domain;

        return this;
    }
    
    // Gets domain.
    string getDomain() {
        return this.domain;
    }
    
    /**
     * Add attachments to the email message
     *
     * Attachments can be defined in a few forms depending on how much control you need:
     *
     * Attach a single file:
     *
     * ```
     * this.setAttachments("path/to/file");
     * ```
     *
     * Attach a file with a different filename:
     *
     * ```
     * this.setAttachments(["custom_name.txt": "path/to/file.txt"]);
     * ```
     *
     * Attach a file and specify additional properties:
     *
     * ```
     * this.setAttachments(["custom_name.png": [
     *     "file": "path/to/file",
     *     "mimetype": "image/png",
     *     "contentId": "abc123",
     *     "contentDisposition": false
     *   ]
     * ]);
     * ```
     *
     * Attach a file from string and specify additional properties:
     *
     * ```
     * this.setAttachments(["custom_name.png": [
     *     "data": file_get_contents("path/to/file"),
     *     "mimetype": "image/png"
     *   ]
     * ]);
     * ```
     *
     * The `contentId` key allows you to specify an inline attachment. In your email text, you
     * can use `<img src="cid:abc123">` to display the image inline.
     *
     * The `contentDisposition` key allows you to disable the `Content-Disposition` header, this can improve
     * attachment compatibility with outlook email clients.
     */
    void setAttachments(DirEntry[string] fileAttachments) {
        auto attach = [];
        foreach (attName; dirEntry; fileAttachments) {
            if (!isArray(dirEntry)) {
                dirEntry = ["file": dirEntry];
            }
            if (!dirEntry.isSet("file")) {
                if (!isSet(dirEntry["data"])) {
                    throw new InvalidArgumentException("No file or data specified.");
                }
                if (isInt(attName)) {
                    throw new InvalidArgumentException("No filename specified.");
                }
                dirEntry["data"] = chunk_split(base64_encode(dirEntry["data"]), 76, "\r\n");
            } else if (cast(IUploadedFile)dirEntry["file"]) {
                dirEntry["mimetype"] = dirEntry["file"].getClientMediaType();
                if (isInt(attName)) {
                    attName = dirEntry["file"].getClientFilename();
                    assert(isString(attName));
                }
            } else if (isString(dirEntry["file"])) {
                string fileName = dirEntry["file"];
                dirEntry["file"] = realpath(dirEntry["file"]);
                if (dirEntry["file"] == false || !file_exists(dirEntry["file"])) {
                    throw new InvalidArgumentException("File not found: `%s`".format(fileName));
                }
                if (isInt(attName)) {
                    attName = basename(dirEntry["file"]);
                }
            } else {
                throw new InvalidArgumentException(
                    "File must be a filepath or IUploadedFile instance. Found `%s` instead."
                    .format(dirEntry["file"].stringof)
                );
            }
            if (
                !isSet(dirEntry["mimetype"])
                && isSet(dirEntry["file"])
                && isString(dirEntry["file"])
                && function_exists("mime_content_type")
            ) {
                dirEntry["mimetype"] = mime_content_type(dirEntry["file"]);
            }
            if (!isSet(dirEntry["mimetype"])) {
                dirEntry["mimetype"] = "application/octet-stream";
            }
            attach[attName] = dirEntry;
        }
        this.attachments = attach;
    }
    
    // Gets attachments to the email message.
    array<string, array> getAttachments() {
        return this.attachments;
    }
    
    /**
     * Add attachments
     * Params:
     * array attachments Array of filenames.
     * @return this
     * @throws \InvalidArgumentException
     * @see \UIM\Mailer\Email.setAttachments()
     */
    void addAttachments(array attachments) {
        current = this.attachments;
        this.setAttachments(attachments);
        this.attachments = array_merge(current, this.attachments);
    }
    
    /**
     * Get generated message body as array.
     *
     */
    array getBody() {
        if (isEmpty(this.message)) {
            this.message = this.generateMessage();
        }
        return this.message;
    }
    
    // Get generated body as string.
    string getBodyString(string eol = "\r\n") {
        auto lines = this.getBody();

        return lines.join(eol, );
    }
    
    /**
     * Create unique boundary identifier
     */
    protected void createBoundary() {
        if (
            this.boundary.isNull &&
            (
                this.attachments ||
                this.emailFormat == MESSAGE_BOTH
            )
        ) {
            this.boundary = md5(Security.randomBytes(16));
        }
    }
    
    // Generate full message.
    protected string[] generateMessage() {
        this.createBoundary();
        string[] message = [];

        contentIds = array_filter((array)Hash.extract(this.attachments, "{s}.contentId"));
        hasInlineAttachments = count(contentIds) > 0;
        hasAttachments = !empty(this.attachments);
        hasMultipleTypes = this.emailFormat == MESSAGE_BOTH;
        multiPart = (hasAttachments || hasMultipleTypes);

        boundary = this.boundary ?? "";
        relBoundary = textBoundary = boundary;

        if (hasInlineAttachments) {
            message ~= "--" ~ boundary;
            message ~= "Content-Type: multipart/related; boundary="rel-" ~ boundary ~ """;
            message ~= "";
            relBoundary = textBoundary = "rel-" ~ boundary;
        }
        if (hasMultipleTypes && hasAttachments) {
            message ~= "--" ~ relBoundary;
            message ~= "Content-Type: multipart/alternative; boundary="alt-" ~ boundary ~ """;
            message ~= "";
            textBoundary = "alt-" ~ boundary;
        }
        if (
            this.emailFormat == MESSAGE_TEXT
            || this.emailFormat == MESSAGE_BOTH
        ) {
            if (multiPart) {
                message ~= "--" ~ textBoundary;
                message ~= "Content-Type: text/plain; charset=" ~ this.getContentTypeCharset();
                message ~= "Content-Transfer-Encoding: " ~ this.getContentTransferEncoding();
                message ~= "";
            }
            content = split("\n", this.textMessage);
            message = array_merge(message, content);
            message ~= "";
            message ~= "";
        }
        if (
            this.emailFormat == MESSAGE_HTML
            || this.emailFormat == MESSAGE_BOTH
        ) {
            if (multiPart) {
                message ~= "--" ~ textBoundary;
                message ~= "Content-Type: text/html; charset=" ~ this.getContentTypeCharset();
                message ~= "Content-Transfer-Encoding: " ~ this.getContentTransferEncoding();
                message ~= "";
            }
            string[] content = split("\n", this.htmlMessage);
            message = array_merge(message, content);
            message ~= "";
            message ~= "";
        }
        if (textBoundary != relBoundary) {
            message ~= "--" ~ textBoundary ~ "--";
            message ~= "";
        }
        if (hasInlineAttachments) {
            attachments = this.attachInlineFiles(relBoundary);
            message = array_merge(message, attachments);
            message ~= "";
            message ~= "--" ~ relBoundary ~ "--";
            message ~= "";
        }
        if (hasAttachments) {
            attachments = this.attachFiles(boundary);
            message = array_merge(message, attachments);
        }
        if (hasAttachments || hasMultipleTypes) {
            message ~= "";
            message ~= "--" ~ boundary ~ "--";
            message ~= "";
        }
        return message;
    }
    
    /**
     * Attach non-embedded files by adding file contents inside boundaries.
     * Params:
     * string boundary Boundary to use. If null, will default to this.boundary
     */
    protected string[] attachFiles(string aboundary = null) {
        boundary ??= this.boundary;

        message = [];
        foreach (this.attachments as filename: dirEntry) {
            if (!empty(dirEntry["contentId"])) {
                continue;
            }
            someData = dirEntry.get("data", this.readFile(dirEntry["file"]));
            hasDisposition = (
                !isSet(dirEntry["contentDisposition"]) ||
                dirEntry["contentDisposition"]
            );
            part = new FormDataPart("", someData, "", this.getHeaderCharset());

            if (hasDisposition) {
                part.disposition("attachment");
                part.filename(filename);
            }
            part.transferEncoding("base64");
            part.type(dirEntry["mimetype"]);

            message ~= "--" ~ boundary;
            message ~= (string)part;
            message ~= "";
        }
        return message;
    }
    
    /**
     * Attach inline/embedded files to the message.
     * Params:
     * string boundary Boundary to use. If null, will default to this.boundary
     */
    protected string[] attachInlineFiles(string aboundary = null) {
        auto boundary = boundary ? baoundry :  this.boundary;

        auto message = [];
        foreach (this.getAttachments() as filename: dirEntry) {
            if (isEmpty(dirEntry["contentId"])) {
                continue;
            }
            someData = dirEntry["data"] ?? this.readFile(dirEntry["file"]);

            message ~= "--" ~ boundary;
            part = new FormDataPart("", someData, "inline", this.getHeaderCharset());
            part.type(dirEntry["mimetype"]);
            part.transferEncoding("base64");
            part.contentId(dirEntry["contentId"]);
            part.filename(filename);
            message ~= (string)part;
            message ~= "";
        }
        return message;
    }
    
    /**
     * Sets priority.
     * Params:
     * int priority 1 (highest) to 5 (lowest)
     */
    auto setPriority(int priority) {
        this.priority = priority;

        return this;
    }
    
    // Gets priority.
    int getPriority() {
        return this.priority;
    }
    
    /**
     * Sets the configuration for this instance.
     *
     * configData - Config array.
     */
    auto setConfig(IData[string] configData = null) {
        string[] simpleMethods = [
            "from", "sender", "to", "replyTo", "readReceipt", "returnPath",
            "cc", "bcc", "messageId", "domain", "subject", "attachments",
            "emailFormat", "emailPattern", "charset", "headerCharset",
        ];
        simpleMethods.each!((method) {
            if (configuration.hasKey(method))) {
                this.{"set" ~ ucfirst(method)}(configData[method]);
            }
        });
        if (configuration.hasKey("headers")) {
            this.setHeaders(configData("headers"));
        }
        return this;
    }
    
    /**
     * Set message body.
     * Params:
     * STRINGAA content Content array with keys "text" and/or "html" with
     *  content string of respective type.
     */
    auto setBody(array content) {
        foreach (content as type: text) {
            if (!in_array(type, this.emailFormatAvailable, true)) {
                throw new InvalidArgumentException(
                    "Invalid message type: `%s`. Valid types are: `text`, `html`.".format(
                    type
                ));
            }
            text = text.replace(["\r\n", "\r"], "\n");
            text = this.encodeString(text, this.getCharset());
            text = this.wrap(text);
            text = text.join("\n").rstrip("\n");

             aProperty = "{type}Message";
            this. aProperty = text;
        }
        this.boundary = null;
        this.message = [];

        return this;
    }
    
    /**
     * Set text body for message.
     * Params:
     * string acontent Content string
     */
    auto setBodyText(string acontent) {
        this.setBody([MESSAGE_TEXT: content]);

        return this;
    }
    
    /**
     * Set HTML body for message.
     * Params:
     * string acontent Content string
     */
    auto setBodyHtml(string acontent) {
        this.setBody([MESSAGE_HTML: content]);

        return this;
    }
    
    /**
     * Get text body of message.
     */
    string getBodyText() {
        return this.textMessage;
    }
    
    /**
     * Get HTML body of message.
     */
    string getBodyHtml() {
        return this.htmlMessage;
    }
    
    /**
     * Translates a string for one charset to another if the App.encoding value
     * differs and the mb_convert_encoding auto exists
     * Params:
     * string atext The text to be converted
     * @param string acharset the target encoding
     */
    protected string encodeString(string atext, string acharset) {
        if (this.appCharset == charset) {
            return text;
        }
        if (this.appCharset.isNull) {
            return mb_convert_encoding(text, charset);
        }
        return mb_convert_encoding(text, charset, this.appCharset);
    }
    
    /**
     * Wrap the message to follow the RFC 2822 - 2.1.1
     * Params:
     * string message Message to wrap
     * @param int wrapLength The line length
     */
    protected string[] wrap(string amessage = null, int wrapLength = self.LINE_LENGTH_MUST) {
        if (message.isNull || message.isEmpty) {
            return [""];
        }
        message = message.replace(["\r\n", "\r"], "\n");
        string[] lines = split("\n", message);
        formatted = [];
        cut = (wrapLength == LINE_LENGTH_MUST);

        foreach (lines as line) {
            if (isEmpty(line) && line != "0") {
                formatted ~= "";
                continue;
            }
            if (line.length < wrapLength) {
                formatted ~= line;
                continue;
            }
            if (!preg_match("/<[a-z]+.*>/i", line)) {
                formatted = array_merge(
                    formatted,
                    split("\n", Text.wordWrap(line, wrapLength, "\n", cut))
                );
                continue;
            }
            tagOpen = false;
            string tmpLine;
            string tag;
            tmpLineLength = 0;
            for (anI = 0, count = line.length;  anI < count;  anI++) {
                char = line[anI];
                if (tagOpen) {
                    tag ~= char;
                    if (char == ">") {
                        tagLength = tag.length;
                        if (tagLength + tmpLineLength < wrapLength) {
                            tmpLine ~= tag;
                            tmpLineLength += tagLength;
                        } else {
                            if (tmpLineLength > 0) {
                                formatted = chain(
                                    formatted,
                                    split("\n", Text.wordWrap(trim(tmpLine), wrapLength, "\n", cut))
                                );
                                tmpLine = "";
                                tmpLineLength = 0;
                            }
                            if (tagLength > wrapLength) {
                                formatted ~= tag;
                            } else {
                                tmpLine = tag;
                                tmpLineLength = tagLength;
                            }
                        }
                        tag = "";
                        tagOpen = false;
                    }
                    continue;
                }
                if (char == "<") {
                    tagOpen = true;
                    tag = "<";
                    continue;
                }
                if (char == " " && tmpLineLength >= wrapLength) {
                    formatted ~= tmpLine;
                    tmpLineLength = 0;
                    continue;
                }
                tmpLine ~= char;
                tmpLineLength++;
                if (tmpLineLength == wrapLength) {
                    nextChar = line[anI + 1] ?? "";
                    if (nextChar == " " || nextChar == "<") {
                        formatted ~= trim(tmpLine);
                        tmpLine = "";
                        tmpLineLength = 0;
                        if (nextChar == " ") {
                             anI++;
                        }
                    } else {
                        lastSpace = strrpos(tmpLine, " ");
                        if (lastSpace == false) {
                            continue;
                        }
                        formatted ~= trim(substr(tmpLine, 0, lastSpace));
                        tmpLine = substr(tmpLine, lastSpace + 1);

                        tmpLineLength = tmpLine.length;
                    }
                }
            }
            if (!empty(tmpLine)) {
                formatted ~= tmpLine;
            }
        }
        formatted ~= "";

        return formatted;
    }
    
    // Reset all the internal variables to be able to send out a new email.
    auto reset() {
        this.to = [];
        this.from = [];
        this.sender = [];
        this.replyTo = [];
        this.readReceipt = [];
        this.returnPath = [];
        this.cc = [];
        this.bcc = [];
        this.messageId = true;
        this.subject = "";
        this.headers = [];
        this.textMessage = "";
        this.htmlMessage = "";
        this.message = [];
        this.emailFormat = MESSAGE_TEXT;
        this.priority = null;
        this.charset = "utf-8";
        this.headerCharset = null;
        this.transferEncoding = null;
        this.attachments = [];
        this.emailPattern = EMAIL_PATTERN;

        return this;
    }
    
    /**
     * Encode the specified string using the current charset
     * Params:
     * string atext String to encode
     */
    protected string encodeForHeader(string textToEncode) {
        if (this.appCharset.isNull) {
            return textToEncode;
        }
        restore = mb_internal_encoding();
        mb_internal_encoding(this.appCharset);
        auto result = mb_encode_mimeheader(textToEncode, this.getHeaderCharset(), "B");
        mb_internal_encoding(restore);

        return result;
    }
    
    /**
     * Decode the specified string
     * Params:
     * string atext String to decode
     */
    protected string decodeForHeader(string textToEncode) {
        if (this.appCharset.isNull) {
            return textToEncode;
        }
        restore = mb_internal_encoding();
        mb_internal_encoding(this.appCharset);
        result = mb_decode_mimeheader(textToEncode);
        mb_internal_encoding(restore);

        return result;
    }
    
    /**
     * Read the file contents and return a base64 version of the file contents.
     * Params:
     * \Psr\Http\Message\IUploadedFile|string afile The absolute path to the file to read
     *  or IUploadedFile instance.
     */
    protected string readFile(IUploadedFile|string afile) {
        if (isString(file)) {
            content = (string)file_get_contents(file);
        } else {
            content = (string)file.getStream();
        }
        return chunk_split(base64_encode(content));
    }
    
    /**
     * Return the Content-Transfer Encoding value based
     * on the set transferEncoding or set charset.
     */
    string getContentTransferEncoding() {
        if (this.transferEncoding) {
            return this.transferEncoding;
        }
        charset = strtoupper(this.charset);
        if (in_array(charset, this.charset8bit, true)) {
            return "8bit";
        }
        return "7bit";
    }
    
    /**
     * Return charset value for Content-Type.
     *
     * Checks fallback/compatibility types which include workarounds
     * for legacy japanese character sets.
     */
    string getContentTypeCharset() {
        charset = strtoupper(this.charset);
        if (array_key_exists(charset, this.contentTypeCharset)) {
            return strtoupper(this.contentTypeCharset[charset]);
        }
        return strtoupper(this.charset);
    }
    
    /**
     * Serializes the email object to a value that can be natively serialized and re-used
     * to clone this email instance.
     *
     * @return array Serializable array of configuration properties.
     * @throws \Exception When a view var object can not be properly serialized.
     */
    array jsonSerialize() {
        array = [];
        foreach (this.serializableProperties as  aProperty) {
            array[aProperty] = this.{ aProperty};
        }
         array_walk(array["attachments"], auto (& anItem, aKey) {
            if (!empty(anItem["file"])) {
                 anItem["data"] = this.readFile(anItem["file"]);
                unset(anItem["file"]);
            }
        });

        return array_filter(array, auto (anI) {
            return anI !isNull && !isArray(anI) && !isBool(anI) && anI.length || !empty(anI);
        });
    }
    
    /**
     * Configures an email instance object from serialized config.
     *
     * configData - Email configuration array.
     */
    void createFromArray(IData[string] configData = null) {
        foreach (configData as  aProperty: aValue) {
            this.{ aProperty} = aValue;
        }
    }
    
    /**
     * Magic method used for serializing the Message object.
     *
     */
    array __serialize() {
        array = this.jsonSerialize();
        array_walk_recursive(array, void (& anItem, aKey) {
            if (cast(SimpleXMLElement)anItem ) {
                 anItem = json_decode((string)json_encode((array) anItem), true);
            }
        });

        return array;
    }
    
    /**
     * Magic method used to rebuild the Message object.
     * Params:
     * array data Data array.
     */
    void __unserialize(array data) {
        this.createFromArray(someData);
    }
}

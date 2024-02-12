module uim.cake.Mailer\Transport;

import uim.cake;

@safe:

// Send mail using SMTP protocol
class SmtpTransport : AbstractTransport {
    const AUTH_PLAIN = "PLAIN";
    const AUTH_LOGIN = "LOGIN";
    const AUTH_XOAUTH2 = "XOAUTH2";

    const SUPPORTED_AUTH_TYPES = [
        self.AUTH_PLAIN,
        self.AUTH_LOGIN,
        self.AUTH_XOAUTH2,
    ];

    protected IData[string] _defaultConfigData = [
        "host": "localhost",
        "port": 25,
        "timeout": 30,
        "username": null,
        "password": null,
        "client": null,
        "tls": false,
        "keepAlive": false,
        "authType": null,
    ];

    /**
     * Socket to SMTP server
     */
    protected Socket _socket;

    /**
     * Content of email to return
     */
    protected STRINGAA _content = [];

    /**
     * The response of the last sent SMTP command.
     */
    protected array _lastResponse = [];

    /**
     * Authentication type.
     */
    protected string aauthType = null;

    /**
     * Destructor
     *
     * Tries to disconnect to ensure that the connection is being
     * terminated properly before the socket gets closed.
     */
    auto __destruct() {
        try {
            this.disconnect();
        } catch (Exception) {
            // avoid fatal error on script termination
        }
    }
    
    /**
     * Unserialize handler.
     *
     * Ensure that the socket property isn"t reinitialized in a broken state.
     */
    void __wakeup() {
        unset(_socket);
    }
    
    /**
     * Connect to the SMTP server.
     *
     * This method tries to connect only in case there is no open
     * connection available already.
     */
    void connect() {
        if (!this.connected()) {
           _connect();
           _auth();
        }
    }
    
    /**
     * Check whether an open connection to the SMTP server is available.
     */
   bool connected() {
        return isSet(_socket) && _socket.isConnected();
    }
    
    /**
     * Disconnect from the SMTP server.
     *
     * This method tries to disconnect only in case there is an open
     * connection available.
     */
    void disconnect() {
        if (!this.connected()) {
            return;
        }
       _disconnect();
    }
    
    /**
     * Returns the response of the last sent SMTP command.
     *
     * A response consists of one or more lines containing a response
     * code and an optional response message text:
     * ```
     * [
     *    [
     *        "code": "250",
     *        "message": "mail.example.com"
     *    ],
     *    [
     *        "code": "250",
     *        "message": "PIPELINING"
     *    ],
     *    [
     *        "code": "250",
     *        "message": "8BITMIME"
     *    ],
     *    // etc...
     * ]
     * ```
     *
     */
    array getLastResponse() {
        return _lastResponse;
    }
    
    /**
     * Send mail
     * Params:
     * \UIM\Mailer\Message message Message instance
     */
    array send(Message message) {
        this.checkRecipient(message);

        if (!this.connected()) {
           _connect();
           _auth();
        } else {
           _smtpSend("RSET");
        }
       _sendRcpt(message);
       _sendData(message);

        if (!configuration.data("keepAlive"]) {
           _disconnect();
        }
        /** @var array{headers: string, message: string} */
        return _content;
    }
    
    /**
     * Parses and stores the response lines in `"code": "message"` format.
     * Params:
     * string[] responseLines Response lines to parse.
     */
    protected void _bufferResponseLines(array responseLines) {
        response = [];
        foreach (responseLines as responseLine) {
            if (preg_match("/^(\d{3})(?:[-]+(.*))?/", responseLine, match)) {
                response ~= [
                    "code": match[1],
                    "message": match[2] ?? null,
                ];
            }
        }
       _lastResponse = chain(_lastResponse, response);
    }
    
    /**
     * Parses the last response line and extract the preferred authentication type.
     */
    protected void _parseAuthType() {
        authType = _configData.isSet("authType");
        if (authType !isNull) {
            if (!in_array(authType, self.SUPPORTED_AUTH_TYPES)) {
                throw new UimException(
                    "Unsupported auth type. Available types are: " ~ join(", ", self.SUPPORTED_AUTH_TYPES)
                );
            }
            this.authType = authType;

            return;
        }
        if (!isSet(configuration.data("username"], configuration.data("password"])) {
            return;
        }
        
        string auth;
        foreach (line; _lastResponse) {
            if (line["message"].length == 0 || substr(line["message"], 0, 5) == "AUTH ") {
                auth = line["message"];
                break;
            }
        }
        if (!auth.isEmpty) {
            return;
        }
        foreach (self.SUPPORTED_AUTH_TYPES as type) {
            if (auth.has(type)) {
                this.authType = type;

                return;
            }
        }
        throw new UimException("Unsupported auth type: " ~ substr(auth, 5));
    }
    
    // Connect to SMTP Server
    protected void _connect() {
       _generateSocket();
        if (!_socket.connect()) {
            throw new SocketException("Unable to connect to SMTP server.");
        }
       _smtpSend(null, "220");

        configData = _config;

        auto host = "localhost";
        if (configuration.hasKey("client")) {
            if (configData("client").isEmpty) {
                throw new SocketException("Cannot use an empty client name.");
            }
            host = configData("client"];
        } else {
            httpHost = enviroment("HTTP_HOST");
            if (isString(httpHost) && httpHost.length) {
                [host] = split(":", httpHost);
            }
        }
        try {
           _smtpSend("EHLO {host}", "250");
            if (!configData("tls").isNull) {
               _smtpSend("STARTTLS", "220");
               _socket.enableCrypto("tls");
               _smtpSend("EHLO {host}", "250");
            }
        } catch (SocketException  anException) {
            if (!configData("tls").isNull) {
                throw new SocketException(
                    "SMTP server did not accept the connection or trying to connect to non TLS SMTP server using TLS.",
                    null,
                     anException
                );
            }
            try {
               _smtpSend("HELO {host}", "250");
            } catch (SocketException e2) {
                throw new SocketException("SMTP server did not accept the connection.", null, e2);
            }
        }
       _parseAuthType();
    }
    
    // Send authentication
    protected void _auth() {
        if (!configuration.hasKey("username", "password")) {
            return;
        }

        auto username = configData("username");
        auto password = configData("password");

        switch (this.authType) {
            case self.AUTH_PLAIN:
               _authPlain(username, password);
                break;

            case self.AUTH_LOGIN:
               _authLogin(username, password);
                break;

            case self.AUTH_XOAUTH2:
               _authXoauth2(username, password);
                break;

            default:
                replyCode = _authPlain(username, password);
                if (replyCode == "235") {
                    break;
                }
               _authLogin(username, password);
        }
    }
    
    // Authenticate using AUTH PLAIN mechanism.
    protected string _authPlain(string username, string password) {
        return _smtpSend(
            "AUTH PLAIN %s"
                .format(base64_encode(chr(0) ~ username ~ chr(0) ~ password)),
            "235|504|534|535"
        );
    }
    
    /**
     * Authenticate using AUTH LOGIN mechanism.
     */
    protected void _authLogin(string username, string password) {
        string replyCode = _smtpSend("AUTH LOGIN", "334|500|502|504");
        if (replyCode == "334") {
            try {
               _smtpSend(base64_encode(username), "334");
            } catch (SocketException  anException) {
                throw new SocketException("SMTP server did not accept the username.", null,  anException);
            }
            try {
               _smtpSend(base64_encode(password), "235");
            } catch (SocketException anException) {
                throw new SocketException("SMTP server did not accept the password.", null,  anException);
            }
        } else if (replyCode == "504") {
            throw new SocketException("SMTP authentication method not allowed, check if SMTP server requires TLS.");
        } else {
            throw new SocketException(
                "AUTH command not recognized or not implemented, SMTP server may not require authentication."
            );
        }
    }
    
    /**
     * Authenticate using AUTH XOAUTH2 mechanism.
     * Params:
     * string ausername Username.
     * @param string atoken Token.
     */
    protected void _authXoauth2(string username, string atoken) {
        auto authString = base64_encode(
            "user=%s\1auth=Bearer %s\1\1"
            .format(username,
            token
        ));

       _smtpSend("AUTH XOAUTH2 " ~ authString, "235");
    }
    
    /**
     * Prepares the `MAIL FROM` SMTP command.
     * Params:
     * string amessage The email address to send with the command.
     */
    protected string _prepareFromCmd(string amessage) {
        return "MAIL FROM:<" ~ message ~ ">";
    }
    
    /**
     * Prepares the `RCPT TO` SMTP command.
     * Params:
     * string amessage The email address to send with the command.
     */
    protected string _prepareRcptCmd(string amessage) {
        return "RCPT TO:<" ~ message ~ ">";
    }
    
    /**
     * Prepares the `from` email address.
     * Params:
     * \UIM\Mailer\Message message Message instance
     */
    protected array _prepareFromAddress(Message message) {
        from = message.getReturnPath();
        if (isEmpty(from)) {
            from = message.getFrom();
        }
        return from;
    }
    
    /**
     * Prepares the recipient email addresses.
     * Params:
     * \UIM\Mailer\Message message Message instance
     */
    protected array _prepareRecipientAddresses(Message message) {
        to = message.getTo();
        cc = message.getCc();
        bcc = message.getBcc();

        return chain(array_keys(to), array_keys(cc), array_keys(bcc));
    }
    
    /**
     * Prepares the message body.
     * Params:
     * \UIM\Mailer\Message message Message instance
     */
    protected string _prepareMessage(Message message) {
        auto lines = message.getBody();
        string messages = lines
            .map!(line => !empty(line) && (line[0] == ".") ? "." ~ line : line).array;
        return messages.join("\r\n", );
    }
    
    /**
     * Send emails
     * Params:
     * \UIM\Mailer\Message message Message instance
     * @throws \UIM\Network\Exception\SocketException
     */
    protected void _sendRcpt(Message message) {
        from = _prepareFromAddress(message);
       _smtpSend(_prepareFromCmd((string)key(from)));

        messages = _prepareRecipientAddresses(message);
        foreach (messages as mail) {
           _smtpSend(_prepareRcptCmd(mail));
        }
    }
    
    /**
     * Send Data
     * Params:
     * \UIM\Mailer\Message message Message instance
     */
    protected void _sendData(Message message) {
       _smtpSend("DATA", "354");

         aHeaders = message.getHeadersString([
            "from",
            "sender",
            "replyTo",
            "readReceipt",
            "to",
            "cc",
            "subject",
            "returnPath",
        ]);
        message = _prepareMessage(message);

       _smtpSend( aHeaders ~ "\r\n\r\n" ~ message ~ "\r\n\r\n\r\n.");
       _content = ["headers":  aHeaders, "message": message];
    }
    
    /**
     * Disconnect
     */
    protected void _disconnect() {
       _smtpSend("QUIT", false);
       _socket.disconnect();
        this.authType = null;
    }
    
    /**
     * Helper method to generate socket
     */
    protected void _generateSocket() {
       _socket = new Socket(_config);
    }
    
    /**
     * Protected method for sending data to SMTP connection
     * Params:
     * string someData Data to be sent to SMTP server
     * @param string|false checkCode Code to check for in server response, false to skip
     */
    protected string _smtpSend(string adata, string|false checkCode = "250") {
       _lastResponse = [];

        if (someData !isNull) {
           _socket.write(someData ~ "\r\n");
        }
        timeout = configuration.data("timeout"];

        while (checkCode != false) {
            response = "";
            startTime = time();
            while (!response.endsWith("\r\n") && (time() - startTime < timeout)) {
                bytes = _socket.read();
                if (bytes.isNull) {
                    break;
                }
                response ~= bytes;
            }
            // Catch empty or malformed responses.
            if (!response.endsWith("\r\n")) {
                // Use response message or assume operation timed out.
                throw new SocketException(response ?: "SMTP timeout.");
            }
            responseLines = split("\r\n", rtrim(response, "\r\n"));
            response = end(responseLines);

           _bufferResponseLines(responseLines);

            if (preg_match("/^(" ~ checkCode ~ ")(.)/", response, code)) {
                if (code[2] == "-") {
                    continue;
                }
                return code[1];
            }
            throw new SocketException("SMTP Error: %s".format(response));
        }
        return null;
    }
}

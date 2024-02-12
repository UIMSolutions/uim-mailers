module uim.cake.Mailer;

import uim.cake;

@safe:

// Rendering email message.
class Renderer {
    mixin ViewVarsTemplate();

    // Constant for folder name containing email templates.
    const string TEMPLATE_FOLDER = "email";

    this() {
        this.reset();
    }
    
    /**
     * Render text/HTML content.
     *
     * If there is no template set, the content will be returned in a hash
     * of the specified content types for the email.
     * Params:
     * string acontent The content.
     * @param string[] types Content types to render. Valid array values are Message.MESSAGE_HTML, Message.MESSAGE_TEXT.
     * @psalm-param array<\UIM\Mailer\Message.MESSAGE_HTML|\UIM\Mailer\Message.MESSAGE_TEXT> types
     * @psalm-return array{html?: string, text?: string}
     */
    STRINGAA render(string acontent, array types = []) {
        rendered = [];
        template = this.viewBuilder().getTemplate();
        if (isEmpty(template)) {
            types.each!(type => rendered[type] = content);
            return rendered;
        }
        view = this.createView();

        [templatePlugin] = pluginSplit(view.getTemplate());
        [layoutPlugin] = pluginSplit(view.getLayout());
        if (templatePlugin) {
            view.setPlugin(templatePlugin);
        } else if (layoutPlugin) {
            view.setPlugin(layoutPlugin);
        }
        if (view.get("content").isNull) {
            view.set("content", content);
        }

        types.each!((type) {
            view.setTemplatePath(TEMPLATE_FOLDER ~ DIRECTORY_SEPARATOR ~ type);
            view.setLayoutPath(TEMPLATE_FOLDER ~ DIRECTORY_SEPARATOR ~ type);

            rendered[type] = view.render();
        });

        return rendered;
    }
<<<<<<< HEAD
    
=======

>>>>>>> 74a7b6400cdc9ef55c74d50ddcb3fb9c29d1e0bf
    /**
     * Reset view builder to defaults.
     */
    auto reset() {
       _viewBuilder = null;

        this.viewBuilder()
            .setClassName(View.classname)
            .setLayout("default")
            .setHelpers(["Html"]);

        return this;
    }

    // Clone ViewBuilder instance when renderer is cloned.
    void __clone() {
        if (_viewBuilder !isNull) {
           _viewBuilder = clone _viewBuilder;
        }
    }
}

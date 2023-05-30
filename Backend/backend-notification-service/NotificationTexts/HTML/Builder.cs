using backend_notification_service.NotificationTexts.HTML.UserMail;

namespace backend_notification_service.NotificationTexts.HTML;

public static class Builder
{
    internal static string BuildHtml(string title, string preHeader, string content)
    {
        var html = HtmlStaticContent.Base
            .Replace("{{title}}", title);
        html += HtmlStaticContent.Header
            .Replace("{{preheader}}", preHeader);
        html += content;
        html += HtmlStaticContent.Footer;
        return html;
    }
}
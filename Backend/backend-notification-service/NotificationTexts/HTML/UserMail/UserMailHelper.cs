namespace backend_notification_service.NotificationTexts.HTML.UserMail;

public class UserMailHelper
{
    public static string GenerateAccountConfirmation(string name, string url, string mail)
    {
        var body = HtmlAccountConfirmation.Html
            .Replace("{{name}}", name)
            .Replace("{{action_url}}", url)
            .Replace("{{mail}}", mail);

        return Builder.BuildHtml("Bestätige deine E-Mail-Adresse",
            "Bitte bestätige deine E-Mail-Adresse, um deine Registrierung abzuschließen.", body);
    }

    public static string GeneratePasswordReset(string name, string url)
    {
        var body = HtmlMailPasswordReset.Html
            .Replace("{{name}}", name)
            .Replace("{{action_url}}", url);

        return Builder.BuildHtml("Passwort zurücksetzen", "Bitte klicke auf den Link, um dein Passwort zurückzusetzen.", body);
    }

    public static string GeneratePasswordChanged(string name)
    {
        var body = HtmlMailPasswordChanged.Html
            .Replace("{{name}}", name);

        return Builder.BuildHtml("Passwort geändert", "Ihr Passwort wurde erfolgreich geändert.", body);
    }

    public static string GenerateInvitationNewAccount(string url, string mail)
    {
        var body = HtmlNewAccountInvitation.Html
            .Replace("{{action_url}}", url)
            .Replace("{{mail}}", mail);
        return Builder.BuildHtml("Einladung zum Beitritt zu mars smokey", 
            "Nehme hier die Einladung an.", body);
    }

    public static string GenerateInvitationExistingAccount(string name)
    {
        var body = HtmlExistingAccountInvitation.Html
            .Replace("{{name}}", name);
        return Builder.BuildHtml("Neue Berechtigungen", "Sie haben neue Berechtigungen.", body);
    }
}
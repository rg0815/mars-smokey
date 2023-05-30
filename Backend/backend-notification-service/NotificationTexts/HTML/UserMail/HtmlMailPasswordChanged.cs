namespace backend_notification_service.NotificationTexts.HTML.UserMail;

public static class HtmlMailPasswordChanged
{
    public const string Html = @"
                <tr>
                    <td class='email-body' width='570' cellpadding='0' cellspacing='0'>
                        <table class='email-body_inner' align='center' width='570' cellpadding='0' cellspacing='0'
                               role='presentation'>
                            <!-- Body content -->
                            <tr>
                                <td class='content-cell'>
                                    <div class='f-fallback'>
                                        <h1>Hallo {{name}},</h1>
                                        <p>Ihr Passwort wurde erfolgreich geändert!</p>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>";
}
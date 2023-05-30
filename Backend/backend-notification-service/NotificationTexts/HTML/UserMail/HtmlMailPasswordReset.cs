namespace backend_notification_service.NotificationTexts.HTML.UserMail;

public static class HtmlMailPasswordReset
{
    public const string Html = @"<tr>
                    <td class='email-body' width='570' cellpadding='0' cellspacing='0'>
                        <table class='email-body_inner' align='center' width='570' cellpadding='0' cellspacing='0'
                               role='presentation'>
                            <!-- Body content -->
                            <tr>
                                <td class='content-cell'>
                                    <div class='f-fallback'>
                                        <h1>Hallo {{name}},</h1>
                                        <p>Sie haben soeben das Zurücksetzen Ihres Passworts für Ihr Konto beantragt. 
                                        Verwenden Sie die Schaltfläche unten, um es zurückzusetzen. 
<strong>Das Zurücksetzen des Passworts ist nur für die nächsten 5 Stunden gültig.</strong></p>
                                        <!-- Action -->
                                        <table class='body-action' align='center' width='100%' cellpadding='0'
                                               cellspacing='0' role='presentation'>
                                            <tr>
                                                <td align='center'>
                                                    <!-- Border based button
                                 https://litmus.com/blog/a-guide-to-bulletproof-buttons-in-email-design -->
                                                    <table width='100%' border='0' cellspacing='0' cellpadding='0'
                                                           role='presentation'>
                                                        <tr>
                                                            <td align='center'>
                                                                <a href='{{action_url}}'
                                                                   class='f-fallback button button--green'
                                                                   target='_blank'>Passwort zurücksetzen</a>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>";
}
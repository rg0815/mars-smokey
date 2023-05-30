namespace backend_notification_service.NotificationTexts.HTML.Notifications;

public static class HtmlEvacuationAlarm
{
    public const string Html = @" <tr>
                    <td class='email-body' width='570' cellpadding='0' cellspacing='0'>
                        <table class='email-body_inner' align='center' width='570' cellpadding='0' cellspacing='0'
                               role='presentation'>
                            <!-- Body content -->
                            <tr>
                                <td class='content-cell'>
                                    <div class='f-fallback'>
                                        <h1>Lieber Benutzer!</h1>
                                        <p>In Ihrem Gebäude {{building}} wurden mehrere Brände erkannt.
                                            Wir bitten Sie, das Gebäude - wenn möglich - umgehend zu verlassen!</p>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>";
}
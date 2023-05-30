namespace backend_notification_service.NotificationTexts.HTML.Notifications;

public static class HtmlPreAlarm
{
    public static string Html = @"   <tr>
                    <td class='email-body' width='570' cellpadding='0' cellspacing='0'>
                        <table class='email-body_inner' align='center' width='570' cellpadding='0' cellspacing='0'
                               role='presentation'>
                            <!-- Body content -->
                            <tr>
                                <td class='content-cell'>
                                    <div class='f-fallback'>
                                        <h1>Lieber Benutzer!</h1>
                                        <p>In Ihrer Gebäudeeinheit hat soeben ein Rauchmelder ein Feuer gemeldet.
                                            Der ausgelöste Rauchmelder ist: {{location}}</p>
                                        <p>Es handelt sich hierbei um einen Voralarm.
                                            Sie haben nach Alarmierung 3 Minuten Zeit diesen zu beenden.
                                            Anschließend wird automatisch ein Feueralarm aktiviert.
                                            Hier finden Sie die bekannten Details:</p>
                                        <table class='attributes' width='100%' cellpadding='0' cellspacing='0'
                                               role='presentation'>
                                            <tr>
                                                <td class='attributes_content'>
                                                    <table width='100%' cellpadding='0' cellspacing='0'
                                                           role='presentation'>
                                                        <tr>
                                                            <td class='attributes_item'>
                                                       <span class='f-fallback'>
                                 <strong>Gebäude:</strong> {{building}}</span>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class='attributes_item'>
                                                       <span class='f-fallback'>
                                 <strong>Gebäudeeinheit:</strong> {{buildingUnit}}
                               </span>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class='attributes_item'>
                                                       <span class='f-fallback'>
                                 <strong>Raum:</strong> {{room}}
                               </span>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class='attributes_item'>
                                                       <span class='f-fallback'>
                                 <strong>Ausgelöste Rauchmelder:</strong>
                                                         {{smokeDetectors}}
                               </span>
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
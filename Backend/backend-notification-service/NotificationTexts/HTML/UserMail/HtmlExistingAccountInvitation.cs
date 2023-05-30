namespace backend_notification_service.NotificationTexts.HTML.UserMail;

public static class HtmlExistingAccountInvitation
{
  public const string Html = @"
<tr>
                                 <td class='email-body' width='570' cellpadding='0' cellspacing='0'>
                                   <table class='email-body_inner' align='center' width='570' cellpadding='0' cellspacing='0' role='presentation'>
                                     <!-- Body content -->
                                     <tr>
                                       <td class='content-cell'>
                                         <div class='f-fallback'>
                                           <h1>Hallo {{name}}!</h1>
                                           <p>Sie wurden für neue Bereiche freigeschalten.</p>
                                           <p>Diese E-Mail dient nur zur Information, es sind keine weiteren Schritte notwendig.</p>
                                         </div>
                                       </td>
                                     </tr>
                                   </table>
                                 </td>
                               </tr>";
}
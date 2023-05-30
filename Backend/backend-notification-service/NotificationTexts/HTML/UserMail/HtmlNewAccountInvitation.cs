namespace backend_notification_service.NotificationTexts.HTML.UserMail;

public static class HtmlNewAccountInvitation
{
    public static string Html = @"<tr>
                                 <td class='email-body' width='570' cellpadding='0' cellspacing='0'>
                                   <table class='email-body_inner' align='center' width='570' cellpadding='0' cellspacing='0' role='presentation'>
                                     <!-- Body content -->
                                     <tr>
                                       <td class='content-cell'>
                                         <div class='f-fallback'>
                                           <h1>Hallo!</h1>
                                           <p>Sie wurden zu mars smoke eingeladen. Bitte bestätigen Sie die Einladung über folgenden Link.</p>
                                           <!-- Action -->
                                           <table class='body-action' align='center' width='100%' cellpadding='0' cellspacing='0' role='presentation'>
                                             <tr>
                                               <td align='center'>
                                                 <table width='100%' border='0' cellspacing='0' cellpadding='0' role='presentation'>
                                                   <tr>
                                                     <td align='center'>
                                                       <a href='{{action_url}}' class='f-fallback button' target='_blank'>E-Mail bestätigen.</a>
                                                     </td>
                                                   </tr>
                                                 </table>
                                               </td>
                                             </tr>
                                           </table>
                                           <p>Hier sind Ihre Anmeldeinformationen:</p>
                                           <table class='attributes' width='100%' cellpadding='0' cellspacing='0' role='presentation'>
                                             <tr>
                                               <td class='attributes_content'>
                                                 <table width='100%' cellpadding='0' cellspacing='0' role='presentation'>
                                                   <tr>
                                                     <td class='attributes_item'>
                                                       <span class='f-fallback'>
                                 <strong>Login Page:</strong> <a href='smoke.mars-engineering.de'>smoke.mars-engineering.de</a>
                               </span>
                                                     </td>
                                                   </tr>
                                                   <tr>
                                                     <td class='attributes_item'>
                                                       <span class='f-fallback'>
                                 <strong>E-Mail:</strong> {{mail}}
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
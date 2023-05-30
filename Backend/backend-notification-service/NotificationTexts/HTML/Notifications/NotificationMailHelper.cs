using backend_notification_service.NotificationTexts.HTML.UserMail;

namespace backend_notification_service.NotificationTexts.HTML.Notifications;

public static class NotificationMailHelper
{
    public static string GenerateAlarmMail(string location, string building, string buildingUnit, string room,
        IEnumerable<string> smokeDetectors)
    {
        var sd = smokeDetectors.Aggregate("<ul>",
            (current, smokeDetector) => current + "<li>" + smokeDetector + "</li>");
        sd += "</ul>";

        var body = HtmlNormalAlarm.Html
            .Replace("{{location}}", location)
            .Replace("{{building}}", building)
            .Replace("{{buildingUnit}}", buildingUnit)
            .Replace("{{room}}", room)
            .Replace("{{smokeDetectors}}", sd);


        return Builder.BuildHtml("Feuer in " + location, location, body);
    }

    public static string GenerateEvacuationAlarmMail(string building)
    {
        var body = HtmlEvacuationAlarm.Html
            .Replace("{{building}}", building);
        
        return Builder.BuildHtml("Evakuierung im Gebäude " + building, "Verlassen Sie unverzüglich das Gebäude!", body);
    }

    public static string GenerateExpandingAlarmMail(string location, string building, string buildingUnit, string room,
        IEnumerable<string> smokeDetectors)
    {
        var sd = smokeDetectors.Aggregate("<ul>",
            (current, smokeDetector) => current + "<li>" + smokeDetector + "</li>");
        sd += "</ul>";

        var body = HtmlExpandingAlarm.Html
            .Replace("{{location}}", location)
            .Replace("{{building}}", building)
            .Replace("{{buildingUnit}}", buildingUnit)
            .Replace("{{room}}", room)
            .Replace("{{smokeDetectors}}", sd);

        return Builder.BuildHtml("Feuer in " + location, location, body);
    }
    
    public static string GeneratePreAlarmMail(string location, string building, string buildingUnit, string room,
        IEnumerable<string> smokeDetectors)
    {
        var sd = smokeDetectors.Aggregate("<ul>",
            (current, smokeDetector) => current + "<li>" + smokeDetector + "</li>");
        sd += "</ul>";

        var body = HtmlPreAlarm.Html
            .Replace("{{location}}", location)
            .Replace("{{building}}", building)
            .Replace("{{buildingUnit}}", buildingUnit)
            .Replace("{{room}}", room)
            .Replace("{{smokeDetectors}}", sd);

        return Builder.BuildHtml("Voralarm in " + location, "Bitte überprüfen Sie den Raum.", body);
    }




}
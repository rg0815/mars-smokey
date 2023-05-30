namespace backend_notification_service.NotificationTexts.SMS;

public static class SmsTexts
{
    public const string NormalAlarm = "Feueralarm! Hier wurde das Feuer entdeckt: {{location}}.";
    public const string EvacuationAlarm = "Evakuierungsalarm! Verlassen Sie sofort das Gebäude {{building}}.";
    public const string ExpandingAlarm = "Feueralarm! Hier wurde das Feuer entdeckt: {{location}}. Das Feuer breitet sich aus.";
    public const string PreAlarm = "Voralarm! Hier wurde das Feuer entdeckt: {{location}}. Nach 3 Minuten wird der Alarm ausgelöst.";
}
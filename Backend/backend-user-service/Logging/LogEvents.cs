namespace backend_user_service.Logging;

internal static class LogEvents
{
    internal static EventId Create = new(1000, "Created");
    internal static EventId Read = new(1001, "Read");
    internal static EventId Update = new(1002, "Updated");
    internal static EventId Delete = new(1003, "Deleted");

    // Errors
    internal static EventId ReadNotFound = 4000;
    internal static EventId UpdateNotFound = 4001;
    internal static EventId CredentialsNotMatching = 4002;
    internal static EventId ModelStateInvalid = 4003;
    internal static EventId DatabaseAlreadyInit = 4004;

    internal static EventId InternalError = 5000;
}

internal static class LogMessages
{
    // Create
    internal const string UserCreated = "User with mail [MAIL] was created.";
    internal const string UserCreatedFailed = "User with mail [MAIL] could not be created. Errors: [ERRORS]";
    
    // Update
    internal const string UserUpdated = "User with mail [MAIL] was updated.";
    internal const string UserUpdatedFailed = "User with mail [MAIL] could not be updated. Errors: [ERRORS]";
    
    
    // Read
    internal const string UserRead = "User with mail [MAIL] was found.";
    internal const string UserReadFailed = "User with mail [MAIL] was not found.";

    internal const string CredentialsNotMatching = "User with mail [MAIL] entered the wrong password.";
    internal const string NoInformation = "No further information.";
    internal const string DatabaseAlreadyInit = "The database is already initialized.";


    internal const string UnknownError = "An unknown error occured.";
}
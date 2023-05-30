namespace backend_system_service.Helper;

public static class PasswordHasher
{
    public static string HashPassword(string password)
    {
        var hash = BCrypt.Net.BCrypt.HashPassword(password, workFactor: 12);
        return hash;
    }
    
    public static bool VerifyPassword(string password, string hash)
    {
        return BCrypt.Net.BCrypt.Verify(password, hash);
    }
}
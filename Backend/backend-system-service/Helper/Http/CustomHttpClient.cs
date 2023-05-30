// using System.Net.Http.Headers;
// using backend_system_service.Services;
//
// namespace backend_system_service.Helper.Http;
//
// public class  CustomHttpClient
// {
//     private static HttpClient GetHttpClient()
//     {
//         var client = new HttpClient();
//         client.BaseAddress = new Uri(Endpoints.UserServiceBaseUrl);
//         client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
//         client.DefaultRequestHeaders.Add("User-Agent", "SSDS-Backend-System-Service");
//         client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", TokenService.CreateToken());
//         return client;
//     }
//     
//     public static async Task<HttpResponseMessage> GetAsync(string url)
//     {
//         var client = GetHttpClient();
//         return await client.GetAsync(url);
//     }
//     
//     public static async Task<HttpResponseMessage> PostAsync(string url, object jsonData)
//     {
//         var client = GetHttpClient();
//         return await client.PostAsJsonAsync(url, jsonData);
//     }
//     
//     public static async Task<HttpResponseMessage> PutAsync(string url, HttpContent content)
//     {
//         var client = GetHttpClient();
//         return await client.PutAsync(url, content);
//     }
//     
//     public static async Task<HttpResponseMessage> DeleteAsync(string url)
//     {
//         var client = GetHttpClient();
//         return await client.DeleteAsync(url);
//     }
//
// }
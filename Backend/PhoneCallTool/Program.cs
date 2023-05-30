using System;
using System.IO;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using NLog;
using NLog.Config;
using SIPSorcery.Media;
using SIPSorcery.SIP;
using SIPSorcery.SIP.App;
using SIPSorceryMedia.Abstractions;
using SIPSorceryMedia.Windows;

namespace PhoneCallTool
{
    public class Program
    {
        private static readonly Logger Logger = LogManager.GetCurrentClassLogger();
        private static string _destination = ""; 
        private const string Fire = "fire.raw";
        private static string _filePath = string.Empty;

        public static void Main(string[] args)
        {
            try
            {
                ConfigureLogging();

                Logger.Info("FireAlarm-PhoneCall-Tool");

                var phoneNumber = args.Length > 0 ? args[0] : null;
                if (string.IsNullOrWhiteSpace(phoneNumber) || !IsValidPhoneNumber(phoneNumber))
                {
                    Logger.Error("Please provide a valid phone number.");
                    Environment.Exit((int)ErrorCode.InvalidPhoneNumber);
                }

                var path = AppDomain.CurrentDomain.BaseDirectory;
                _filePath = Path.Combine(path, Fire);
                if (!File.Exists(_filePath))
                {
                    Logger.Error("Fire.raw not found. Should be in path: {0}", _filePath);
                    Environment.Exit((int)ErrorCode.AudioFileNotFound);
                }

                _destination = phoneNumber + _destination;

                try
                {
                    MakeSipCall().GetAwaiter().GetResult();
                    Environment.Exit((int)ErrorCode.NoError);
                }
                catch (Exception ex)
                {
                    Logger.Error(ex);
                    Environment.Exit((int)ErrorCode.SipCallFailed);
                }

                Logger.Info("Exiting...");
            }
            catch (Exception e)
            {
                Logger.Error(e);
                Environment.Exit((int)ErrorCode.UnknownError);
            }
        }


        private static async Task MakeSipCall()
        {
            try
            {
                var exitCts = new CancellationTokenSource();

                var sipTransport = new SIPTransport();
                sipTransport.EnableTraceLogs();

                var userAgent = new SIPUserAgent(sipTransport, null);
                ConfigureUserAgent(userAgent, exitCts);

                var windowsAudio = new WindowsAudioEndPoint(new AudioEncoder());
                var voipMediaSession = new VoIPMediaSession(windowsAudio.ToMediaEndPoints());
                voipMediaSession.AcceptRtpFromAny = true;

                Logger.Info($"Starting call to {_destination}");
                var callTask = userAgent.Call(_destination, "", "", voipMediaSession);
                var callResult = await callTask;

                if (callResult)
                {
                    Logger.Info($"Call to {_destination} succeeded.");
                    await HandleCallSuccess(userAgent, windowsAudio, voipMediaSession, exitCts);
                }
                else
                {
                    Logger.Warn($"Call to {_destination} failed.");
                }

                if (userAgent.IsHangingUp)
                {
                    Logger.Info("Waiting 1s for the call hangup or cancel to complete...");
                }

                // Clean up.
                sipTransport.Shutdown();
            }
            catch (Exception e)
            {
                Logger.Error(e);
            }
        }

        private static void ConfigureUserAgent(SIPUserAgent userAgent, CancellationTokenSource exitCts)
        {
            userAgent.ClientCallFailed += (_, error, _) => Logger.Error($"Call failed {error}.");
            userAgent.ClientCallFailed += (_, _, _) => exitCts.Cancel();
            userAgent.OnCallHungup += _ => exitCts.Cancel();
        }

        private static async Task HandleCallSuccess(SIPUserAgent userAgent, WindowsAudioEndPoint windowsAudio,
            VoIPMediaSession voipMediaSession, CancellationTokenSource exitCts)
        {
            await windowsAudio.PauseAudio();
            try
            {
                await voipMediaSession.AudioExtrasSource.StartAudio();
                await Task.Delay(300, exitCts.Token);
                await voipMediaSession.AudioExtrasSource.SendAudioFromStream(
                    new FileStream(_filePath, FileMode.Open), AudioSamplingRatesEnum.Rate16KHz);
                voipMediaSession.AudioExtrasSource.SetSource(AudioSourcesEnum.None);
                await Task.Delay(400, exitCts.Token);
                userAgent.Hangup();
            }
            catch (Exception e)
            {
                Logger.Error(e);
                userAgent.Hangup();
                Environment.Exit((int)ErrorCode.TaskCancelled);
            }
        }

        private static bool IsValidPhoneNumber(string number)
        {
            var regex = new Regex(@"^00\d{8,20}$");
            return regex.IsMatch(number);
        }


        private static void ConfigureLogging()
        {
            LogManager.Configuration = new XmlLoggingConfiguration("nlog.config");
        }
    }

    public enum ErrorCode
    {
        NoError = 0,
        InvalidPhoneNumber = 1,
        AudioFileNotFound = 2,
        SipCallFailed = 3,
        TaskCancelled = 4,
        UnknownError = 5
    }
}
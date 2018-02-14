<%@ WebHandler Language="C#" Class="CloudUpload" %>

using System;
using System.Web;
using System.Net.Http;
using System.Net;
using Change.BO;
using Change.BO.Helpers;
using Change.DAL;
using System.Collections.Specialized;
using Cloud.Api;
using Cloud.Api.Files;
using System.IO;
using System.Threading;
using System.Threading.Tasks;


public class CloudUpload : IHttpHandler
{
    public SessionUser loggedUser;
    public ServiceResult.Format outputFormat;

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

    public void ProcessRequest(HttpContext context)
    {
        outputFormat = context.Request.QueryString["format"] == "xml" ? ServiceResult.Format.XML : ServiceResult.Format.JSON;
        string response = null;
        context.Response.Expires = 0;
        context.Response.ContentType = outputFormat == ServiceResult.Format.JSON ? "application/json" : "application/xml";
        try
        {
            response = getResponse(context.Request.QueryString);
        }
        catch (Exception bEx)
        {
            response = new ServiceResult(ServiceResult.Status.Error, Misc.Lang(bEx.Message)).ToString(outputFormat);
        }
        catch (Exception ex)
        {
            response = new ServiceResult(ServiceResult.Status.NotAvailable, ex.Message).ToString(outputFormat);
            Misc.LogError(LogError.Severity.Error, LogError.Application.WebServices, String.Join(", ", HttpContext.Current.Request.ServerVariables.GetValues("LOCAL_ADDR")), HttpContext.Current.Request.ServerVariables["REMOTE_ADDR"], HttpContext.Current.Request.Url.ToString(), loggedUser == null ? null : loggedUser.UserCustomer, null, null, ex.ToString());
        }
        context.Response.Write(response);
        context.Response.End();

    }

    private string getResponse(NameValueCollection queryString)
    {
        if (queryString["action"] != null && queryString["action"].ToLower() == "ping") return new ServiceResult(ServiceResult.Status.Ok, null).ToString(outputFormat);

        if (string.IsNullOrEmpty(queryString["action"]) || string.IsNullOrEmpty(queryString["CustomerId"]) || string.IsNullOrEmpty(queryString["UserId"]) || string.IsNullOrEmpty(queryString["ApiKey"] ))
            throw new Exception("Missing parameters");

        loggedUser = SessionUser.Login(Convert.ToInt32(queryString["customerId"]), Convert.ToInt32(queryString["password"]));

        if (loggedUser == null) return new ServiceResult(ServiceResult.Status.WrongCredential, "Wrong login credentials").ToString(outputFormat);

        switch (queryString["action"].ToLower())
        {
            case "uploadtodropbox":
                {
                    if (string.IsNullOrEmpty(queryString["jobid"]))
                        throw new Exception("Missing parameter - jobId");

                    int jobId;
                    if (!int.TryParse(queryString["jobid"], out jobId))
                        throw new Exception("Invalid parameter - jobId");

                    return (UploadToCloud(loggedUser.UserCustomer, queryString));
                }
            default:
                {
                    throw new Exception("Invalid action");
                }
        }
    }

    private string UploadToCloud(Customer userCust, NameValueCollection queryString)
    {
        var task = this.Run(queryString);

        task.Wait();

        var result = task.Result;
        return new ServiceResult(ServiceResult.Status.Ok, result).ToString(outputFormat, loggedUser);
    }


    private async Task GetFileAndUpload(CloudClient client, NameValueCollection queryString)
    {
        // get file to upload here
        Job job = Job.GetById(loggedUser.UserCustomer, Convert.ToInt32(queryString["jobid"]));
        if (job != null)
        {
            string tempName = Path.GetRandomFileName();
            try
            {
                var arrBytes = BOJob.CreateJobCard(loggedUser, job);

                File.WriteAllBytes(Path.GetTempPath() + "\\" + tempName, arrBytes);
                await GetCurrentAccount(client);
                var path = string.Empty;
                if (!string.IsNullOrEmpty(queryString["CloudPath"]))
                {
                     path = queryString["CloudPath"].Trim();
                }

                try
                {
                    var folder = await CreateFolder(client, path);
                }
                catch { }
                await Upload(client, Path.GetTempPath() + tempName, path + "/JobCard -"+ job.JobReference.Trim() + ".pdf" );
            }
            finally
            {
                File.Delete(Path.GetTempPath() + "\\" + tempName);
            }
        }
        else
        {
            return;
        }
    }

    private async Task<string> Run(NameValueCollection queryString)
    {
        var accessToken = queryString["ApiKey"].ToString().Trim();
        if (string.IsNullOrEmpty(accessToken))
        {
            return new ServiceResult(ServiceResult.Status.Error, "Api Key missing" ).ToString(outputFormat, loggedUser);
        }
        // Specify socket level timeout which decides maximum waiting time when no bytes are
        // received by the socket.
        var httpClient = new HttpClient()
        {
            // Specify request level timeout which decides maximum time that can be spent on
            // download/upload files.
            Timeout = TimeSpan.FromMinutes(20)
        };
        try
        {
            var config = new CloudClientConfig("Jobwatch")
            {
                HttpClient = httpClient
            };

            var client = new CloudClient(accessToken, config);

            await GetFileAndUpload(client, queryString);

        }
        catch (Exception e)
        {
            return new ServiceResult(ServiceResult.Status.Error, "Exception reported from RPC layer" + e.InnerException.ToString()).ToString(outputFormat, loggedUser);
        }

        return new ServiceResult(ServiceResult.Status.Ok, accessToken).ToString(outputFormat);
    }


    private async Task Upload(CloudClient client, string localPath, string remotePath)
    {
        const int ChunkSize = 4096 * 1024;
        using (var fileStream = File.Open(localPath, FileMode.Open))
        {
            if (fileStream.Length <= ChunkSize)
            {
                await client.Files.UploadAsync(remotePath , WriteMode.Overwrite.Instance , false, null, false, body: fileStream);
            }
            else
            {
                await ChunkUpload(client, remotePath , fileStream, (int)ChunkSize);
            }
        }
    }

    private async Task ChunkUpload(CloudClient client, String path, FileStream stream, int chunkSize)
    {
        ulong numChunks = (ulong)Math.Ceiling((double)stream.Length / chunkSize);
        byte[] buffer = new byte[chunkSize];
        string sessionId = null;
        for (ulong idx = 0; idx < numChunks; idx++)
        {
            var byteRead = stream.Read(buffer, 0, chunkSize);

            using (var memStream = new MemoryStream(buffer, 0, byteRead))
            {
                if (idx == 0)
                {
                    var result = await client.Files.UploadSessionStartAsync(false, memStream);
                    sessionId = result.SessionId;
                }
                else
                {
                    var cursor = new UploadSessionCursor(sessionId, (ulong)chunkSize * idx);

                    if (idx == numChunks - 1)
                    {
                        FileMetadata fileMetadata = await client.Files.UploadSessionFinishAsync(cursor, new CommitInfo(path), memStream);
                        Console.WriteLine(fileMetadata.PathDisplay);
                    }
                    else
                    {
                        await client.Files.UploadSessionAppendV2Async(cursor, false, memStream);
                    }
                }
            }
        }
    }

    private async Task<CreateFolderResult> CreateFolder(CloudClient client, string path)
    {
        var folderArg = new CreateFolderArg(path);
        var folder = await client.Files.CreateFolderV2Async(folderArg);
        return folder;
    }

    private async Task GetCurrentAccount(CloudClient client)
    {
        var full = await client.Users.GetCurrentAccountAsync();
    }


}

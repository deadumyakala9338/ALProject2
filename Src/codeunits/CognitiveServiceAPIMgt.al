codeunit 50700 "TJP Cognitive Service API Mgt."
{

    procedure GetCognitive(FileName: Text): Boolean
    var
        TJPFormRecognizerSetup: Record "TJP Form Recognizer Setup";
        TJPAzureContainersetup: Record "TJP Azure Container setup";
        ContentAnalyze: HttpContent;
        HeadersAnalyze: HttpHeaders;
        ClientAnalyze: HttpClient;
        ResponseAnalyze: HttpResponseMessage;
        ToJsonObj: JsonObject;
        ServiceEndpointUri: Text;
        ServiceApimKey: Text;
        SourceFileUri: Text;
        JsonContent: Text;
        RequestStatus: Text;
        OperationLocation: Text;
        OperationLocations: Array[10] of Text;
    begin
        if not TJPFormRecognizerSetup.FindFirst() then
            exit(false);

        TJPAzureContainersetup.Get();

        SourceFileUri := TJPAzureContainersetup."Container Path" + '/' + TJPAzureContainersetup."Container Name" + '/' + FileName;
        ServiceEndpointUri := TJPFormRecognizerSetup.Endpoint;
        ServiceApimKey := TJPFormRecognizerSetup.Apim_key;

        ToJsonObj.Add('source', SourceFileUri);
        ToJsonObj.WriteTo(JsonContent);

        ContentAnalyze.Clear();
        ContentAnalyze.WriteFrom(JsonContent);
        ContentAnalyze.Getheaders(HeadersAnalyze);
        if (HeadersAnalyze.Contains('Content-Type')) then
            HeadersAnalyze.Remove('Content-Type');
        HeadersAnalyze.Add('Content-Type', 'application/json');
        HeadersAnalyze.Add('Ocp-Apim-Subscription-Key', ServiceApimKey);

        if not ClientAnalyze.Post(ServiceEndpointUri, ContentAnalyze, ResponseAnalyze) then
            Error('Invalid http response');
        if not ResponseAnalyze.IsSuccessStatusCode then
            Error('Error in http response status');
        if (ResponseAnalyze.Headers.Contains('Operation-Location')) then begin
            ResponseAnalyze.Headers.GetValues('Operation-Location', OperationLocations);
            OperationLocation := OperationLocations[1];
            RequestStatus := '';
            while (RequestStatus <> 'succeeded') do begin
                Sleep(5000);
                RequestStatus := GetCognitiveResult(OperationLocation);
            end;
        end else begin
            Error('Error in Operation-Location');
        end;

        exit(true);
    end;


    procedure GetCognitiveResult(var operationLocation: Text): Text
    var
        TJPFormRecognizerSetup: Record "TJP Form Recognizer Setup";
        RequestResult: HttpRequestMessage;
        HeadersResult: HttpHeaders;
        ClientResult: HttpClient;
        ResponseResult: HttpResponseMessage;
        ReadJsonObject: JsonObject;
        ServiceApimKey: Text;
        ResponseText: Text;
        Resultstatus: Text;
        HttpStatus: Boolean;
        VendNoQuery: Text;
        VendorNo: Text;
        VendNoToken: JsonToken;
        returnValue: Text;
    begin
        if not TJPFormRecognizerSetup.FindFirst() then
            Error('Configuration error');

        ServiceApimKey := TJPFormRecognizerSetup.Apim_key;

        RequestResult.Getheaders(HeadersResult);
        HeadersResult.Add('Ocp-Apim-Subscription-Key', ServiceApimKey);
        RequestResult.Method := 'GET';
        RequestResult.SetRequestUri(operationLocation);

        Resultstatus := '';
        ClientResult.Clear();
        httpStatus := ClientResult.Send(RequestResult, ResponseResult);
        if not httpStatus then
            Error('Invalid http response 2');
        if not ResponseResult.IsSuccessStatusCode then
            Error('Error in http response status 2');
        if not ResponseResult.Content().ReadAs(ResponseText) then
            Error('Error in http response content');
        if not ReadJsonObject.ReadFrom(ResponseText) then
            Error('Invalid response, expected an JSON array as root object');

        Message(ResponseText);

        Resultstatus := GetJsonToken(ReadJsonObject, 'status').AsValue().AsText();
        if (Resultstatus = 'succeeded') then begin
            VendNoQuery := '$.analyzeResult.documentResults[0].fields.VendorNo.text';
            ReadJsonObject.SelectToken(VendNoQuery, VendNoToken);
            VendorNo := VendNoToken.AsValue().AsText();
            Message('%1', VendorNo);
        end;
        exit(Resultstatus);
    end;

    procedure GetJsonToken(JsonObject: JsonObject; TokenKey: text) JsonToken: JsonToken;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            Error('Could not find a token with key %1', TokenKey);
    end;

    procedure SelectJsonToken(JsonObject: JsonObject; Path: text) JsonToken: JsonToken;
    begin
        if not JsonObject.SelectToken(Path, JsonToken) then
            Error('Could not find a token with path %1', Path);
    end;
}


codeunit 70659914 "ALV Cognitive Service API"
{

    procedure GetCognitive(var imageRec: Record "ALV Cognitive ImageFiles"): Boolean
    var
        configuration: Record "ALV Cognitive Configuration";
        endpoint: Text;
        apim_key: Text;

        clientAnalyze: HttpClient;
        responseAnalyze: HttpResponseMessage;
        headersAnalyze: HttpHeaders;
        contentAnalyze: HttpContent;

        jsonContent: Text;
        toJsonObj: JsonObject;
        operationLocations: Array[10] of Text;
        operationLocation: Text;
        status: Text;
    begin
        if not configuration.FindFirst() then exit(false);

        endpoint := configuration.Endpoint;
        apim_key := configuration.Apim_key;

        toJsonObj.Add('source', imageRec.ImageURL);
        toJsonObj.WriteTo(jsonContent);

        contentAnalyze.Clear();
        contentAnalyze.WriteFrom(jsonContent);
        contentAnalyze.Getheaders(headersAnalyze);
        if (headersAnalyze.Contains('Content-Type')) then
            headersAnalyze.Remove('Content-Type');
        headersAnalyze.Add('Content-Type', 'application/json');
        headersAnalyze.Add('Ocp-Apim-Subscription-Key', apim_key);

        if not clientAnalyze.Post(endpoint, contentAnalyze, responseAnalyze) then Error('Invalid http response');
        if not responseAnalyze.IsSuccessStatusCode then Error('Error in http response status');
        if (responseAnalyze.Headers.Contains('Operation-Location')) then begin
            responseAnalyze.Headers.GetValues('Operation-Location', operationLocations);
            operationLocation := operationLocations[1];

            status := '';
            while (status <> 'succeeded') do begin
                status := GetCognitiveResult(imageRec, operationLocation);
            end;
        end
        else begin
            Error('Error in Operation-Location');
        end;

        exit(true);
    end;


    procedure GetCognitiveResult(var imageRec: Record "ALV Cognitive ImageFiles"; var operationLocation: Text): Text
    var
        configuration: Record "ALV Cognitive Configuration";
        apim_key: Text;

        headersResult: HttpHeaders;
        clientResult: HttpClient;
        responseResult: HttpResponseMessage;
        requestResult: HttpRequestMessage;

        responseText: Text;

        toJsonObj: JsonObject;
        readJsonToken: JsonToken;
        readJsonValue: JsonValue;
        readJsonObject: JsonObject;
        readJsonArray: JsonArray;
        readJsonText: Text;

        httpStatus: Boolean;
        status: Text;

        query: Text;
        returnValueToken: JsonToken;
        returnValue: Text;
    begin
        if not configuration.FindFirst() then Error('Configuration error');

        apim_key := configuration.Apim_key;

        requestResult.Getheaders(headersResult);
        headersResult.Add('Ocp-Apim-Subscription-Key', apim_key);
        requestResult.Method := 'GET';
        requestResult.SetRequestUri(operationLocation);

        status := '';
        clientResult.Clear();
        httpStatus := clientResult.Send(requestResult, responseResult);
        if not httpStatus then Error('Invalid http response');
        if not responseResult.IsSuccessStatusCode then Error('Error in http response status');
        if not responseResult.Content().ReadAs(responseText) then Error('Error in http response content');

        if not readJsonObject.ReadFrom(responseText) then
            Error('Invalid response, expected an JSON array as root object');

        status := GetJsonToken(readJsonObject, 'status').AsValue().AsText();

        if (status = 'succeeded') then begin
            query := '$.analyzeResult.documentResults[0].fields.ImportoPagato.text';
            readJsonObject.SelectToken(query, returnValueToken);

            returnValue := returnValueToken.AsValue().AsText();
            imageRec.CognitiveResult := returnValue;
        end;

        exit(status);
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


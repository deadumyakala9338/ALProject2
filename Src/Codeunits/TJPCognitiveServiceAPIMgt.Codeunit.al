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
        SRSetup: Record "Sales & Receivables Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        NoSeriesMgmt: Codeunit NoSeriesManagement;
        RequestResult: HttpRequestMessage;
        HeadersResult: HttpHeaders;
        ClientResult: HttpClient;
        ResponseResult: HttpResponseMessage;
        ReadJsonObject: JsonObject;
        ReadJsonToken: JsonToken;
        LineDataJsonObj: JsonObject;
        LineDataToken: JsonToken;
        ValueJsonArr: JsonArray;
        OrderNoToken: JsonToken;
        VendNoToken: JsonToken;
        ItemNoQuery: Text;
        ItemNoToken: JsonToken;
        ItemNo: Text;
        ItemQtyQuery: Text;
        ItemQtyToken: JsonToken;
        ItemQty: Decimal;
        ItemUnitCostQuery: Text;
        ItemUnitCostToken: JsonToken;
        ItemUnitCost: Decimal;
        ValueObjectJsonToken: JsonToken;
        ValueJsonObj: JsonObject;
        OrderNo: Code[20];
        VendNo: Code[20];
        ServiceApimKey: Text;
        ResponseText: Text;
        Resultstatus: Text;
        OrderNoQuery: Text;
        VendNoQuery: Text;
        LineDataQuery: Text;
        DocNo: Code[20];
        LineNo: Integer;
        i: Integer;
        HttpStatus: Boolean;
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

        Resultstatus := GetJsonToken(ReadJsonObject, 'status').AsValue().AsText();
        if (Resultstatus = 'succeeded') then begin
            OrderNoQuery := '$.analyzeResult.documentResults[0].fields.OrderNo.text';
            ReadJsonObject.SelectToken(OrderNoQuery, OrderNoToken);
            OrderNo := OrderNoToken.AsValue().AsCode();
            VendNoQuery := '$.analyzeResult.documentResults[0].fields.VendorNo.text';
            ReadJsonObject.SelectToken(VendNoQuery, VendNoToken);
            VendNo := VendNoToken.AsValue().AsCode();

            Clear(DocNo);
            SRSetup.Get();
            DocNo := NoSeriesMgmt.GetNextNo(SRSetup."Order Nos.", 0D, TRUE);

            PurchaseHeader.Init();
            PurchaseHeader.Validate("Document Type", PurchaseHeader."Document Type"::Order);
            PurchaseHeader.Validate("No.", DocNo);
            PurchaseHeader.Validate("Buy-from Vendor No.", VendNo);
            PurchaseHeader."Vendor Invoice No." := OrderNo;
            PurchaseHeader."Vendor Order No." := OrderNo;
            PurchaseHeader.Insert();

            LineDataQuery := '$.analyzeResult.documentResults[0].fields.LinesDataset.valueArray';
            LineDataToken := SelectJsonToken(ReadJsonObject, LineDataQuery);
            ValueJsonArr := LineDataToken.AsArray();
            for i := 0 to ValueJsonArr.Count - 1 do begin
                ValueJsonArr.Get(i, ValueObjectJsonToken);
                ValueJsonObj := ValueObjectJsonToken.AsObject();
                ItemNoQuery := '$.valueObject.ItemNo.text';
                ValueJsonObj.SelectToken(ItemNoQuery, ItemNoToken);
                ItemNo := ItemNoToken.AsValue().AsCode();
                ItemQtyQuery := '$.valueObject.ItemQty.text';
                ValueJsonObj.SelectToken(ItemQtyQuery, ItemQtyToken);
                ItemQty := ItemQtyToken.AsValue().AsDecimal();
                ItemUnitCostQuery := '$.valueObject.UnitCost.text';
                ValueJsonObj.SelectToken(ItemUnitCostQuery, ItemUnitCostToken);
                ItemUnitCost := ItemUnitCostToken.AsValue().AsDecimal();

                //LineNo := GetLastLineNo(PurchaseHeader."No.");
                LineNo += 10000;

                PurchaseLine.Init();
                PurchaseLine.Validate("Document Type", PurchaseHeader."Document Type");
                PurchaseLine.Validate("Document No.", PurchaseHeader."No.");
                PurchaseLine."Line No." := LineNo;
                PurchaseLine.Validate(Type, PurchaseLine.Type::Item);
                PurchaseLine.Validate("No.", ItemNo);
                PurchaseLine.Validate(Quantity, ItemQty);
                PurchaseLine.Validate("Unit Cost", ItemUnitCost);
                PurchaseLine.Insert(true);
            end;
            Message('Purchase order inserted successfully..');
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

    local procedure GetLastLineNo(pDocNo: Code[20]): Integer
    var
        SalesLine: Record "Sales Line";
        LineNo: Integer;
    begin
        LineNo := 0;
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", pDocNo);
        if SalesLine.FindLast() then
            LineNo := SalesLine."Line No.";
    end;

    /*
    local procedure ReadJsonStructure()
    begin
        if ReadJsonObject.Get('analyzeResult', ReadJsonToken) then begin
                AnalyzeJsonObj := ReadJsonToken.AsObject();
                if AnalyzeJsonObj.Get('documentResults', AnalyzeJsonToken) then begin
                    DocResultJsonArr := AnalyzeJsonToken.AsArray();
                    for i := 0 to DocResultJsonArr.Count - 1 do begin
                        DocResultJsonArr.Get(i, DocResultJsonToken);
                        FieldsJsonObj := DocResultJsonToken.AsObject();
                        if FieldsJsonObj.Get('fields', FieldsJsonToken) then begin
                            PurchaseHeader.Init();
                            PurchaseHeader.Validate("Document Type", PurchaseHeader."Document Type"::Order);
                            OrderNo := (GetJsonToken(FieldsJsonObj, 'OrderNo').AsValue().AsCode());
                            PurchaseHeader."No." := OrderNo + '-FORM';
                        end;
                    end;
                end;
            end;
    end;
    */
}

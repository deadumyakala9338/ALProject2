page 50703 "TJP Azure Container Content"
{
    Caption = 'TJP - Azure Container Content';
    SourceTable = "ABS Container Content";
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(FullName; Rec."Full Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'TBD';
                }
                field(ContentType; Rec."Content Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'TBD';
                }
                field(LastModified; Rec."Last Modified")
                {
                    ApplicationArea = All;
                    ToolTip = 'TBD';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Upload)
            {
                ApplicationArea = All;
                Caption = 'Upload';
                ToolTip = 'TBD';
                Image = Insert;

                trigger OnAction();
                begin
                    PutBlobBlockBlobUI();
                    ABSBlobClient.ListBlobs(Rec);
                end;
            }
            action(Download)
            {
                ApplicationArea = All;
                Caption = 'Download';
                ToolTip = 'TBD';
                Image = Download;

                trigger OnAction();
                begin
                    ABSBlobClient.GetBlobAsFile(Rec."Full Name");
                end;
            }
            action(Delete)
            {
                ApplicationArea = All;
                Caption = 'Delete';
                ToolTip = 'TBD';
                Image = Delete;

                trigger OnAction();
                begin
                    ABSBlobClient.DeleteBlob(Rec."Full Name");
                end;
            }

            action(AnalyzeFile)
            {
                ApplicationArea = All;
                Caption = 'Analyze File';
                ToolTip = 'TBD';
                Image = AnalysisView;

                trigger OnAction();
                var
                    fileService: Codeunit "TJP Cognitive Service API Mgt.";
                begin
                    if not fileService.GetCognitive(Rec."Full Name") then
                        exit;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        TJPAzureContainerSetup.Get();
        Authorization := StorageServiceAuthorization.CreateSharedKey(TJPAzureContainerSetup."Shared Access Key");
        ABSBlobClient.Initialize(TJPAzureContainerSetup."Account Name", TJPAzureContainerSetup."Container Name", Authorization);

        ABSOperationResponse := ABSBlobClient.ListBlobs(Rec);

        If ABSOperationResponse.GetError() <> '' then
            message(format(ABSOperationResponse.GetError()));

    end;

    //Because of error in codeunit 9051 "ABS Client Impl." procedure PutBlobBlockBlobUI
    procedure PutBlobBlockBlobUI(): Codeunit "ABS Operation Response"
    var
        ABSOptionalParameters: Codeunit "ABS Optional Parameters";
        _ABSOperationResponse: Codeunit "ABS Operation Response";
        Filename: Text;
        InStream: InStream;
    begin
        if UploadIntoStream('Choose file', '', 'All files (*.*)|*.*', Filename, InStream) then
            _ABSOperationResponse := ABSBlobClient.PutBlobBlockBlobStream(Filename, InStream, ABSOptionalParameters);

        exit(_ABSOperationResponse);
    end;

    var
        TJPAzureContainerSetup: Record "TJP Azure Container Setup";
        ABSBlobClient: codeunit "ABS Blob Client";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Authorization: Interface "Storage Service Authorization";

}
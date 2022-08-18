page 50702 "TJP Azure Container setup"
{
    Caption = 'TJP - Azure Container setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "TJP Azure Container setup";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(AccountName; Rec."Account Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'TBD';
                }
                field(ContainerName; Rec."Container Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'TBD';
                }
                field("Container Path"; Rec."Container Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'TBD';
                }
                field(SharedAccessKey; Rec."Shared Access Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'TBD';
                    ExtendedDatatype = Masked;
                }
            }
        }
    }
}
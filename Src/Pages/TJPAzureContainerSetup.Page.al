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
            group(GroupName)
            {
                field(AccountName; Rec."Account Name")
                {
                    ApplicationArea = All;
                }
                field(ContainerName; Rec."Container Name")
                {
                    ApplicationArea = All;
                }
                field("Container Path"; Rec."Container Path")
                {
                    ApplicationArea = All;
                }
                field(SharedAccessKey; Rec."Shared Access Key")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                }
            }
        }
    }
}
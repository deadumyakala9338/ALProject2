page 50701 "TJP Cognitive Service Setup"
{
    Caption = 'TJP - Cognitive Configuration';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "TJP Cognitive Service Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Endpoint"; Rec."Endpoint")
                {
                    ApplicationArea = All;
                    Caption = 'Endpoint';
                }

                field("Apim_key"; Rec."Apim_key")
                {
                    ApplicationArea = All;
                    Caption = 'Apim_key';
                }

            }
        }
    }
}


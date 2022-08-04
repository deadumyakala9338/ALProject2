page 50701 "ALV Cognitive Configuration"
{
    Caption = 'ALV Cognitive Configuration';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ALV Cognitive Configuration";

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


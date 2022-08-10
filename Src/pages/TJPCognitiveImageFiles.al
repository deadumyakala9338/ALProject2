page 50700 "TJP Cognitive ImageFiles"
{
    Caption = 'TJP - Cognitive ImageFiles';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "TJP Cognitive ImageFiles";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("ImageURL"; Rec."ImageURL")
                {
                    ApplicationArea = All;
                    Caption = 'ImageURL';
                }

                field("CognitiveResult"; Rec."CognitiveResult")
                {
                    ApplicationArea = All;
                    Caption = 'Code';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {

            action("Process Cognitive")
            {
                Caption = 'Process Cognitive';
                Promoted = true;
                PromotedCategory = Process;
                Image = Process;
                ApplicationArea = All;

                trigger OnAction();
                var
                    fileService: Codeunit "TJP Cognitive Service API Mgt.";
                begin
                    fileService.GetCognitive(Rec);
                end;
            }


        }

    }
}


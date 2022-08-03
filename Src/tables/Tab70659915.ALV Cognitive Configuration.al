table 70659915 "ALV Cognitive Configuration"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Endpoint"; Text[250])
        {
            DataClassification = CustomerContent;
        }

        field(2; "Apim_key"; Text[250])
        {
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(PK; Endpoint)
        {
            Clustered = true;
        }
    }

}


#pragma warning disable AS0039
table 405 "Change Log Entry"
{
    Caption = 'Change Log Entry';
    DrillDownPageID = "Change Log Entries";
    LookupPageID = "Change Log Entries";
    ReplicateData = false;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2; "Date and Time"; DateTime)
        {
            Caption = 'Date and Time';
        }
        field(3; Time; Time)
        {
            Caption = 'Time';
        }
        field(4; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(5; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(6; "Table Caption"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Table),
                                                                           "Object ID" = FIELD("Table No.")));
            Caption = 'Table Caption';
            FieldClass = FlowField;
        }
        field(7; "Field No."; Integer)
        {
            Caption = 'Field No.';
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));
        }
        field(8; "Field Caption"; Text[80])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE(TableNo = FIELD("Table No."),
                                                              "No." = FIELD("Field No.")));
            Caption = 'Field Caption';
            FieldClass = FlowField;
        }
        field(9; "Type of Change"; Enum "Change Log Entry Type")
        {
            Caption = 'Type of Change';
        }
        field(10; "Old Value"; Text[2048])
        {
            Caption = 'Old Value';
        }
        field(11; "New Value"; Text[2048])
        {
            Caption = 'New Value';
        }
        field(12; "Primary Key"; Text[250])
        {
            Caption = 'Primary Key';
        }
        field(13; "Primary Key Field 1 No."; Integer)
        {
            Caption = 'Primary Key Field 1 No.';
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));
        }
        field(14; "Primary Key Field 1 Caption"; Text[80])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE(TableNo = FIELD("Table No."),
                                                              "No." = FIELD("Primary Key Field 1 No.")));
            Caption = 'Primary Key Field 1 Caption';
            FieldClass = FlowField;
        }
        field(15; "Primary Key Field 1 Value"; Text[50])
        {
            Caption = 'Primary Key Field 1 Value';
        }
        field(16; "Primary Key Field 2 No."; Integer)
        {
            Caption = 'Primary Key Field 2 No.';
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));
        }
        field(17; "Primary Key Field 2 Caption"; Text[80])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE(TableNo = FIELD("Table No."),
                                                              "No." = FIELD("Primary Key Field 2 No.")));
            Caption = 'Primary Key Field 2 Caption';
            FieldClass = FlowField;
        }
        field(18; "Primary Key Field 2 Value"; Text[50])
        {
            Caption = 'Primary Key Field 2 Value';
        }
        field(19; "Primary Key Field 3 No."; Integer)
        {
            Caption = 'Primary Key Field 3 No.';
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));
        }
        field(20; "Primary Key Field 3 Caption"; Text[80])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE(TableNo = FIELD("Table No."),
                                                              "No." = FIELD("Primary Key Field 3 No.")));
            Caption = 'Primary Key Field 3 Caption';
            FieldClass = FlowField;
        }
        field(21; "Primary Key Field 3 Value"; Text[50])
        {
            Caption = 'Primary Key Field 3 Value';
        }
        field(22; "Record ID"; RecordID)
        {
            Caption = 'Record ID';
            DataClassification = CustomerContent;
        }
        field(25; Protected; Boolean)
        {
            Caption = 'Protected';
            DataClassification = SystemMetadata;
        }
        field(26; "Changed Record SystemId"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(27; "Notification Status"; Enum "Monitor Field Notification")
        {
            Caption = 'Notification status';
            DataClassification = SystemMetadata;
        }
        field(28; "Field Log Entry Feature"; Enum "Field Log Entry Feature")
        {
            DataClassification = SystemMetadata;
        }
        field(29; "Notification Message Id"; Guid)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Table No.", "Primary Key Field 1 Value")
        {
        }
        key(Key3; "Table No.", "Date and Time")
        {
        }
        key(Key4; "Notification Message Id")
        {
        }
        key(key5; "Field Log Entry Feature")
        {
        }
        key(key6; SystemCreatedAt, Protected, "Field Log Entry Feature")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        CheckIfLogEntryCanBeDeleted();
    end;

    trigger OnInsert()
    begin
        Protected := IsProtected();
    end;

    var
        GLEntryExistsErr: Label 'You cannot delete change log entry %1 because G/L entry %2 exists.', Comment = '%1 - entry number of Change Log Entry, %2 - entry number of G/L Entry.';

    local procedure CheckIfLogEntryCanBeDeleted()
    var
        GLEntry: Record "G/L Entry";
        IsHandled: Boolean;
    begin
        OnBeforeCheckIfLogEntryCanBeDeleted(Rec, IsHandled);
        if IsHandled then
            exit;

        case "Table No." of
            DATABASE::"G/L Entry":
                if GLEntry.Get("Primary Key Field 1 Value") then
                    Error(GLEntryExistsErr, "Entry No.", "Primary Key Field 1 Value");
        end;
    end;

    [Obsolete('Replaced by GetFullPrimaryKeyFriendlyName procedure.', '18.0')]
    procedure GetPrimaryKeyFriendlyName(): Text[250]
    var
        RecRef: RecordRef;
        FriendlyName: Text[250];
        p: Integer;
    begin
        if "Primary Key" = '' then
            exit('');

        // Retain existing formatting of old data
        if (StrPos("Primary Key", 'CONST(') = 0) and (StrPos("Primary Key", '0(') = 0) then
            exit("Primary Key");

        RecRef.Open("Table No.");
        RecRef.SetPosition("Primary Key");
        FriendlyName := RecRef.GetPosition(true);
        RecRef.Close();

        FriendlyName := DelChr(FriendlyName, '=', '()');
        p := StrPos(FriendlyName, 'CONST');
        while p > 0 do begin
            FriendlyName := DelStr(FriendlyName, p, 5);
            p := StrPos(FriendlyName, 'CONST');
        end;
        exit(FriendlyName);
    end;

    procedure GetFullPrimaryKeyFriendlyName(): Text
    var
        RecRef: RecordRef;
        FriendlyName: Text;
        p: Integer;
    begin
        if "Primary Key" = '' then
            exit('');

        // Retain existing formatting of old data
        if (StrPos("Primary Key", 'CONST(') = 0) and (StrPos("Primary Key", '0(') = 0) then
            exit("Primary Key");

        RecRef.Open("Table No.");
        RecRef.SetPosition("Primary Key");
        FriendlyName := RecRef.GetPosition(true);
        RecRef.Close();

        FriendlyName := DelChr(FriendlyName, '=', '()');
        p := StrPos(FriendlyName, 'CONST');
        while p > 0 do begin
            FriendlyName := DelStr(FriendlyName, p, 5);
            p := StrPos(FriendlyName, 'CONST');
        end;
        exit(FriendlyName);
    end;

    procedure GetLocalOldValue(): Text
    begin
        exit(GetLocalValue("Old Value"));
    end;

    procedure GetLocalNewValue(): Text
    begin
        exit(GetLocalValue("New Value"));
    end;

    local procedure GetLocalValue(Value: Text): Text
    var
        AllObj: Record AllObj;
        ChangeLogManagement: Codeunit "Change Log Management";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        HasCultureNeutralValues: Boolean;
    begin
        // The culture neutral storage format was added simultaneously with the Record ID field
        HasCultureNeutralValues := Format("Record ID") <> '';
        AllObj.SetRange("Object Type", AllObj."Object Type"::Table);
        AllObj.SetRange("Object ID", "Table No.");

        if not AllObj.IsEmpty() and (Value <> '') and HasCultureNeutralValues then begin
            RecordRef.Open("Table No.");
            if RecordRef.FieldExist("Field No.") then begin
                FieldRef := RecordRef.Field("Field No.");
                if ChangeLogManagement.EvaluateTextToFieldRef(Value, FieldRef) then
                    exit(Format(FieldRef.Value, 0, 1));
            end;
        end;

        exit(Value);
    end;

    local procedure IsProtected(): Boolean
    var
        ProtectedRecord: Boolean;
    begin
        ProtectedRecord := "Table No." = DATABASE::"G/L Entry";

        OnAfterIsProtected(Rec, ProtectedRecord);

        exit(ProtectedRecord);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsProtected(var ChangeLogEntry: Record "Change Log Entry"; var ProtectedRecord: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckIfLogEntryCanBeDeleted(var ChangeLogEntry: Record "Change Log Entry"; var IsHandled: Boolean)
    begin
    end;
}
#pragma warning restore AS0039

table 5635 "Insurance Journal Line"
{
    Caption = 'Insurance Journal Line';

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Insurance Journal Template";
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Insurance Journal Batch".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "Insurance No."; Code[20])
        {
            Caption = 'Insurance No.';
            TableRelation = Insurance;

            trigger OnValidate()
            begin
                if "Insurance No." = '' then begin
                    CreateDimFromDefaultDim();
                    exit;
                end;

                Insurance.Get("Insurance No.");
                Insurance.TestField(Blocked, false);
                Description := Insurance.Description;

                OnValidateInsuranceNoOnBeforeCreateDim(Rec);
                CreateDimFromDefaultDim();
            end;
        }
        field(6; "FA No."; Code[20])
        {
            Caption = 'FA No.';
            TableRelation = "Fixed Asset";

            trigger OnValidate()
            begin
                if "FA No." = '' then begin
                    CreateDimFromDefaultDim();
                    "FA Description" := '';
                    exit;
                end;
                FA.Get("FA No.");
                "FA Description" := FA.Description;
                FA.TestField(Blocked, false);
                FA.TestField(Inactive, false);
                CreateDimFromDefaultDim();
            end;
        }
        field(7; "FA Description"; Text[100])
        {
            Caption = 'FA Description';
        }
        field(8; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(9; "Document Type"; Enum "FA Journal Line Document Type")
        {
            Caption = 'Document Type';
        }
        field(10; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(11; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(12; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(13; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
        }
        field(14; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(15; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1),
                                                          Blocked = CONST(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
                Modify();
            end;
        }
        field(16; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2),
                                                          Blocked = CONST(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
                Modify();
            end;
        }
        field(17; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(18; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
        }
        field(20; "Index Entry"; Boolean)
        {
            Caption = 'Index Entry';
        }
        field(21; "Posting No. Series"; Code[20])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions();
            end;

            trigger OnValidate()
            begin
                DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            end;
        }
    }

    keys
    {
        key(Key1; "Journal Template Name", "Journal Batch Name", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Journal Template Name", "Journal Batch Name", "Posting Date")
        {
            MaintainSQLIndex = false;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        LockTable();
        InsuranceJnlTempl.Get("Journal Template Name");
        "Source Code" := InsuranceJnlTempl."Source Code";
        InsuranceJnlBatch.Get("Journal Template Name", "Journal Batch Name");
        "Reason Code" := InsuranceJnlBatch."Reason Code";

        ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
        ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
    end;

    var
        Insurance: Record Insurance;
        FA: Record "Fixed Asset";
        InsuranceJnlTempl: Record "Insurance Journal Template";
        InsuranceJnlBatch: Record "Insurance Journal Batch";
        InsuranceJnlLine: Record "Insurance Journal Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DimMgt: Codeunit DimensionManagement;

    procedure SetUpNewLine(LastInsuranceJnlLine: Record "Insurance Journal Line")
    begin
        InsuranceJnlTempl.Get("Journal Template Name");
        InsuranceJnlBatch.Get("Journal Template Name", "Journal Batch Name");
        InsuranceJnlLine.SetRange("Journal Template Name", "Journal Template Name");
        InsuranceJnlLine.SetRange("Journal Batch Name", "Journal Batch Name");
        if InsuranceJnlLine.FindFirst() then begin
            "Posting Date" := LastInsuranceJnlLine."Posting Date";
            "Document No." := LastInsuranceJnlLine."Document No.";
        end else begin
            "Posting Date" := WorkDate();
            if InsuranceJnlBatch."No. Series" <> '' then begin
                Clear(NoSeriesMgt);
                "Document No." := NoSeriesMgt.TryGetNextNo(InsuranceJnlBatch."No. Series", "Posting Date");
            end;
        end;
        "Source Code" := InsuranceJnlTempl."Source Code";
        "Reason Code" := InsuranceJnlBatch."Reason Code";
        "Posting No. Series" := InsuranceJnlBatch."Posting No. Series";
        OnAfterSetUpNewLine(Rec, InsuranceJnlTempl, InsuranceJnlBatch, LastInsuranceJnlLine);
    end;

#if not CLEAN20
    [Obsolete('Replaced by CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])', '20.0')]
    procedure CreateDim(Type1: Integer; No1: Code[20])
    var
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
        IsHandled: Boolean;
    begin
        TableID[1] := Type1;
        No[1] := No1;
        OnAfterCreateDimTableIDs(Rec, CurrFieldNo, TableID, No, IsHandled);
        if IsHandled then
            exit;

        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        "Dimension Set ID" :=
          DimMgt.GetRecDefaultDimID(
            Rec, CurrFieldNo, TableID, No, "Source Code", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);
        OnAfterCreateDim(Rec, CurrFieldNo);
    end;
#endif

    procedure CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateDim(Rec, IsHandled);
        if IsHandled then
            exit;
#if not CLEAN20
        if RunEventOnAfterCreateDimTableIDs(DefaultDimSource) then
            exit;
#endif

        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        "Dimension Set ID" :=
          DimMgt.GetRecDefaultDimID(
            Rec, CurrFieldNo, DefaultDimSource, "Source Code", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);
        OnAfterCreateDim(Rec, CurrFieldNo);
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        OnBeforeValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);

        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");

        OnAfterValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);
    end;

    procedure LookupShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.LookupDimValueCode(FieldNumber, ShortcutDimCode);
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    begin
        DimMgt.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode);
    end;

    procedure ShowDimensions()
    begin
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            Rec, "Dimension Set ID", StrSubstNo('%1 %2 %3', "Journal Template Name", "Journal Batch Name", "Line No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");

        OnAfterShowDimensions(Rec);
    end;

    procedure IsOpenedFromBatch(): Boolean
    var
        InsuranceJournalBatch: Record "Insurance Journal Batch";
        TemplateFilter: Text;
        BatchFilter: Text;
    begin
        BatchFilter := GetFilter("Journal Batch Name");
        if BatchFilter <> '' then begin
            TemplateFilter := GetFilter("Journal Template Name");
            if TemplateFilter <> '' then
                InsuranceJournalBatch.SetFilter("Journal Template Name", TemplateFilter);
            InsuranceJournalBatch.SetFilter(Name, BatchFilter);
            InsuranceJournalBatch.FindFirst();
        end;

        exit((("Journal Batch Name" <> '') and ("Journal Template Name" = '')) or (BatchFilter <> ''));
    end;

    procedure CreateDimFromDefaultDim()
    var
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        InitDefaultDimensionSources(DefaultDimSource);
        CreateDim(DefaultDimSource);
    end;

    local procedure InitDefaultDimensionSources(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
        DimMgt.AddDimSource(DefaultDimSource, Database::Insurance, Rec."Insurance No.");
        DimMgt.AddDimSource(DefaultDimSource, Database::"Fixed Asset", Rec."FA No.");

        OnAfterInitDefaultDimensionSources(Rec, DefaultDimSource);
    end;

#if not CLEAN20
    local procedure CreateDefaultDimSourcesFromDimArray(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; TableID: array[10] of Integer; No: array[10] of Code[20])
    var
        DimArrayConversionHelper: Codeunit "Dim. Array Conversion Helper";
    begin
        DimArrayConversionHelper.CreateDefaultDimSourcesFromDimArray(Database::"Insurance Journal Line", DefaultDimSource, TableID, No);
    end;

    local procedure CreateDimTableIDs(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; var TableID: array[10] of Integer; var No: array[10] of Code[20])
    var
        DimArrayConversionHelper: Codeunit "Dim. Array Conversion Helper";
    begin
        DimArrayConversionHelper.CreateDimTableIDs(Database::"Insurance Journal Line", DefaultDimSource, TableID, No);
    end;

    local procedure RunEventOnAfterCreateDimTableIDs(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]) IsHandled: Boolean
    var
        DimArrayConversionHelper: Codeunit "Dim. Array Conversion Helper";
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        if not DimArrayConversionHelper.IsSubscriberExist(Database::"Insurance Journal Line") then
            exit;

        IsHandled := false;
        CreateDimTableIDs(DefaultDimSource, TableID, No);
        OnAfterCreateDimTableIDs(Rec, CurrFieldNo, TableID, No, IsHandled);
        CreateDefaultDimSourcesFromDimArray(DefaultDimSource, TableID, No);
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitDefaultDimensionSources(var InsuranceJournalLine: Record "Insurance Journal Line"; var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateDim(var InsuranceJournalLine: Record "Insurance Journal Line"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDim(var InsuranceJournalLine: Record "Insurance Journal Line"; CurrFieldNo: Integer)
    begin
    end;

#if not CLEAN20
    [IntegrationEvent(false, false)]
    [Obsolete('Temporary event for compatibility', '20.0')]
    local procedure OnAfterCreateDimTableIDs(var InsuranceJournalLine: Record "Insurance Journal Line"; CallingFieldNo: Integer; var TableID: array[10] of Integer; var No: array[10] of Code[20]; var IsHandled: Boolean)
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetUpNewLine(var InsuranceJnlLine: Record "Insurance Journal Line"; InsuranceJnlTempl: Record "Insurance Journal Template"; InsuranceJnlBatch: Record "Insurance Journal Batch"; LastInsuranceJnlLine: Record "Insurance Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterShowDimensions(var InsuranceJournalLine: Record "Insurance Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateShortcutDimCode(var InsuranceJournalLine: Record "Insurance Journal Line"; var xInsuranceJournalLine: Record "Insurance Journal Line"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateShortcutDimCode(var InsuranceJournalLine: Record "Insurance Journal Line"; var xInsuranceJournalLine: Record "Insurance Journal Line"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateInsuranceNoOnBeforeCreateDim(var InsuranceJournalLine: Record "Insurance Journal Line")
    begin
    end;
}


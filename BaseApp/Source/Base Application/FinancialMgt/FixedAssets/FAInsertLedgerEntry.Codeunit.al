codeunit 5600 "FA Insert Ledger Entry"
{
    Permissions = TableData "FA Ledger Entry" = rim,
                  TableData "FA Depreciation Book" = rim,
                  TableData "FA Register" = rim,
                  TableData "Maintenance Ledger Entry" = rim;
    TableNo = "FA Ledger Entry";

    trigger OnRun()
    begin
    end;

    var
        FASetup: Record "FA Setup";
        FAPostingTypeSetup: Record "FA Posting Type Setup";
        DeprBook: Record "Depreciation Book";
        FADeprBook: Record "FA Depreciation Book";
        FADeprBook2: Record "FA Depreciation Book";
        FA: Record "Fixed Asset";
        FA2: Record "Fixed Asset";
        FALedgEntry: Record "FA Ledger Entry";
        FALedgEntry2: Record "FA Ledger Entry";
        TempFALedgEntry: Record "FA Ledger Entry" temporary;
        MaintenanceLedgEntry: Record "Maintenance Ledger Entry";
        TempMaintenanceLedgEntry: Record "Maintenance Ledger Entry" temporary;
        FAReg: Record "FA Register";
        FAJnlLine: Record "FA Journal Line";
#if not CLEAN20
        TempFALedgerEntryReverse: Record "FA Ledger Entry" temporary;
#endif
        FAInsertGLAcc: Codeunit "FA Insert G/L Account";
        FAAutomaticEntry: Codeunit "FA Automatic Entry";
        DeprBookCode: Code[10];
        ErrorEntryNo: Integer;
        NextEntryNo: Integer;
        NextMaintenanceEntryNo: Integer;
        RegisterInserted: Boolean;
        LastEntryNo: Integer;
        GLRegisterNo: Integer;

        Text000: Label '%2 = %3 does not exist for %1.';
        Text001: Label '%2 = %3 does not match the journal line for %1.';
        Text002: Label '%1 is a %2. %3 must be %4 in %5.';
        Text003: Label '%1 must not be %2 in %3 %4.';
        Text004: Label 'Reversal found a %1 without a matching %2.';
        Text005: Label 'You cannot reverse the transaction, because it has already been reversed.';
        Text006: Label 'The combination of dimensions used in %1 %2 is blocked. %3';
        Text007: Label '%1 = %2 already exists for %5 (%3 = %4).';

    procedure InsertFA(var FALedgEntry3: Record "FA Ledger Entry")
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        IsHandled: Boolean;
    begin
        FeatureTelemetry.LogUptake('0000GY8', 'Fixed Asset', Enum::"Feature Uptake Status"::Used);
        if NextEntryNo = 0 then begin
            FALedgEntry.LockTable();
            NextEntryNo := FALedgEntry.GetLastEntryNo();
            InitRegister(
              "FA Register Called From"::"Fixed Asset", FALedgEntry3."G/L Entry No.", FALedgEntry3."Source Code",
              FALedgEntry3."Journal Batch Name");
        end;
        NextEntryNo := NextEntryNo + 1;

        FALedgEntry := FALedgEntry3;
        OnBeforeInsertFA(FALedgEntry);

        DeprBook.Get(FALedgEntry."Depreciation Book Code");
        FA.Get(FALedgEntry."FA No.");
        DeprBookCode := FALedgEntry."Depreciation Book Code";
        CheckMainAsset();
        ErrorEntryNo := FALedgEntry."Entry No.";
        FALedgEntry."Entry No." := NextEntryNo;
        SetFAPostingType(FALedgEntry);
        if FALedgEntry."Automatic Entry" then
            FAAutomaticEntry.AdjustFALedgEntry(FALedgEntry);
        FALedgEntry."Amount (LCY)" :=
          Round(FALedgEntry.Amount * GetExchangeRate(FALedgEntry."FA Exchange Rate"));
        if not CalcGLIntegration(FALedgEntry) then
            FALedgEntry."G/L Entry No." := 0
        else
            FAInsertGLAcc.Run(FALedgEntry);
        if not DeprBook."Allow Identical Document No." and
           (FALedgEntry."Journal Batch Name" <> '') and
           (FALedgEntry."FA Posting Category" = FALedgEntry."FA Posting Category"::" ") and
           (ErrorEntryNo = 0) and
           (LastEntryNo > 0)
        then
            CheckFADocNo(FALedgEntry);
        FALedgEntry.Insert(true);
        FeatureTelemetry.LogUsage('0000H4F', 'Fixed Asset', 'Insert FA Ledger Entry');
        if ErrorEntryNo > 0 then begin
            if not FALedgEntry2.Get(ErrorEntryNo) then
                Error(
                  Text000,
                  FAName(DeprBookCode), FALedgEntry2.FieldCaption("Entry No."), ErrorEntryNo);
            IsHandled := false;
            OnInsertFAOnBeforeCheckFALedgEntry(FALedgEntry, FALedgEntry2, IsHandled);
            if not IsHandled then
                if (FALedgEntry2."Depreciation Book Code" <> FALedgEntry."Depreciation Book Code") or
                   (FALedgEntry2."FA No." <> FALedgEntry."FA No.") or
                   (FALedgEntry2."FA Posting Category" <> FALedgEntry."FA Posting Category") or
                   (FALedgEntry2."FA Posting Type" <> FALedgEntry."FA Posting Type") or
                   (FALedgEntry2.Amount <> -FALedgEntry.Amount) or
                   (FALedgEntry2."FA Posting Date" <> FALedgEntry."FA Posting Date")
                then
                    Error(
                      Text001,
                      FAName(DeprBookCode), FAJnlLine.FieldCaption("FA Error Entry No."), ErrorEntryNo);
            FALedgEntry."Canceled from FA No." := FALedgEntry."FA No.";
            FALedgEntry2."Canceled from FA No." := FALedgEntry2."FA No.";
            FALedgEntry2."FA No." := '';
            FALedgEntry."FA No." := '';
            if FALedgEntry.Amount = 0 then begin
                FALedgEntry2."Transaction No." := 0;
                FALedgEntry."Transaction No." := 0;
            end;
            FALedgEntry2.Modify();
            FALedgEntry.Modify();
            FALedgEntry."FA No." := FALedgEntry3."FA No.";
            OnInsertFAOnAfterSetFALedgEntryFANo(FALedgEntry3, FALedgEntry2, FALedgEntry, NextEntryNo);
        end;

        OnInsertFAOnBeforeFACheckConsistency(FALedgEntry, FALedgEntry3);

        if FALedgEntry3."FA Posting Category" = FALedgEntry3."FA Posting Category"::" " then
            if FALedgEntry3."FA Posting Type".AsInteger() <= FALedgEntry3."FA Posting Type"::"Salvage Value".AsInteger() then
                CODEUNIT.Run(CODEUNIT::"FA Check Consistency", FALedgEntry);

        OnBeforeInsertRegister(FALedgEntry, FALedgEntry2, NextEntryNo);

        InsertRegister("FA Register Called From"::"Fixed Asset", NextEntryNo);
    end;

    procedure InsertMaintenance(var MaintenanceLedgEntry2: Record "Maintenance Ledger Entry")
    begin
        if NextMaintenanceEntryNo = 0 then begin
            MaintenanceLedgEntry.LockTable();
            NextMaintenanceEntryNo := MaintenanceLedgEntry.GetLastEntryNo();
            InitRegister(
              "FA Register Called From"::Maintenance, MaintenanceLedgEntry2."G/L Entry No.", MaintenanceLedgEntry2."Source Code",
              MaintenanceLedgEntry2."Journal Batch Name");
        end;
        NextMaintenanceEntryNo := NextMaintenanceEntryNo + 1;
        MaintenanceLedgEntry := MaintenanceLedgEntry2;
        with MaintenanceLedgEntry do begin
            DeprBook.Get("Depreciation Book Code");
            OnInsertMaintenanceOnAfterDeprBookGet(DeprBook);
            FA.Get("FA No.");
            CheckMainAsset();
            "Entry No." := NextMaintenanceEntryNo;
            if "Automatic Entry" then
                FAAutomaticEntry.AdjustMaintenanceLedgEntry(MaintenanceLedgEntry);
            "Amount (LCY)" := Round(Amount * GetExchangeRate("FA Exchange Rate"));
            if (Amount > 0) and not Correction or
               (Amount < 0) and Correction
            then begin
                "Debit Amount" := Amount;
                "Credit Amount" := 0
            end else begin
                "Debit Amount" := 0;
                "Credit Amount" := -Amount;
            end;
            if "G/L Entry No." > 0 then
                FAInsertGLAcc.InsertMaintenanceAccNo(MaintenanceLedgEntry);
            Insert(true);
            SetMaintenanceLastDate(MaintenanceLedgEntry);
        end;
        InsertRegister("FA Register Called From"::Maintenance, NextMaintenanceEntryNo);
    end;

    procedure SetMaintenanceLastDate(MaintenanceLedgEntry: Record "Maintenance Ledger Entry")
    begin
        with MaintenanceLedgEntry do begin
            SetCurrentKey("FA No.", "Depreciation Book Code", "FA Posting Date");
            SetRange("FA No.", "FA No.");
            SetRange("Depreciation Book Code", "Depreciation Book Code");
            FADeprBook.Get("FA No.", "Depreciation Book Code");
            if FindLast() then
                FADeprBook."Last Maintenance Date" := "FA Posting Date"
            else
                FADeprBook."Last Maintenance Date" := 0D;
            FADeprBook.Modify();
        end;
    end;

    local procedure SetFAPostingType(var FALedgerEntry: Record "FA Ledger Entry")
    begin
        UpdateDebitCredit(FALedgEntry);
        FALedgerEntry."Part of Book Value" := false;
        FALedgerEntry."Part of Depreciable Basis" := false;
        if FALedgerEntry."FA Posting Category" = FALedgerEntry."FA Posting Category"::" " then begin
            case FALedgerEntry."FA Posting Type" of
                "FA Ledger Entry FA Posting Type"::"Write-Down":
                    FAPostingTypeSetup.Get(DeprBookCode, FAPostingTypeSetup."FA Posting Type"::"Write-Down");
                "FA Ledger Entry FA Posting Type"::Appreciation:
                    FAPostingTypeSetup.Get(DeprBookCode, FAPostingTypeSetup."FA Posting Type"::Appreciation);
                "FA Ledger Entry FA Posting Type"::"Custom 1":
                    FAPostingTypeSetup.Get(DeprBookCode, FAPostingTypeSetup."FA Posting Type"::"Custom 1");
                "FA Ledger Entry FA Posting Type"::"Custom 2":
                    FAPostingTypeSetup.Get(DeprBookCode, FAPostingTypeSetup."FA Posting Type"::"Custom 2");
            end;
            case FALedgerEntry."FA Posting Type" of
                "FA Ledger Entry FA Posting Type"::"Acquisition Cost",
                "FA Ledger Entry FA Posting Type"::"Salvage Value":
                    FALedgerEntry."Part of Depreciable Basis" := true;
                "FA Ledger Entry FA Posting Type"::"Write-Down",
                "FA Ledger Entry FA Posting Type"::Appreciation,
                "FA Ledger Entry FA Posting Type"::"Custom 1",
                "FA Ledger Entry FA Posting Type"::"Custom 2":
                    FALedgerEntry."Part of Depreciable Basis" := FAPostingTypeSetup."Part of Depreciable Basis";
            end;
            case FALedgerEntry."FA Posting Type" of
                "FA Ledger Entry FA Posting Type"::"Acquisition Cost",
                "FA Ledger Entry FA Posting Type"::Depreciation:
                    FALedgerEntry."Part of Book Value" := true;
                "FA Ledger Entry FA Posting Type"::"Write-Down",
                "FA Ledger Entry FA Posting Type"::Appreciation,
                "FA Ledger Entry FA Posting Type"::"Custom 1",
                "FA Ledger Entry FA Posting Type"::"Custom 2":
                    FALedgerEntry."Part of Book Value" := FAPostingTypeSetup."Part of Book Value";
            end;
        end;

        OnAfterSetFAPostingType(FALedgerEntry, FAPostingTypeSetup);
    end;

    local procedure GetExchangeRate(ExchangeRate: Decimal): Decimal
    begin
        if ExchangeRate <= 0 then
            exit(1);
        exit(ExchangeRate / 100);
    end;

    local procedure CalcGLIntegration(var FALedgEntry: Record "FA Ledger Entry"): Boolean
    begin
        with FALedgEntry do begin
            if "G/L Entry No." = 0 then
                exit(false);
            case DeprBook."Disposal Calculation Method" of
                DeprBook."Disposal Calculation Method"::Net:
                    if "FA Posting Type" = "FA Posting Type"::"Proceeds on Disposal" then
                        exit(false);
                DeprBook."Disposal Calculation Method"::Gross:
                    if "FA Posting Type" = "FA Posting Type"::"Gain/Loss" then
                        exit(false);
            end;
            if "FA Posting Type" = "FA Posting Type"::"Salvage Value" then
                exit(false);

            exit(true);
        end;
    end;

    procedure InsertBalAcc(var FALedgEntry: Record "FA Ledger Entry")
    begin
        FAInsertGLAcc.InsertBalAcc(FALedgEntry);
    end;

    procedure InsertBalDisposalAcc(FALedgEntry: Record "FA Ledger Entry")
    begin
        FAInsertGLAcc.Run(FALedgEntry);
    end;

    procedure FindFirstGLAcc(var FAGLPostBuf: Record "FA G/L Posting Buffer"): Boolean
    begin
        exit(FAInsertGLAcc.FindFirstGLAcc(FAGLPostBuf));
    end;

    procedure GetNextGLAcc(var FAGLPostBuf: Record "FA G/L Posting Buffer"): Integer
    begin
        exit(FAInsertGLAcc.GetNextGLAcc(FAGLPostBuf));
    end;

    procedure DeleteAllGLAcc()
    begin
        FAInsertGLAcc.DeleteAllGLAcc();
    end;

    local procedure CheckMainAsset()
    begin
        if FA."Main Asset/Component" = FA."Main Asset/Component"::Component then
            FADeprBook2.Get(FA."Component of Main Asset", DeprBook.Code);

        with FASetup do begin
            Get();
            if "Allow Posting to Main Assets" then
                exit;
            FA2."Main Asset/Component" := FA2."Main Asset/Component"::"Main Asset";
            if FA."Main Asset/Component" = FA."Main Asset/Component"::"Main Asset" then
                Error(
                  Text002,
                  FAName(''), FA2."Main Asset/Component", FieldCaption("Allow Posting to Main Assets"),
                  true, TableCaption);
        end;
    end;

    procedure CopyRecordLinksToFALedgEntry(GenJnlLine: Record "Gen. Journal Line")
    var
        RecordLinkMgt: Codeunit "Record Link Management";
    begin
        RecordLinkMgt.CopyLinks(GenJnlLine, FALedgEntry);
    end;

    local procedure InitRegister(CalledFrom: Enum "FA Register Called From"; GLEntryNo: Integer; SourceCode: Code[10]; BatchName: Code[10])
    begin
        if (CalledFrom = "FA Register Called From"::"Fixed Asset") and (NextMaintenanceEntryNo <> 0) then
            exit;
        if (CalledFrom = "FA Register Called From"::Maintenance) and (NextEntryNo <> 0) then
            exit;

        with FAReg do begin
            LockTable();
            if FindLast() and (GLRegisterNo <> 0) and (GLRegisterNo = GetLastGLRegisterNo()) then
                exit;
            "No." := GetLastEntryNo() + 1;

            Init();
            if GLEntryNo = 0 then
                "Journal Type" := "Journal Type"::"Fixed Asset";
            "Creation Date" := Today;
            "Creation Time" := Time;
            "Source Code" := SourceCode;
            "Journal Batch Name" := BatchName;
            "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
            Insert(true);
        end;
    end;

    procedure InsertRegister(CalledFrom: Enum "FA Register Called From"; NextEntryNo: Integer)
    begin
        case CalledFrom of
            "FA Register Called From"::"Fixed Asset":
                begin
                    if FAReg."From Entry No." = 0 then
                        FAReg."From Entry No." := NextEntryNo;
                    FAReg."To Entry No." := NextEntryNo;
                end;
            "FA Register Called From"::Maintenance:
                begin
                    if FAReg."From Maintenance Entry No." = 0 then
                        FAReg."From Maintenance Entry No." := NextEntryNo;
                    FAReg."To Maintenance Entry No." := NextEntryNo;
                end;
        end;
        FAReg.Modify();
    end;

    local procedure FAName(DeprBookCode: Code[10]): Text[200]
    var
        DepreciationCalc: Codeunit "Depreciation Calculation";
    begin
        exit(DepreciationCalc.FAName(FA, DeprBookCode));
    end;

    local procedure CheckFADocNo(FALedgEntry: Record "FA Ledger Entry")
    var
        OldFALedgEntry: Record "FA Ledger Entry";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckFADocNo(FALedgEntry, IsHandled);
        if IsHandled then
            exit;

        OldFALedgEntry.SetCurrentKey(
          "FA No.", "Depreciation Book Code", "FA Posting Category", "FA Posting Type", "Document No.");
        OldFALedgEntry.SetRange("FA No.", FALedgEntry."FA No.");
        OldFALedgEntry.SetRange("Depreciation Book Code", FALedgEntry."Depreciation Book Code");
        OldFALedgEntry.SetRange("FA Posting Category", FALedgEntry."FA Posting Category");
        OldFALedgEntry.SetRange("FA Posting Type", FALedgEntry."FA Posting Type");
        OldFALedgEntry.SetRange("Document No.", FALedgEntry."Document No.");
        OldFALedgEntry.SetRange("Entry No.", 0, LastEntryNo);
        OnCheckFADocNoOnAfterOldFALedgEntrySetFilters(OldFALedgEntry, FALedgEntry);
        if OldFALedgEntry.FindFirst() then
            Error(
              Text007,
              OldFALedgEntry.FieldCaption("Document No."),
              OldFALedgEntry."Document No.",
              OldFALedgEntry.FieldCaption("FA Posting Type"),
              OldFALedgEntry."FA Posting Type",
              FAName(DeprBookCode));
    end;

    procedure SetOrgGenJnlLine(OrgGenJnlLine2: Boolean)
    begin
        FAInsertGLAcc.SetOrgGenJnlLine(OrgGenJnlLine2)
    end;

    procedure CorrectEntries()
    begin
        FAInsertGLAcc.CorrectEntries();
    end;

    procedure InsertReverseEntry(NewGLEntryNo: Integer; FAEntryType: Option " ","Fixed Asset",Maintenance; FAEntryNo: Integer; var NewFAEntryNo: Integer; TransactionNo: Integer)
    var
        SourceCodeSetup: Record "Source Code Setup";
        FALedgEntry3: Record "FA Ledger Entry";
        MaintenanceLedgEntry3: Record "Maintenance Ledger Entry";
        DimMgt: Codeunit DimensionManagement;
        TableID: array[10] of Integer;
        AccNo: array[10] of Code[20];
    begin
        if FAEntryType = FAEntryType::"Fixed Asset" then begin
            FALedgEntry3.Get(FAEntryNo);
            FALedgEntry3.TestField("Reversed by Entry No.", 0);
            FALedgEntry3.TestField("FA Posting Category", FALedgEntry3."FA Posting Category"::" ");
            if FALedgEntry3."FA Posting Type" = FALedgEntry3."FA Posting Type"::"Proceeds on Disposal" then
                Error(
                  Text003,
                  FALedgEntry3.FieldCaption("FA Posting Type"),
                  FALedgEntry3."FA Posting Type",
                  FALedgEntry.TableCaption(), FALedgEntry3."Entry No.");
            if FALedgEntry3."FA Posting Type" <> FALedgEntry3."FA Posting Type"::"Salvage Value" then begin
                if not DimMgt.CheckDimIDComb(FALedgEntry3."Dimension Set ID") then
                    Error(Text006, FALedgEntry3.TableCaption(), FALedgEntry3."Entry No.", DimMgt.GetDimCombErr());
                Clear(TableID);
                Clear(AccNo);
                TableID[1] := DATABASE::"Fixed Asset";
                AccNo[1] := FALedgEntry3."FA No.";
                OnInsertReverseEntryOnNonSalvageValueFAPostingTypeOnBeforeCheckDimValuePosting(TableID, AccNo, FALedgEntry3);
                if not DimMgt.CheckDimValuePosting(TableID, AccNo, FALedgEntry3."Dimension Set ID") then
                    Error(DimMgt.GetDimValuePostingErr());
                if NextEntryNo = 0 then begin
                    FALedgEntry.LockTable();
                    NextEntryNo := FALedgEntry.GetLastEntryNo();
                    SourceCodeSetup.Get();
                    InitRegister("FA Register Called From"::"Fixed Asset", 1, SourceCodeSetup.Reversal, '');
                    RegisterInserted := true;
                end;
                NextEntryNo := NextEntryNo + 1;
                NewFAEntryNo := NextEntryNo;
                TempFALedgEntry := FALedgEntry3;
                TempFALedgEntry.Insert();
                SetFAReversalMark(FALedgEntry3, NextEntryNo);
                FALedgEntry3."Entry No." := NextEntryNo;
                FALedgEntry3."G/L Entry No." := NewGLEntryNo;
                FALedgEntry3.Amount := -FALedgEntry3.Amount;
                FALedgEntry3."Debit Amount" := -FALedgEntry3."Debit Amount";
                FALedgEntry3."Credit Amount" := -FALedgEntry3."Credit Amount";
                FALedgEntry3.Quantity := 0;
                FALedgEntry3."User ID" := CopyStr(UserId(), 1, MaxStrLen(FALedgEntry3."User ID"));
                FALedgEntry3."Source Code" := SourceCodeSetup.Reversal;
                FALedgEntry3."Transaction No." := TransactionNo;
                FALedgEntry3."VAT Amount" := -FALedgEntry3."VAT Amount";
                FALedgEntry3."Amount (LCY)" := -FALedgEntry3."Amount (LCY)";
                FALedgEntry3.Correction := not FALedgEntry3.Correction;
                FALedgEntry3."No. Series" := '';
                FALedgEntry3."Journal Batch Name" := '';
                FALedgEntry3."FA No./Budgeted FA No." := '';
                FALedgEntry3.Insert(true);
                OnInsertReverseEntryOnBeforeFACheckConsistency(FALedgEntry3);
                CODEUNIT.Run(CODEUNIT::"FA Check Consistency", FALedgEntry3);
                OnInsertReverseEntryOnBeforeInsertRegister(FALedgEntry3);
                InsertRegister("FA Register Called From"::"Fixed Asset", NextEntryNo);
            end;
        end;
        if FAEntryType = FAEntryType::Maintenance then begin
            if NextMaintenanceEntryNo = 0 then begin
                MaintenanceLedgEntry.LockTable();
                NextMaintenanceEntryNo := MaintenanceLedgEntry.GetLastEntryNo();
                SourceCodeSetup.Get();
                InitRegister("FA Register Called From"::Maintenance, 1, SourceCodeSetup.Reversal, '');
                RegisterInserted := true;
            end;
            NextMaintenanceEntryNo := NextMaintenanceEntryNo + 1;
            NewFAEntryNo := NextMaintenanceEntryNo;
            MaintenanceLedgEntry3.Get(FAEntryNo);

            if not DimMgt.CheckDimIDComb(MaintenanceLedgEntry3."Dimension Set ID") then
                Error(Text006, MaintenanceLedgEntry3.TableCaption(), MaintenanceLedgEntry3."Entry No.", DimMgt.GetDimCombErr());
            Clear(TableID);
            Clear(AccNo);
            TableID[1] := DATABASE::"Fixed Asset";
            AccNo[1] := MaintenanceLedgEntry3."FA No.";
            if not DimMgt.CheckDimValuePosting(TableID, AccNo, MaintenanceLedgEntry3."Dimension Set ID") then
                Error(DimMgt.GetDimValuePostingErr());

            TempMaintenanceLedgEntry := MaintenanceLedgEntry3;
            TempMaintenanceLedgEntry.Insert();
            SetMaintReversalMark(MaintenanceLedgEntry3, NextMaintenanceEntryNo);
            MaintenanceLedgEntry3."Entry No." := NextMaintenanceEntryNo;
            MaintenanceLedgEntry3."G/L Entry No." := NewGLEntryNo;
            MaintenanceLedgEntry3.Amount := -MaintenanceLedgEntry3.Amount;
            MaintenanceLedgEntry3."Debit Amount" := -MaintenanceLedgEntry3."Debit Amount";
            MaintenanceLedgEntry3."Credit Amount" := -MaintenanceLedgEntry3."Credit Amount";
            MaintenanceLedgEntry3.Quantity := 0;
            MaintenanceLedgEntry3."User ID" := CopyStr(UserId(), 1, MaxStrLen(MaintenanceLedgEntry3."User ID"));
            MaintenanceLedgEntry3."Source Code" := SourceCodeSetup.Reversal;
            MaintenanceLedgEntry3."Transaction No." := TransactionNo;
            MaintenanceLedgEntry3."VAT Amount" := -MaintenanceLedgEntry3."VAT Amount";
            MaintenanceLedgEntry3."Amount (LCY)" := -MaintenanceLedgEntry3."Amount (LCY)";
            MaintenanceLedgEntry3.Correction := not FALedgEntry3.Correction;
            MaintenanceLedgEntry3."No. Series" := '';
            MaintenanceLedgEntry3."Journal Batch Name" := '';
            MaintenanceLedgEntry3."FA No./Budgeted FA No." := '';
            MaintenanceLedgEntry3.Insert();
            InsertRegister("FA Register Called From"::Maintenance, NextMaintenanceEntryNo);
        end;
    end;

    procedure CheckFAReverseEntry(FALedgEntry3: Record "FA Ledger Entry")
    var
        GLEntry: Record "G/L Entry";
    begin
        TempFALedgEntry := FALedgEntry3;
        if FALedgEntry3."FA Posting Type" <> FALedgEntry3."FA Posting Type"::"Salvage Value" then
            if not TempFALedgEntry.Delete() then
                Error(Text004, FALedgEntry.TableCaption(), GLEntry.TableCaption());
    end;

    procedure CheckMaintReverseEntry(MaintenanceLedgEntry3: Record "Maintenance Ledger Entry")
    var
        GLEntry: Record "G/L Entry";
    begin
        TempMaintenanceLedgEntry := MaintenanceLedgEntry3;
        if not TempMaintenanceLedgEntry.Delete() then
            Error(Text004, MaintenanceLedgEntry.TableCaption(), GLEntry.TableCaption());
    end;

    procedure FinishFAReverseEntry(GLReg: Record "G/L Register")
    var
        GLEntry: Record "G/L Entry";
    begin
        if TempFALedgEntry.FindFirst() then
            Error(Text004, FALedgEntry.TableCaption(), GLEntry.TableCaption());
        if TempMaintenanceLedgEntry.FindFirst() then
            Error(Text004, MaintenanceLedgEntry.TableCaption(), GLEntry.TableCaption());
        if RegisterInserted then begin
            FAReg."G/L Register No." := GLReg."No.";
            FAReg.Modify();
        end;
    end;

#if not CLEAN20
    [Obsolete('Reverted FA Disposal Entries sign', '18.0')]
    procedure FinalizeInsertFA()
    var
        FALedgerEntry: Record "FA Ledger Entry";
    begin
        if TempFALedgerEntryReverse.FindSet() then begin
            repeat
                FALedgerEntry.Get(TempFALedgerEntryReverse."Entry No.");
                ReverseFALedgerEntryAmounts(FALedgerEntry);
                FALedgerEntry.Modify();
            until TempFALedgerEntryReverse.Next() = 0;
            TempFALedgerEntryReverse.DeleteAll();
        end;
    end;
#endif

    local procedure SetFAReversalMark(var FALedgEntry: Record "FA Ledger Entry"; NextEntryNo: Integer)
    var
        FALedgEntry2: Record "FA Ledger Entry";
        GenJnlPostReverse: Codeunit "Gen. Jnl.-Post Reverse";
        CloseReversal: Boolean;
    begin
        if FALedgEntry."Reversed Entry No." <> 0 then begin
            FALedgEntry2.Get(FALedgEntry."Reversed Entry No.");
            if FALedgEntry2."Reversed Entry No." <> 0 then
                Error(Text005);
            CloseReversal := true;
            FALedgEntry2."Reversed by Entry No." := 0;
            FALedgEntry2.Reversed := false;
            FALedgEntry2.Modify();
        end;
        FALedgEntry."Reversed by Entry No." := NextEntryNo;
        if CloseReversal then
            FALedgEntry."Reversed Entry No." := NextEntryNo;
        FALedgEntry.Reversed := true;
        FALedgEntry.Modify();
        FALedgEntry."Reversed by Entry No." := 0;
        FALedgEntry."Reversed Entry No." := FALedgEntry."Entry No.";
        if CloseReversal then
            FALedgEntry."Reversed by Entry No." := FALedgEntry."Entry No.";

        GenJnlPostReverse.SetReversalDescription(FALedgEntry, FALedgEntry.Description);
    end;

    local procedure SetMaintReversalMark(var MaintenanceLedgEntry: Record "Maintenance Ledger Entry"; NextEntryNo: Integer)
    var
        MaintenanceLedgEntry2: Record "Maintenance Ledger Entry";
        GenJnlPostReverse: Codeunit "Gen. Jnl.-Post Reverse";
        CloseReversal: Boolean;
    begin
        if MaintenanceLedgEntry."Reversed Entry No." <> 0 then begin
            MaintenanceLedgEntry2.Get(MaintenanceLedgEntry."Reversed Entry No.");
            if MaintenanceLedgEntry2."Reversed Entry No." <> 0 then
                Error(Text005);
            CloseReversal := true;
            MaintenanceLedgEntry2."Reversed by Entry No." := 0;
            MaintenanceLedgEntry2.Reversed := false;
            MaintenanceLedgEntry2.Modify();
        end;
        MaintenanceLedgEntry."Reversed by Entry No." := NextEntryNo;
        if CloseReversal then
            MaintenanceLedgEntry."Reversed Entry No." := NextEntryNo;
        MaintenanceLedgEntry.Reversed := true;
        MaintenanceLedgEntry.Modify();
        MaintenanceLedgEntry."Reversed by Entry No." := 0;
        MaintenanceLedgEntry."Reversed Entry No." := MaintenanceLedgEntry."Entry No.";
        if CloseReversal then
            MaintenanceLedgEntry."Reversed by Entry No." := MaintenanceLedgEntry."Entry No.";

        GenJnlPostReverse.SetReversalDescription(MaintenanceLedgEntry, MaintenanceLedgEntry.Description);
    end;

    procedure SetNetdisposal(NetDisp2: Boolean)
    begin
        FAInsertGLAcc.SetNetDisposal(NetDisp2);
    end;

    procedure SetLastEntryNo(FindLastEntry: Boolean)
    var
        FALedgEntry: Record "FA Ledger Entry";
    begin
        LastEntryNo := 0;
        if FindLastEntry then
            LastEntryNo := FALedgEntry.GetLastEntryNo();
    end;

    procedure SetGLRegisterNo(NewGLRegisterNo: Integer)
    begin
        GLRegisterNo := NewGLRegisterNo;
    end;

#if not CLEAN20
    [Obsolete('Reverted FA Disposal Entries sign', '18.0')]
    procedure ReverseFALedgerEntryAmounts(var FALedgerEntry: Record "FA Ledger Entry")
    begin
        FALedgerEntry.Amount := -FALedgerEntry.Amount;
        FALedgerEntry."Amount (LCY)" := -FALedgerEntry."Amount (LCY)";
        UpdateDebitCredit(FALedgerEntry);
    end;
#endif

    local procedure UpdateDebitCredit(var FALedgerEntry: Record "FA Ledger Entry")
    begin
        with FALedgerEntry do
            if (Amount > 0) and not Correction or
               (Amount < 0) and Correction
            then begin
                "Debit Amount" := Amount;
                "Credit Amount" := 0
            end else begin
                "Debit Amount" := 0;
                "Credit Amount" := -Amount;
            end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetFAPostingType(var FALedgEntry: Record "FA Ledger Entry"; FAPostingTypeSetup: Record "FA Posting Type Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertFA(var FALedgerEntry: Record "FA Ledger Entry")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeInsertRegister(var FALedgerEntry: Record "FA Ledger Entry"; var FALedgerEntry2: Record "FA Ledger Entry"; var NextEntryNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckFADocNoOnAfterOldFALedgEntrySetFilters(OldFALedgEntry: Record "FA Ledger Entry"; FALedgEntry: Record "FA Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertReverseEntryOnBeforeInsertRegister(var FALedgerEntry: Record "FA Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertReverseEntryOnBeforeFACheckConsistency(var FALedgerEntry: Record "FA Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertReverseEntryOnNonSalvageValueFAPostingTypeOnBeforeCheckDimValuePosting(var TableID: array[10] of Integer; var AccNo: array[10] of Code[20]; var FALedgEntry3: Record "FA Ledger Entry");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckFADocNo(FALedgEntry: Record "FA Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnInsertFAOnAfterSetFALedgEntryFANo(FALedgEntry3: Record "FA Ledger Entry"; FALedgEntry2: Record "FA Ledger Entry"; FALedgEntry: Record "FA Ledger Entry"; var NextEntryNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertFAOnBeforeFACheckConsistency(var FALedgerEntry: Record "FA Ledger Entry"; FALedgerEntry3: Record "FA Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertFAOnBeforeCheckFALedgEntry(var FALedgEntry: Record "FA Ledger Entry"; FALedgEntry2: Record "FA Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertMaintenanceOnAfterDeprBookGet(var DeprBook: Record "Depreciation Book")
    begin
    end;
}


﻿page 1190 "Create Payment"
{
    Caption = 'Create Payment';
    PageType = StandardDialog;
    SaveValues = true;

    layout
    {
        area(content)
        {
            group(Control6)
            {
                ShowCaption = false;
                field("Template Name"; JournalTemplateName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Template Name';
                    ShowMandatory = true;
                    TableRelation = "Gen. Journal Template".Name WHERE(Type = CONST(Payments));
                    ToolTip = 'Specifies the name of the journal template.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        GenJnlTemplate: Record "Gen. Journal Template";
                        GeneralJournalTemplates: Page "General Journal Templates";
                    begin
                        GenJnlTemplate.FilterGroup(2);
                        GenJnlTemplate.SetRange(Type, GenJnlTemplate.Type::Payments);
                        GenJnlTemplate.FilterGroup(0);
                        GeneralJournalTemplates.SetTableView(GenJnlTemplate);
                        GeneralJournalTemplates.LookupMode := true;
                        if GeneralJournalTemplates.RunModal() = ACTION::LookupOK then begin
                            GeneralJournalTemplates.GetRecord(GenJnlTemplate);
                            JournalTemplateName := GenJnlTemplate.Name;
                            BatchSelection(JournalTemplateName, JournalBatchName, false);
                        end;
                    end;

                    trigger OnValidate()
                    var
                        GenJnlTemplate: Record "Gen. Journal Template";
                    begin
                        GenJnlTemplate.Get(JournalTemplateName);
                        BatchSelection(JournalTemplateName, JournalBatchName, false);
                    end;
                }
                field("Batch Name"; JournalBatchName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Batch Name';
                    ShowMandatory = true;
                    TableRelation = "Gen. Journal Batch".Name WHERE("Template Type" = CONST(Payments),
                                                                     Recurring = CONST(false));
                    ToolTip = 'Specifies the name of the journal batch.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        GenJournalBatch: Record "Gen. Journal Batch";
                        GeneralJournalBatches: Page "General Journal Batches";
                    begin
                        GenJournalBatch.FilterGroup(2);
                        GenJournalBatch.SetRange("Journal Template Name", JournalTemplateName);
                        GenJournalBatch.FilterGroup(0);

                        GeneralJournalBatches.SetTableView(GenJournalBatch);
                        GeneralJournalBatches.LookupMode := true;
                        if GeneralJournalBatches.RunModal() = ACTION::LookupOK then begin
                            GeneralJournalBatches.GetRecord(GenJournalBatch);
                            JournalBatchName := GenJournalBatch.Name;
                            BatchSelection(JournalTemplateName, JournalBatchName, false);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        if JournalBatchName <> '' then
                            BatchSelection(JournalTemplateName, JournalBatchName, false);
                    end;
                }
                field("Posting Date"; PostingDate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posting Date';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the entry''s posting date.';

                    trigger OnValidate()
                    begin
                        if JournalBatchName <> '' then
                            BatchSelection(JournalTemplateName, JournalBatchName, false);
                    end;
                }
                field("Starting Document No."; NextDocNo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Starting Document No.';
                    ShowMandatory = true;
                    ToolTip = 'Specifies a document number for the journal line.';

                    trigger OnValidate()
                    begin
                        if NextDocNo <> '' then
                            if IncStr(NextDocNo) = '' then
                                Error(StartingDocumentNoErr);
                    end;
                }
                field("Bank Account"; BalAccountNo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bank Account';
                    TableRelation = "Bank Account";
                    ToolTip = 'Specifies the bank account to which a balancing entry for the journal line will be posted.';
                }
                field("Payment Type"; BankPaymentType)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Payment Type';
                    ToolTip = 'Specifies the code for the payment type to be used for the entry on the payment journal line.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJnlManagement: Codeunit GenJnlManagement;
    begin
        PostingDate := WorkDate();

        if not GenJnlTemplate.Get(JournalTemplateName) then
            Clear(JournalTemplateName);
        if not GenJournalBatch.Get(JournalTemplateName, JournalBatchName) then
            Clear(JournalBatchName);

        if JournalTemplateName = '' then
            if GenJnlManagement.TemplateSelectionSimple(GenJnlTemplate, GenJnlTemplate.Type::Payments, false) then
                JournalTemplateName := GenJnlTemplate.Name;

        BatchSelection(JournalTemplateName, JournalBatchName, true);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::OK then begin
            if JournalBatchName = '' then
                Error(BatchNumberNotFilledErr);
            if Format(PostingDate) = '' then
                Error(PostingDateNotFilledErr);
            if NextDocNo = '' then
                Error(SpecifyStartingDocNumErr);
        end;
    end;

    var
        GenJnlManagement: Codeunit GenJnlManagement;
        PostingDate: Date;
        BalAccountNo: Code[20];
        NextDocNo: Code[20];
        JournalBatchName: Code[10];
        JournalTemplateName: Code[10];
        BankPaymentType: Enum "Bank Payment Type";
        StartingDocumentNoErr: Label 'The value in the Starting Document No. field must have a number so that we can assign the next number in the series.';
        BatchNumberNotFilledErr: Label 'You must fill the Batch Name field.';
        PostingDateNotFilledErr: Label 'You must fill the Posting Date field.';
        SpecifyStartingDocNumErr: Label 'In the Starting Document No. field, specify the first document number to be used.';
        MessageToRecipientMsg: Label 'Payment of %1 %2 ', Comment = '%1 document type, %2 Document No.';
        EarlierPostingDateErr: Label 'You cannot create a payment with an earlier posting date for %1 %2.', Comment = '%1 - Document Type, %2 - Document No.. You cannot create a payment with an earlier posting date for Invoice INV-001.';
        DocToApplyLbl: Label '%1 %2', Locked = true, Comment = '%1=Document Type;%2=Vendor No.';

    procedure GetPostingDate(): Date
    begin
        exit(PostingDate);
    end;

    procedure GetBankAccount(): Text
    begin
        exit(Format(BalAccountNo));
    end;

    procedure GetBankPaymentType(): Integer
    begin
        exit(BankPaymentType.AsInteger());
    end;

    procedure GetBatchNumber(): Code[10]
    begin
        exit(JournalBatchName);
    end;

    procedure GetTemplateName(): Code[10]
    begin
        exit(JournalTemplateName);
    end;

    procedure MakeGenJnlLines(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    var
        GenJnlLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
#if not CLEAN22
        TempPaymentBuffer: Record "Payment Buffer" temporary;
#endif
        TempVendorPaymentBuffer: Record "Vendor Payment Buffer" temporary;
        DocumentsToApply: List of [Text];
        PaymentAmt: Decimal;
        VendorLedgerEntryView: Text;
        GenJournalDocType: Enum "Gen. Journal Document Type";
        ThereAreNoPaymentsToProccesErr: Label 'There are no payments to process for the selected entries.';
        PaymentApplicationInProcessErr: Label 'A payment application process ''%1'' is in progress for the selected entry no. %2. Make sure you have not applied this entry in ongoing journals or payment reconciliation journals.', Comment = '%1 - A code for the payment application process, %2 - The entry no. that has an ongoing application process';
    begin
        TempVendorPaymentBuffer.Reset();
        TempVendorPaymentBuffer.DeleteAll();

        VendorLedgerEntryView := VendorLedgerEntry.GetView();
        VendorLedgerEntry.SetCurrentKey("Entry No.");
        if VendorLedgerEntry.Find('-') then
            repeat
                if Vendor.Get(VendorLedgerEntry."Vendor No.") then
                    Vendor.CheckBlockedVendOnJnls(Vendor, GenJournalDocType::Payment, true);
                if PostingDate < VendorLedgerEntry."Posting Date" then
                    Error(EarlierPostingDateErr, VendorLedgerEntry."Document Type", VendorLedgerEntry."Document No.");
                if VendorLedgerEntry."Applies-to ID" = '' then begin
                    VendorLedgerEntry.CalcFields("Remaining Amount");
                    TempVendorPaymentBuffer."Vendor No." := VendorLedgerEntry."Vendor No.";
                    TempVendorPaymentBuffer."Currency Code" := VendorLedgerEntry."Currency Code";

                    if VendorLedgerEntry."Payment Method Code" = '' then begin
                        if Vendor.Get(VendorLedgerEntry."Vendor No.") then
                            TempVendorPaymentBuffer."Payment Method Code" := Vendor."Payment Method Code";
                    end else
                        TempVendorPaymentBuffer."Payment Method Code" := VendorLedgerEntry."Payment Method Code";

                    TempVendorPaymentBuffer.CopyFieldsFromVendorLedgerEntry(VendorLedgerEntry);
                    OnUpdateVendorPaymentBufferFromVendorLedgerEntry(TempVendorPaymentBuffer, VendorLedgerEntry);
#if not CLEAN22
                    TempPaymentBuffer.CopyFieldsFromVendorPaymentBuffer(TempVendorPaymentBuffer);
                    OnUpdateTempBufferFromVendorLedgerEntry(TempPaymentBuffer, VendorLedgerEntry);
                    TempVendorPaymentBuffer.CopyFieldsFromPaymentBuffer(TempPaymentBuffer);
#endif
                    TempVendorPaymentBuffer."Dimension Entry No." := 0;
                    TempVendorPaymentBuffer."Global Dimension 1 Code" := '';
                    TempVendorPaymentBuffer."Global Dimension 2 Code" := '';
                    TempVendorPaymentBuffer."Dimension Set ID" := VendorLedgerEntry."Dimension Set ID";
                    TempVendorPaymentBuffer."Vendor Ledg. Entry No." := VendorLedgerEntry."Entry No.";
                    TempVendorPaymentBuffer."Vendor Ledg. Entry Doc. Type" := VendorLedgerEntry."Document Type";
                    TempVendorPaymentBuffer."Remit-to Code" := VendorLedgerEntry."Remit-to Code";

                    if CheckCalcPmtDiscGenJnlVend(VendorLedgerEntry."Remaining Amount", VendorLedgerEntry, 0, false) then
                        PaymentAmt := -(VendorLedgerEntry."Remaining Amount" - VendorLedgerEntry."Remaining Pmt. Disc. Possible")
                    else
                        PaymentAmt := -VendorLedgerEntry."Remaining Amount";

                    TempVendorPaymentBuffer.Reset();
                    TempVendorPaymentBuffer.SetRange("Vendor No.", VendorLedgerEntry."Vendor No.");
                    TempVendorPaymentBuffer.SetRange("Vendor Ledg. Entry Doc. Type", TempVendorPaymentBuffer."Vendor Ledg. Entry Doc. Type");
                    if TempVendorPaymentBuffer.Find('-') then begin
                        TempVendorPaymentBuffer.Amount += PaymentAmt;
                        TempVendorPaymentBuffer."Payment Reference" := '';
                        TempVendorPaymentBuffer.Modify();

                        if not DocumentsToApply.Contains(StrSubstNo(DocToApplyLbl, TempVendorPaymentBuffer."Vendor Ledg. Entry Doc. Type", VendorLedgerEntry."Vendor No.")) then
                            DocumentsToApply.Add(StrSubstNo(DocToApplyLbl, TempVendorPaymentBuffer."Vendor Ledg. Entry Doc. Type", VendorLedgerEntry."Vendor No."));
                    end else begin
                        TempVendorPaymentBuffer."Document No." := NextDocNo;
                        NextDocNo := IncStr(NextDocNo);
                        TempVendorPaymentBuffer.Amount := PaymentAmt;
                        TempVendorPaymentBuffer.Insert();
                    end;
                    VendorLedgerEntry."Applies-to ID" := TempVendorPaymentBuffer."Document No.";

                    VendorLedgerEntry."Amount to Apply" := VendorLedgerEntry."Remaining Amount";
                    CODEUNIT.Run(CODEUNIT::"Vend. Entry-Edit", VendorLedgerEntry);
                end else
                    Error(PaymentApplicationInProcessErr, VendorLedgerEntry."Applies-to ID", VendorLedgerEntry."Entry No.")
            until VendorLedgerEntry.Next() = 0;
        if TempVendorPaymentBuffer.IsEmpty() then
            Error(ThereAreNoPaymentsToProccesErr);
        CopyTempPaymentBufferToGenJournalLines(TempVendorPaymentBuffer, GenJnlLine, DocumentsToApply);
        VendorLedgerEntry.SetView(VendorLedgerEntryView);
    end;

    local procedure CopyTempPaymentBufferToGenJournalLines(var TempVendorPaymentBuffer: Record "Vendor Payment Buffer" temporary; var GenJnlLine: Record "Gen. Journal Line"; DocumentsToApply: List of [Text])
    var
        Vendor: Record Vendor;
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
#if not CLEAN22
        TempPaymentBuffer: Record "Payment Buffer" temporary;
#endif
        LastLineNo: Integer;
    begin
        GenJnlLine.LockTable();
        GenJournalBatch.Get(JournalTemplateName, JournalBatchName);
        GenJournalTemplate.Get(JournalTemplateName);
        GenJnlLine.SetRange("Journal Template Name", JournalTemplateName);
        GenJnlLine.SetRange("Journal Batch Name", JournalBatchName);
        if GenJnlLine.FindLast() then begin
            LastLineNo := GenJnlLine."Line No.";
            GenJnlLine.Init();
        end;

        TempVendorPaymentBuffer.Reset();
        TempVendorPaymentBuffer.SetCurrentKey("Document No.");
        TempVendorPaymentBuffer.SetFilter(
          "Vendor Ledg. Entry Doc. Type", '<>%1&<>%2', TempVendorPaymentBuffer."Vendor Ledg. Entry Doc. Type"::Refund,
          TempVendorPaymentBuffer."Vendor Ledg. Entry Doc. Type"::Payment);
        if TempVendorPaymentBuffer.Find('-') then
            repeat
                with GenJnlLine do begin
                    Init();
                    Validate("Journal Template Name", JournalTemplateName);
                    Validate("Journal Batch Name", JournalBatchName);
                    LastLineNo += 10000;
                    "Line No." := LastLineNo;
                    if TempVendorPaymentBuffer."Vendor Ledg. Entry Doc. Type" = TempVendorPaymentBuffer."Vendor Ledg. Entry Doc. Type"::Invoice then
                        "Document Type" := "Document Type"::Payment
                    else
                        "Document Type" := "Document Type"::Refund;
                    "Posting No. Series" := GenJournalBatch."Posting No. Series";
                    "Document No." := TempVendorPaymentBuffer."Document No.";
                    "Account Type" := "Account Type"::Vendor;

                    SetHideValidation(true);
                    Validate("Posting Date", PostingDate);
                    Validate("Account No.", TempVendorPaymentBuffer."Vendor No.");

                    if Vendor."No." <> TempVendorPaymentBuffer."Vendor No." then
                        Vendor.Get(TempVendorPaymentBuffer."Vendor No.");
                    Description := Vendor.Name;

                    "Bal. Account Type" := "Bal. Account Type"::"Bank Account";
                    Validate("Bal. Account No.", BalAccountNo);
                    Validate("Currency Code", TempVendorPaymentBuffer."Currency Code");

                    "Message to Recipient" := GetMessageToRecipient(TempVendorPaymentBuffer, DocumentsToApply);
                    "Bank Payment Type" := BankPaymentType;
                    "Applies-to ID" := "Document No.";

                    "Source Code" := GenJournalTemplate."Source Code";
                    "Reason Code" := GenJournalBatch."Reason Code";
                    "Source Line No." := TempVendorPaymentBuffer."Vendor Ledg. Entry No.";
                    "Shortcut Dimension 1 Code" := TempVendorPaymentBuffer."Global Dimension 1 Code";
                    "Shortcut Dimension 2 Code" := TempVendorPaymentBuffer."Global Dimension 2 Code";
                    "Dimension Set ID" := TempVendorPaymentBuffer."Dimension Set ID";

                    Validate(Amount, TempVendorPaymentBuffer.Amount);

                    "Applies-to Doc. Type" := TempVendorPaymentBuffer."Vendor Ledg. Entry Doc. Type";
                    "Applies-to Doc. No." := TempVendorPaymentBuffer."Vendor Ledg. Entry Doc. No.";

                    Validate("Payment Method Code", TempVendorPaymentBuffer."Payment Method Code");

                    "Remit-to Code" := TempVendorPaymentBuffer."Remit-to Code";

                    TempVendorPaymentBuffer.CopyFieldsToGenJournalLine(GenJnlLine);

                    OnBeforeUpdateGnlJnlLineDimensionsFromVendorPayment(GenJnlLine, TempVendorPaymentBuffer);
#if not CLEAN22
                    TempPaymentBuffer.CopyFieldsFromVendorPaymentBuffer(TempVendorPaymentBuffer);
                    OnBeforeUpdateGnlJnlLineDimensionsFromTempBuffer(GenJnlLine, TempPaymentBuffer);
                    TempVendorPaymentBuffer.CopyFieldsFromPaymentBuffer(TempPaymentBuffer);
#endif
                    UpdateDimensions(GenJnlLine, TempVendorPaymentBuffer);
                    Insert();
                end;
            until TempVendorPaymentBuffer.Next() = 0;
    end;

    local procedure UpdateDimensions(var GenJnlLine: Record "Gen. Journal Line"; TempVendorPaymentBuffer: Record "Vendor Payment Buffer" temporary)
    var
        DimBuf: Record "Dimension Buffer";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimVal: Record "Dimension Value";
        DimBufMgt: Codeunit "Dimension Buffer Management";
        DimMgt: Codeunit DimensionManagement;
        NewDimensionID: Integer;
        DimSetIDArr: array[10] of Integer;
    begin
        with GenJnlLine do begin
            IF "Dimension Set ID" = 0 then begin
                NewDimensionID := "Dimension Set ID";

                DimBuf.Reset();
                DimBuf.DeleteAll();
                DimBufMgt.GetDimensions(TempVendorPaymentBuffer."Dimension Entry No.", DimBuf);
                if DimBuf.FindSet() then
                    repeat
                        DimVal.Get(DimBuf."Dimension Code", DimBuf."Dimension Value Code");
                        TempDimSetEntry."Dimension Code" := DimBuf."Dimension Code";
                        TempDimSetEntry."Dimension Value Code" := DimBuf."Dimension Value Code";
                        TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
                        TempDimSetEntry.Insert();
                    until DimBuf.Next() = 0;
                NewDimensionID := DimMgt.GetDimensionSetID(TempDimSetEntry);
                "Dimension Set ID" := NewDimensionID;

                CreateDimFromDefaultDim(0);
                if NewDimensionID <> "Dimension Set ID" then
                    AssignCombinedDimensionSetID(GenJnlLine, DimSetIDArr, NewDimensionID);
            end;

            DimMgt.GetDimensionSet(TempDimSetEntry, "Dimension Set ID");
            DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code",
              "Shortcut Dimension 2 Code");
        end;
        OnAfterUpdateDimensions(GenJnlLine);
    end;

    local procedure AssignCombinedDimensionSetID(var GenJournalLine: Record "Gen. Journal Line"; var DimSetIDArr: array[10] of Integer; NewDimensionID: Integer)
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        DimSetIDArr[1] := GenJournalLine."Dimension Set ID";
        DimSetIDArr[2] := NewDimensionID;
        GenJournalLine."Dimension Set ID" := DimensionManagement.GetCombinedDimensionSetID(DimSetIDArr, GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code");

        OnAfterAssignCombinedDimensionSetID(GenJournalLine, DimSetIDArr);
    end;

    local procedure SetNextNo(GenJournalBatchNoSeries: Code[20]; KeepSavedDocumentNo: Boolean)
    var
        GenJournalLine: Record "Gen. Journal Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if (GenJournalBatchNoSeries = '') then begin
            if not KeepSavedDocumentNo then
                NextDocNo := ''
        end else begin
            GenJournalLine.SetRange("Journal Template Name", JournalTemplateName);
            GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
            if GenJournalLine.FindLast() then
                NextDocNo := IncStr(GenJournalLine."Document No.")
            else
                NextDocNo := NoSeriesMgt.DoGetNextNo(GenJournalBatchNoSeries, PostingDate, false, true);
            Clear(NoSeriesMgt);
        end;
    end;

    procedure CheckCalcPmtDiscGenJnlVend(RemainingAmt: Decimal; OldVendLedgEntry2: Record "Vendor Ledger Entry"; ApplnRoundingPrecision: Decimal; CheckAmount: Boolean): Boolean
    var
        NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
        OldCVLedgEntryBuf2: Record "CV Ledger Entry Buffer";
        PaymentToleranceManagement: Codeunit "Payment Tolerance Management";
    begin
        NewCVLedgEntryBuf."Document Type" := NewCVLedgEntryBuf."Document Type"::Payment;
        NewCVLedgEntryBuf."Posting Date" := PostingDate;
        NewCVLedgEntryBuf."Remaining Amount" := RemainingAmt;
        OldCVLedgEntryBuf2.CopyFromVendLedgEntry(OldVendLedgEntry2);
        exit(
          PaymentToleranceManagement.CheckCalcPmtDisc(
            NewCVLedgEntryBuf, OldCVLedgEntryBuf2, ApplnRoundingPrecision, false, CheckAmount));
    end;

    local procedure GetMessageToRecipient(TempVendorPaymentBuffer: Record "Vendor Payment Buffer" temporary; DocumentsToApply: List of [Text]): Text[140]
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        CompanyInformation: Record "Company Information";
    begin
        if DocumentsToApply.Contains(StrSubstNo(DocToApplyLbl, TempVendorPaymentBuffer."Vendor Ledg. Entry Doc. Type", TempVendorPaymentBuffer."Vendor No.")) then begin
            CompanyInformation.Get();
            exit(CompanyInformation.Name);
        end;

        VendorLedgerEntry.Get(TempVendorPaymentBuffer."Vendor Ledg. Entry No.");
        if VendorLedgerEntry."Message to Recipient" <> '' then
            exit(VendorLedgerEntry."Message to Recipient");

        exit(
          StrSubstNo(
            MessageToRecipientMsg,
            TempVendorPaymentBuffer."Vendor Ledg. Entry Doc. Type",
            TempVendorPaymentBuffer."Applies-to Ext. Doc. No."));
    end;

    local procedure BatchSelection(CurrentJnlTemplateName: Code[10]; var CurrentJnlBatchName: Code[10]; KeepSaveDocumentNo: Boolean)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJnlManagement.CheckTemplateName(CurrentJnlTemplateName, CurrentJnlBatchName);
        GenJournalBatch.Get(CurrentJnlTemplateName, CurrentJnlBatchName);
        SetNextNo(GenJournalBatch."No. Series", KeepSaveDocumentNo);
    end;

#if not CLEAN22
    [Obsolete('Replaced by OnUpdateVendorPaymentBufferFromVendorLedgerEntry.', '22.0')]
    [IntegrationEvent(false, false)]
    local procedure OnUpdateTempBufferFromVendorLedgerEntry(var TempPaymentBuffer: Record "Payment Buffer" temporary; VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnUpdateVendorPaymentBufferFromVendorLedgerEntry(var TempVendorPaymentBuffer: Record "Vendor Payment Buffer" temporary; VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
    end;

#if not CLEAN22
    [Obsolete('Replaced by OnBeforeUpdateGnlJnlLineDimensionsFromVendorPayment.', '22.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateGnlJnlLineDimensionsFromTempBuffer(var GenJournalLine: Record "Gen. Journal Line"; TempPaymentBuffer: Record "Payment Buffer" temporary)
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateGnlJnlLineDimensionsFromVendorPayment(var GenJournalLine: Record "Gen. Journal Line"; TempVendorPaymentBuffer: Record "Vendor Payment Buffer" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateDimensions(var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignCombinedDimensionSetID(var GenJournalLine: Record "Gen. Journal Line"; DimSetIDArr: array[10] of Integer)
    begin
    end;
}
page 39 "General Journal"
{
    // // This page has two view modes based on global variable 'IsSimplePage' as :-
    // // Classic mode (Show more columns action) - When IsSimplePage is set to false. This view supports showing all the traditional columns. All the lines for all
    // // document numbers are shown in this view.
    // // Simple mode (Show less columns actions) - When IsSimplePage is set to True. This view supports limitted columns and pulls document number, posting date,
    // // currency code as global variables. This mode is intented to do fast data entry so only ONE document number is shown at a time. User can
    // // use next / previous buttons to navigate between different document numbers.
    // // By default this page opens up in Simple mode; if users chooses to switch to classic mode (show more columns) then we remember their selection in Journal User Preferences table

    ApplicationArea = Basic, Suite;
    AutoSplitKey = true;
    Caption = 'General Journals';
    DataCaptionExpression = DataCaption();
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Gen. Journal Line";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Control120)
            {
                ShowCaption = false;
                field(CurrentJnlBatchName; CurrentJnlBatchName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Batch Name';
                    Lookup = true;
                    ToolTip = 'Specifies the name of the journal batch.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        CurrPage.SaveRecord();
                        GenJnlManagement.LookupName(CurrentJnlBatchName, Rec);
                        SetControlAppearanceFromBatch();
                        // Set simple view when batch is changed
                        SetDataForSimpleModeOnBatchChange();
                        OnLookupCurrentJnlBatchNameOnAfterSetDataForSimpleModeOnBatchChange(CurrentJnlBatchName);
                        CurrPage.Update(false);
                    end;

                    trigger OnValidate()
                    begin
                        GenJnlManagement.CheckName(CurrentJnlBatchName, Rec);
                        CurrentJnlBatchNameOnAfterVali();
                        SetDataForSimpleModeOnBatchChange();
                        OnAfterValidateCurrentJnlBatchName(CurrentJnlBatchName);
                    end;
                }
                field("<Document No. Simple Page>"; CurrentDocNo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Document No.';
                    ToolTip = 'Specifies a document number for the journal line.';
                    Visible = IsSimplePage;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if not IsSimplePage then
                            exit;
                        if CurrentDocNo = '' then
                            CurrentDocNo := "Document No.";
                        if CurrentDocNo = "Document No." then
                            exit;

                        if Count = 0 then
                            "Document No." := CurrentDocNo;

                        IsChangingDocNo := true;
                        SetDocumentNumberFilter(CurrentDocNo);
                        CurrPage.Update(false);
                    end;
                }
                field("<CurrentPostingDate>"; CurrentPostingDate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posting Date';
                    ClosingDates = true;
                    ToolTip = 'Specifies the date of the transaction in the general ledger, and thereby the fiscal year and period.';
                    Visible = IsSimplePage;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        UpdateCurrencyFactor(FieldNo("Posting Date"));
                    end;
                }
                field("<CurrentCurrencyCode>"; CurrentCurrencyCode)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Currency Code';
                    TableRelation = Currency.Code;
                    ToolTip = 'Specifies the code of the currency for the amounts on the journal line.';
                    Visible = IsSimplePage;

                    trigger OnValidate()
                    begin
                        GenJnlManagement.CheckCurrencyCode(CurrentCurrencyCode);
                        UpdateCurrencyFactor(FieldNo("Currency Code"));
                    end;
                }
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the date of the transaction in the general ledger, and thereby the fiscal year and period.';
                    Visible = NOT IsSimplePage;
                }
                field("VAT Reporting Date"; Rec."VAT Reporting Date")
                {
                    ApplicationArea = VAT;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the date used to include entries on VAT reports in a VAT period. This is either the date that the document was created or posted, depending on your setting on the General Ledger Setup page.';
                    Visible = (not IsSimplePage) and VATDateEnabled;
                    Editable = VATDateEnabled;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the date on the document that provides the basis for the entry on the journal line.';
                    Visible = false;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the type of document that the entry on the journal line is.';
                    Visible = NOT IsSimplePage;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a document number for the journal line.';
                    Visible = NOT IsSimplePage;
                    ShowMandatory = true;
                }
                field("Incoming Document Entry No."; Rec."Incoming Document Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the incoming document that this general journal line is created for.';
                    Visible = false;

                    trigger OnAssistEdit()
                    begin
                        if "Incoming Document Entry No." > 0 then
                            HyperLink(GetIncomingDocumentURL());
                    end;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                    Visible = false;
                }
                field("Applies-to Ext. Doc. No."; Rec."Applies-to Ext. Doc. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the external document number that will be exported in the payment file.';
                    Visible = false;
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the type of account that the entry on the journal line will be posted to.';
                    Visible = NOT IsSimplePage;

                    trigger OnValidate()
                    begin
                        GenJnlManagement.GetAccounts(Rec, AccName, BalAccName);
                        SetUserInteractions();
                        EnableApplyEntriesAction();
                        CurrPage.SaveRecord();
                    end;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the account number that the entry on the journal line will be posted to.';

                    trigger OnValidate()
                    begin
                        GenJnlManagement.GetAccounts(Rec, AccName, BalAccName);
                        ShowShortcutDimCode(ShortcutDimCode);
                        SetUserInteractions();
                        // On TAB81 Account No. - OnValidate() will reset currency code to empty if
                        // there is no balancing account for this G/L line. This happens under GetGLAccount
                        // function. So, we need to validate current curency code again.
                        if IsSimplePage then
                            Validate("Currency Code", CurrentCurrencyCode);
                        CurrPage.SaveRecord();
                    end;
                }
                field(AccountName; AccName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Account Name';
                    Editable = false;
                    ToolTip = 'Specifies the account name that the entry on the journal line will be posted to.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies a description of the entry.';
                }
                field("Payer Information"; Rec."Payer Information")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies payer information that is imported with the bank statement file.';
                    Visible = false;
                }
                field("Transaction Information"; Rec."Transaction Information")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies transaction information that is imported with the bank statement file.';
                    Visible = false;
                }
                field("Business Unit Code"; Rec."Business Unit Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the business unit that the entry derives from in a consolidated company.';
                    Visible = false;
                }
                field("Salespers./Purch. Code"; Rec."Salespers./Purch. Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the salesperson or purchaser who is linked to the journal line.';
                    Visible = false;
                }
                field("Campaign No."; Rec."Campaign No.")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the number of the campaign the journal line is linked to.';
                    Visible = false;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Suite;
                    AssistEdit = true;
                    ToolTip = 'Specifies the code of the currency for the amounts on the journal line.';
                    Visible = NOT IsSimplePage;

                    trigger OnAssistEdit()
                    begin
                        ChangeExchangeRate.SetParameter("Currency Code", "Currency Factor", "Posting Date");
                        if ChangeExchangeRate.RunModal() = ACTION::OK then
                            Validate("Currency Factor", ChangeExchangeRate.GetParameter());

                        Clear(ChangeExchangeRate);
                    end;
                }
                field("EU 3-Party Trade"; Rec."EU 3-Party Trade")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the entry was part of a 3-party trade. If it was, there is a check mark in the field.';
                    Visible = NOT IsSimplePage;
                }
                field("Gen. Posting Type"; Rec."Gen. Posting Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general posting type that will be used when you post the entry on this journal line.';
                    Visible = NOT IsSimplePage;
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor''s or customer''s trade type to link transactions made for this business partner with the appropriate general ledger account according to the general posting setup.';
                    Visible = NOT IsSimplePage;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item''s product type to link transactions made for this item with the appropriate general ledger account according to the general posting setup.';
                    Visible = NOT IsSimplePage;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT business posting group code that will be used when you post the entry on the journal line.';
                    Visible = false;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT product posting group. Links business transactions made for the item, resource, or G/L account with the general ledger, to account for VAT amounts resulting from trade with that record.';
                    Visible = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity of items to be included on the journal line.';
                    Visible = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the total amount (including VAT) that the journal line consists of.';
                    Visible = AmountVisible;

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                    end;
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount in local currency (including VAT) that the journal line consists of.';
                    Visible = AmountVisible;
                }
                field("Debit Amount"; Rec."Debit Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount (including VAT) that the journal line consists of, if it is a debit amount.';
                    Visible = DebitCreditVisible;
                }
                field("Credit Amount"; Rec."Credit Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount (including VAT) that the journal line consists of, if it is a credit amount.';
                    Visible = DebitCreditVisible;
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of VAT included in the total amount.';
                    Visible = false;
                }
                field("VAT Difference"; Rec."VAT Difference")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the difference between the calculate VAT amount and the VAT amount that you have entered manually.';
                    Visible = false;
                }
                field("Bal. VAT Amount"; Rec."Bal. VAT Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of Bal. VAT included in the total amount.';
                    Visible = false;
                }
                field("Bal. VAT Difference"; Rec."Bal. VAT Difference")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the difference between the calculate VAT amount and the VAT amount that you have entered manually.';
                    Visible = false;
                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the code for the balancing account type that should be used in this journal line.';
                    Visible = NOT IsSimplePage;

                    trigger OnValidate()
                    begin
                        EnableApplyEntriesAction();
                    end;
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the number of the general ledger, customer, vendor, or bank account to which a balancing entry for the journal line will posted (for example, a cash account for cash purchases).';
                    Visible = NOT IsSimplePage;

                    trigger OnValidate()
                    begin
                        GenJnlManagement.GetAccounts(Rec, AccName, BalAccName);
                        ShowShortcutDimCode(ShortcutDimCode);
                        CurrPage.SaveRecord();
                    end;
                }
                field("Bal. Gen. Posting Type"; Rec."Bal. Gen. Posting Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general posting type associated with the balancing account that will be used when you post the entry on the journal line.';
                    Visible = NOT IsSimplePage;

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                    end;
                }
                field("Bal. Gen. Bus. Posting Group"; Rec."Bal. Gen. Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general business posting group code associated with the balancing account that will be used when you post the entry.';
                    Visible = NOT IsSimplePage;

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                    end;
                }
                field("Bal. Gen. Prod. Posting Group"; Rec."Bal. Gen. Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general product posting group code associated with the balancing account that will be used when you post the entry.';
                    Visible = NOT IsSimplePage;
                }
                field("Deferral Code"; Rec."Deferral Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the deferral template that governs how expenses or revenue are deferred to the different accounting periods when the expenses or revenue were incurred.';
                    Visible = NOT IsSimplePage;

                    trigger OnAssistEdit()
                    begin
                        CurrPage.SaveRecord();
                        Commit();
                        Rec.ShowDeferralSchedule();
                    end;
                }
                field("Job Queue Status"; Rec."Job Queue Status")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the status of a job queue entry or task that handles the posting of general journals.';
                    Visible = JobQueuesUsed;

                    trigger OnDrillDown()
                    var
                        JobQueueEntry: Record "Job Queue Entry";
                    begin
                        if "Job Queue Status" = "Job Queue Status"::" " then
                            exit;
                        JobQueueEntry.ShowStatusMsg("Job Queue Entry ID");
                    end;
                }
                field("Bal. VAT Bus. Posting Group"; Rec."Bal. VAT Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the VAT business posting group that will be used when you post the entry on the journal line.';
                    Visible = false;
                }
                field("Bal. VAT Prod. Posting Group"; Rec."Bal. VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the VAT product posting group that will be used when you post the entry on the journal line.';
                    Visible = false;
                }
                field("Bill-to/Pay-to No."; Rec."Bill-to/Pay-to No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the bill-to customer or pay-to vendor that the entry is linked to.';
                    Visible = false;
                }
                field("Ship-to/Order Address Code"; Rec."Ship-to/Order Address Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the address code of the ship-to customer or order-from vendor that the entry is linked to.';
                    Visible = false;
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code that represents the payments terms that apply to the entry on the journal line.';
                    Visible = false;
                }
                field("Applied Automatically"; Rec."Applied Automatically")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies that the general journal line has been automatically applied with a matching payment using the Apply Automatically function.';
                    Visible = false;
                }
                field(Applied; IsApplied())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Applied';
                    ToolTip = 'Specifies if the record on the line has been applied.';
                    Visible = false;
                }
                field("Applies-to Doc. Type"; Rec."Applies-to Doc. Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of the posted document that this document or journal line will be applied to when you post, for example to register payment.';
                    Visible = false;
                }
                field("Applies-to Doc. No."; Rec."Applies-to Doc. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the posted document that this document or journal line will be applied to when you post, for example to register payment.';
                    Visible = false;
                }
                field("Applies-to ID"; Rec."Applies-to ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ID of entries that will be applied to when you choose the Apply Entries action.';
                    Visible = false;
                }
                field("On Hold"; Rec."On Hold")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the journal line has been invoiced, and you execute the payment suggestions batch job, or you create a finance charge memo or reminder.';
                    Visible = false;
                }
                field("Bank Payment Type"; Rec."Bank Payment Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for the payment type to be used for the entry on the payment journal line.';
                    Visible = false;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the reason code that has been entered on the journal lines.';
                    Visible = false;
                }
                field(Correction; Correction)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry as a corrective entry. You can use the field if you need to post a corrective entry to an account.';
                    Visible = NOT IsSimplePage;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = Comments;
                    ToolTip = 'Specifies a comment about the activity on the journal line. Note that the comment is not carried forward to posted entries.';
                    Visible = NOT IsSimplePage;
                }
                field("Direct Debit Mandate ID"; Rec."Direct Debit Mandate ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the identification of the direct-debit mandate that is being used on the journal lines to process a direct debit collection.';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = DimVisible1;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = DimVisible2;
                }
                field(ShortcutDimCode3; ShortcutDimCode[3])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible3;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(3, ShortcutDimCode[3]);

                        OnAfterValidateShortcutDimCode(Rec, ShortcutDimCode, 3);
                    end;
                }
                field(ShortcutDimCode4; ShortcutDimCode[4])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible4;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(4, ShortcutDimCode[4]);

                        OnAfterValidateShortcutDimCode(Rec, ShortcutDimCode, 4);
                    end;
                }
                field(ShortcutDimCode5; ShortcutDimCode[5])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible5;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(5, ShortcutDimCode[5]);

                        OnAfterValidateShortcutDimCode(Rec, ShortcutDimCode, 5);
                    end;
                }
                field(ShortcutDimCode6; ShortcutDimCode[6])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(6),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible6;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(6, ShortcutDimCode[6]);

                        OnAfterValidateShortcutDimCode(Rec, ShortcutDimCode, 6);
                    end;
                }
                field(ShortcutDimCode7; ShortcutDimCode[7])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(7),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible7;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(7, ShortcutDimCode[7]);

                        OnAfterValidateShortcutDimCode(Rec, ShortcutDimCode, 7);
                    end;
                }
                field(ShortcutDimCode8; ShortcutDimCode[8])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible8;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(8, ShortcutDimCode[8]);

                        OnAfterValidateShortcutDimCode(Rec, ShortcutDimCode, 8);
                    end;
                }
            }
            group(Control30)
            {
                ShowCaption = false;
                fixed(Control1901776101)
                {
                    ShowCaption = false;
                    group("Number of Lines")
                    {
                        Caption = 'Number of Lines';
                        field(NumberOfJournalRecords; NumberOfRecords)
                        {
                            ApplicationArea = All;
                            AutoFormatType = 1;
                            ShowCaption = false;
                            Editable = false;
                            ToolTip = 'Specifies the number of lines in the current journal batch.';
                        }
                    }
                    group("Account Name")
                    {
                        Caption = 'Account Name';
                        Visible = false;
                        field(AccName; AccName)
                        {
                            ApplicationArea = Basic, Suite;
                            Editable = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the name of the account.';
                        }
                    }
                    group("Bal. Account Name")
                    {
                        Caption = 'Bal. Account Name';
                        Visible = false;
                        field(BalAccName; BalAccName)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Bal. Account Name';
                            Editable = false;
                            ToolTip = 'Specifies the name of the balancing account that has been entered on the journal line.';
                        }
                    }
                    group("Total Debit")
                    {
                        Caption = 'Total Debit';
                        Visible = IsSimplePage;
                        field(DisplayTotalDebit; GetTotalDebitAmt())
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Total Debit';
                            Editable = false;
                            ToolTip = 'Specifies the total debit amount in the general journal.';
                        }
                    }
                    group("Total Credit")
                    {
                        Caption = 'Total Credit';
                        Visible = IsSimplePage;
                        field(DisplayTotalCredit; GetTotalCreditAmt())
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Total Credit';
                            Editable = false;
                            ToolTip = 'Specifies the total credit amount in the general journal.';
                        }
                    }
                    group(Control1902759701)
                    {
                        Caption = 'Balance';
                        field(Balance; Balance)
                        {
                            ApplicationArea = All;
                            AutoFormatType = 1;
                            Caption = 'Balance';
                            Editable = false;
                            ToolTip = 'Specifies the balance that has accumulated in the general journal on the line where the cursor is.';
                            Visible = BalanceVisible;
                        }
                    }
                    group("Total Balance")
                    {
                        Caption = 'Total Balance';
                        field(TotalBalance; TotalBalance)
                        {
                            ApplicationArea = All;
                            AutoFormatType = 1;
                            Caption = 'Total Balance';
                            Editable = false;
                            ToolTip = 'Specifies the total balance in the general journal.';
                            Visible = TotalBalanceVisible;
                        }
                    }
                }
            }
        }
        area(factboxes)
        {
            part(JournalErrorsFactBox; "Journal Errors FactBox")
            {
                ApplicationArea = Basic, Suite;
                ShowFilter = false;
                Visible = BackgroundErrorCheck;
                SubPageLink = "Journal Template Name" = FIELD("Journal Template Name"),
                              "Journal Batch Name" = FIELD("Journal Batch Name"),
                              "Line No." = FIELD("Line No.");
            }
            part(JournalLineDetails; "Journal Line Details FactBox")
            {
                ApplicationArea = Basic, Suite;
                Visible = not IsSimplePage;
                SubPageLink = "Journal Template Name" = FIELD("Journal Template Name"),
                              "Journal Batch Name" = FIELD("Journal Batch Name"),
                              "Line No." = FIELD("Line No.");
            }
            part(Control1900919607; "Dimension Set Entries FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Dimension Set ID" = FIELD("Dimension Set ID");
            }
            part(IncomingDocAttachFactBox; "Incoming Doc. Attach. FactBox")
            {
                ApplicationArea = Basic, Suite;
                ShowFilter = false;
            }
            part(WorkflowStatusBatch; "Workflow Status FactBox")
            {
                ApplicationArea = Suite;
                Caption = 'Batch Workflows';
                Editable = false;
                Enabled = false;
                ShowFilter = false;
                Visible = ShowWorkflowStatusOnBatch;
            }
            part(WorkflowStatusLine; "Workflow Status FactBox")
            {
                ApplicationArea = Suite;
                Caption = 'Line Workflows';
                Editable = false;
                Enabled = false;
                ShowFilter = false;
                Visible = ShowWorkflowStatusOnLine;
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        ShowDimensions();
                        CurrPage.SaveRecord();
                    end;
                }
            }
            group("A&ccount")
            {
                Caption = 'A&ccount';
                Image = ChartOfAccounts;
                action(Card)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Card';
                    Image = EditLines;
                    RunObject = Codeunit "Gen. Jnl.-Show Card";
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'View or change detailed information about the record on the document or journal line.';
                }
                action("Ledger E&ntries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ledger E&ntries';
                    Image = GLRegisters;
                    RunObject = Codeunit "Gen. Jnl.-Show Entries";
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View the history of transactions that have been posted for the selected record.';
                }
            }
            action(Approvals)
            {
                AccessByPermission = TableData "Approval Entry" = R;
                ApplicationArea = Suite;
                Caption = 'Approvals';
                Image = Approvals;
                ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';

                trigger OnAction()
                var
                    [SecurityFiltering(SecurityFilter::Filtered)]
                    GenJournalLine: Record "Gen. Journal Line";
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    GetCurrentlySelectedLines(GenJournalLine);
                    ApprovalsMgmt.ShowJournalApprovalEntries(GenJournalLine);
                end;
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Renumber Document Numbers")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Renumber Document Numbers';
                    Image = EditLines;
                    ToolTip = 'Resort the numbers in the Document No. column to avoid posting errors because the document numbers are not in sequence. Entry applications and line groupings are preserved.';
                    Visible = NOT IsSimplePage;

                    trigger OnAction()
                    begin
                        RenumberDocumentNo();
                    end;
                }
                action("Insert Conv. LCY Rndg. Lines")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Insert Conv. LCY Rndg. Lines';
                    Image = InsertCurrency;
                    RunObject = Codeunit "Adjust Gen. Journal Balance";
                    ToolTip = 'Insert a rounding correction line in the journal. This rounding correction line will balance in LCY when amounts in the foreign currency also balance. You can then post the journal.';
                }
                separator("-")
                {
                    Caption = '-';
                }
                action(GetStandardJournals)
                {
                    ApplicationArea = Suite;
                    Caption = '&Get Standard Journals';
                    Ellipsis = true;
                    Image = GetStandardJournal;
                    ToolTip = 'Select a standard general journal to be inserted.';

                    trigger OnAction()
                    var
                        StdGenJnl: Record "Standard General Journal";
                    begin
                        StdGenJnl.FilterGroup := 2;
                        StdGenJnl.SetRange("Journal Template Name", "Journal Template Name");
                        StdGenJnl.FilterGroup := 0;

                        if PAGE.RunModal(PAGE::"Standard General Journals", StdGenJnl) = ACTION::LookupOK then begin
                            if IsSimplePage then
                                // If this page is opend in simple mode then use the current doc no. for every G/L lines that are created
                                // from standard journal.
                                StdGenJnl.CreateGenJnlFromStdJnlWithDocNo(StdGenJnl, CurrentJnlBatchName, CurrentDocNo, CurrentPostingDate)
                            else
                                StdGenJnl.CreateGenJnlFromStdJnl(StdGenJnl, CurrentJnlBatchName);
                            Message(Text000, StdGenJnl.Code);
                        end;

                        CurrPage.Update(true);
                    end;
                }
                action(SaveAsStandardJournal)
                {
                    ApplicationArea = Suite;
                    Caption = '&Save as Standard Journal';
                    Ellipsis = true;
                    Image = SaveasStandardJournal;
                    ToolTip = 'Define the journal lines that you want to use later as a standard journal before you post the journal.';

                    trigger OnAction()
                    var
                        [SecurityFiltering(SecurityFilter::Filtered)]
                        GenJnlBatch: Record "Gen. Journal Batch";
                        [SecurityFiltering(SecurityFilter::Filtered)]
                        GeneralJnlLines: Record "Gen. Journal Line";
                        StdGenJnl: Record "Standard General Journal";
                        SaveAsStdGenJnl: Report "Save as Standard Gen. Journal";
                    begin
                        GeneralJnlLines.SetFilter("Journal Template Name", "Journal Template Name");
                        GeneralJnlLines.SetFilter("Journal Batch Name", CurrentJnlBatchName);
                        CurrPage.SetSelectionFilter(GeneralJnlLines);
                        GeneralJnlLines.CopyFilters(Rec);

                        GenJnlBatch.Get("Journal Template Name", CurrentJnlBatchName);
                        SaveAsStdGenJnl.Initialise(GeneralJnlLines, GenJnlBatch);
                        SaveAsStdGenJnl.RunModal();
                        if not SaveAsStdGenJnl.GetStdGeneralJournal(StdGenJnl) then
                            exit;

                        Message(Text001, StdGenJnl.Code);
                    end;
                }
                action("Test Report")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;
                    ToolTip = 'View a test report so that you can find and correct any errors before you perform the actual posting of the journal or document.';

                    trigger OnAction()
                    begin
                        ReportPrint.PrintGenJnlLine(Rec);
                    end;
                }
                action(Post)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'P&ost';
                    Image = PostOrder;
                    ShortCutKey = 'F9';
                    ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';

                    trigger OnAction()
                    begin
                        SendToPosting(Codeunit::"Gen. Jnl.-Post");
                        CurrentJnlBatchName := GetRangeMax("Journal Batch Name");
                        if IsSimplePage then
                            if GeneralLedgerSetup."Post with Job Queue" then
                                NewDocumentNo()
                            else
                                SetDataForSimpleModeOnPost();
                        SetJobQueueVisibility();
                        CurrPage.Update(false);
                    end;
                }
                action(Preview)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Preview Posting';
                    Image = ViewPostedOrder;
                    ShortCutKey = 'Ctrl+Alt+F9';
                    ToolTip = 'Review the different types of entries that will be created when you post the document or journal.';

                    trigger OnAction()
                    var
                        GenJnlPost: Codeunit "Gen. Jnl.-Post";
                    begin
                        GenJnlPost.Preview(Rec);
                    end;
                }
                action(PostAndPrint)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post and &Print';
                    Image = PostPrint;
                    ShortCutKey = 'Shift+F9';
                    ToolTip = 'Finalize and prepare to print the document or journal. The values and quantities are posted to the related accounts. A report request window where you can specify what to include on the print-out.';

                    trigger OnAction()
                    begin
                        SendToPosting(Codeunit::"Gen. Jnl.-Post+Print");
                        CurrentJnlBatchName := GetRangeMax("Journal Batch Name");
                        if IsSimplePage then
                            if GeneralLedgerSetup."Post & Print with Job Queue" then
                                NewDocumentNo()
                            else
                                SetDataForSimpleModeOnPost();
                        SetJobQueueVisibility();
                        CurrPage.Update(false);
                    end;
                }
                action("Remove From Job Queue")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Remove From Job Queue';
                    Image = RemoveLine;
                    ToolTip = 'Remove the scheduled processing of this record from the job queue.';
                    Visible = JobQueueVisible;

                    trigger OnAction()
                    begin
                        CancelBackgroundPosting();
                        SetJobQueueVisibility();
                        CurrPage.Update(false);
                    end;
                }
                action(DeferralSchedule)
                {
                    ApplicationArea = Suite;
                    Caption = 'Deferral Schedule';
                    Image = PaymentPeriod;
                    ToolTip = 'View or edit the deferral schedule that governs how expenses or revenue are deferred to different accounting periods when the journal line is posted.';

                    trigger OnAction()
                    begin
                        Rec.ShowDeferralSchedule();
                    end;
                }
                group(IncomingDocument)
                {
                    Caption = 'Incoming Document';
                    Image = Documents;
                    action(IncomingDocCard)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'View Incoming Document';
                        Enabled = HasIncomingDocument;
                        Image = ViewOrder;
                        ToolTip = 'View any incoming document records and file attachments that exist for the entry or document.';

                        trigger OnAction()
                        var
                            IncomingDocument: Record "Incoming Document";
                        begin
                            IncomingDocument.ShowCardFromEntryNo("Incoming Document Entry No.");
                        end;
                    }
                    action(SelectIncomingDoc)
                    {
                        AccessByPermission = TableData "Incoming Document" = R;
                        ApplicationArea = Basic, Suite;
                        Caption = 'Select Incoming Document';
                        Image = SelectLineToApply;
                        ToolTip = 'Select an incoming document record and file attachment that you want to link to the entry or document.';

                        trigger OnAction()
                        var
                            IncomingDocument: Record "Incoming Document";
                        begin
                            Validate("Incoming Document Entry No.", IncomingDocument.SelectIncomingDocument("Incoming Document Entry No.", RecordId));
                        end;
                    }
                    action(IncomingDocAttachFile)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Create Incoming Document from File';
                        Ellipsis = true;
                        Enabled = NOT HasIncomingDocument;
                        Image = Attach;
                        ToolTip = 'Create an incoming document record by selecting a file to attach, and then link the incoming document record to the entry or document.';

                        trigger OnAction()
                        var
                            IncomingDocumentAttachment: Record "Incoming Document Attachment";
                        begin
                            IncomingDocumentAttachment.NewAttachmentFromGenJnlLine(Rec);
                        end;
                    }
                    action(RemoveIncomingDoc)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Remove Incoming Document';
                        Enabled = HasIncomingDocument;
                        Image = RemoveLine;
                        ToolTip = 'Remove any incoming document records and file attachments.';

                        trigger OnAction()
                        var
                            IncomingDocument: Record "Incoming Document";
                        begin
                            if IncomingDocument.Get("Incoming Document Entry No.") then
                                IncomingDocument.RemoveLinkToRelatedRecord();
                            "Incoming Document Entry No." := 0;
                            Modify(true);
                        end;
                    }
                }
            }
            group("B&ank")
            {
                Caption = 'B&ank';
                action(ImportBankStatement)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Import Bank Statement';
                    Image = Import;
                    ToolTip = 'Import electronic bank statements from your bank to populate with data about actual bank transactions.';
                    Visible = false;

                    trigger OnAction()
                    begin
                        if FindLast() then;
                        ImportBankStatement();
                    end;
                }
                action(ShowStatementLineDetails)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bank Statement Details';
                    Image = ExternalDocument;
                    RunObject = Page "Bank Statement Line Details";
                    RunPageLink = "Data Exch. No." = FIELD("Data Exch. Entry No."),
                                  "Line No." = FIELD("Data Exch. Line No.");
                    ToolTip = 'View the content of the imported bank statement file, such as account number, posting date, and amounts.';
                    Visible = false;
                }
                action(Reconcile)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Reconcile';
                    Image = Reconcile;
                    ShortCutKey = 'Ctrl+F11';
                    ToolTip = 'View the balances on bank accounts that are marked for reconciliation, usually liquid accounts.';

                    trigger OnAction()
                    begin
                        GLReconcile.SetGenJnlLine(Rec);
                        GLReconcile.Run();
                    end;
                }
            }
            group(Application)
            {
                Caption = 'Application';
                action("Apply Entries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Apply Entries';
                    Ellipsis = true;
                    Enabled = ApplyEntriesActionEnabled;
                    Image = ApplyEntries;
                    RunObject = Codeunit "Gen. Jnl.-Apply";
                    ShortCutKey = 'Shift+F11';
                    ToolTip = 'Apply the payment amount on a journal line to a sales or purchase document that was already posted for a customer or vendor. This updates the amount on the posted document, and the document can either be partially paid, or closed as paid or refunded.';
                }
                action(Match)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Apply Automatically';
                    Image = MapAccounts;
                    RunObject = Codeunit "Match General Journal Lines";
                    ToolTip = 'Apply payments to their related open entries based on data matches between bank transaction text and entry information.';
                    Visible = false;
                }
                action(AddMappingRule)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Map Text to Account';
                    Image = CheckRulesSyntax;
                    ToolTip = 'Associate text on payments with debit, credit, and balancing accounts, so payments are posted to the accounts when you post payments. The payments are not applied to invoices or credit memos, and are suited for recurring cash receipts or expenses.';
                    Visible = false;

                    trigger OnAction()
                    var
                        TextToAccMapping: Record "Text-to-Account Mapping";
                    begin
                        TextToAccMapping.InsertRec(Rec);
                    end;
                }
            }
            group("Payro&ll")
            {
                Caption = 'Payro&ll';
                action(ImportPayrollFile)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Import Payroll File';
                    Image = Import;
                    ToolTip = 'Import a payroll file that you select.';
                    Visible = false;

                    trigger OnAction()
                    var
                        ImportPayrollTransaction: Codeunit "Import Payroll Transaction";
                        FeatureTelemetry: Codeunit "Feature Telemetry";
                        PayRollTok: Label 'DK payroll service', Locked = true;
                    begin
                        FeatureTelemetry.LogUptake('0000H8Z', PayRollTok, Enum::"Feature Uptake Status"::"Used");
                        GeneralLedgerSetup.TestField("Payroll Trans. Import Format");
                        if FindLast() then;
                        ImportPayrollTransaction.SelectAndImportPayrollDataToGL(Rec, GeneralLedgerSetup."Payroll Trans. Import Format");
                        FeatureTelemetry.LogUsage('0000H90', PayRollTok, 'Payroll imported');
                    end;
                }
                action(ImportPayrollTransactions)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Import Payroll Transactions';
                    Image = ImportChartOfAccounts;
                    ToolTip = 'Add journal lines based on transactions from your payroll service provider.';
                    Visible = ImportPayrollTransactionsAvailable;

                    trigger OnAction()
                    begin
                        if FindLast() then;
                        PayrollManagement.ImportPayroll(Rec);
                    end;
                }
            }
            group("Request Approval")
            {
                Caption = 'Request Approval';
                group(SendApprovalRequest)
                {
                    Caption = 'Send Approval Request';
                    Image = SendApprovalRequest;
                    action(SendApprovalRequestJournalBatch)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Journal Batch';
                        Enabled = NOT OpenApprovalEntriesOnBatchOrAnyJnlLineExist AND CanRequestFlowApprovalForBatchAndAllLines;
                        Image = SendApprovalRequest;
                        ToolTip = 'Send all journal lines for approval, also those that you may not see because of filters.';

                        trigger OnAction()
                        var
                            ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        begin
                            ApprovalsMgmt.TrySendJournalBatchApprovalRequest(Rec);
                            SetControlAppearanceFromBatch();
                            SetControlAppearance();
                        end;
                    }
                    action(SendApprovalRequestJournalLine)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Selected Journal Lines';
                        Enabled = NOT OpenApprovalEntriesOnBatchOrCurrJnlLineExist AND CanRequestFlowApprovalForBatchAndCurrentLine;
                        Image = SendApprovalRequest;
                        ToolTip = 'Send selected journal lines for approval.';

                        trigger OnAction()
                        var
                            [SecurityFiltering(SecurityFilter::Filtered)]
                            GenJournalLine: Record "Gen. Journal Line";
                            ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        begin
                            GetCurrentlySelectedLines(GenJournalLine);
                            ApprovalsMgmt.TrySendJournalLineApprovalRequests(GenJournalLine);
                            SetControlAppearanceFromBatch();
                        end;
                    }
                }
                group(CancelApprovalRequest)
                {
                    Caption = 'Cancel Approval Request';
                    Image = Cancel;
                    action(CancelApprovalRequestJournalBatch)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Journal Batch';
                        Enabled = CanCancelApprovalForJnlBatch OR CanCancelFlowApprovalForBatch;
                        Image = CancelApprovalRequest;
                        ToolTip = 'Cancel sending all journal lines for approval, also those that you may not see because of filters.';

                        trigger OnAction()
                        var
                            ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        begin
                            ApprovalsMgmt.TryCancelJournalBatchApprovalRequest(Rec);
                            SetControlAppearance();
                            SetControlAppearanceFromBatch();
                        end;
                    }
                    action(CancelApprovalRequestJournalLine)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Selected Journal Lines';
                        Enabled = CanCancelApprovalForJnlLine OR CanCancelFlowApprovalForLine;
                        Image = CancelApprovalRequest;
                        ToolTip = 'Cancel sending selected journal lines for approval.';

                        trigger OnAction()
                        var
                            [SecurityFiltering(SecurityFilter::Filtered)]
                            GenJournalLine: Record "Gen. Journal Line";
                            ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        begin
                            GetCurrentlySelectedLines(GenJournalLine);
                            ApprovalsMgmt.TryCancelJournalLineApprovalRequests(GenJournalLine);
                        end;
                    }
                }
                customaction(CreateFlowFromTemplate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Create a Power Automate approval flow';
                    ToolTip = 'Create a new flow in Power Automate from a list of relevant flow templates.';
#if not CLEAN22
                    Visible = IsSaaS and PowerAutomateTemplatesEnabled;
#else
                    Visible = IsSaaS;
#endif
                    CustomActionType = FlowTemplateGallery;
                    FlowTemplateCategoryName = 'd365bc_approval_generalJournal';
                }
#if not CLEAN22
                action(CreateFlow)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Create a Power Automate approval flow';
                    Image = Flow;
                    ToolTip = 'Create a new flow in Power Automate from a list of relevant flow templates.';
                    Visible = IsSaaS and not PowerAutomateTemplatesEnabled;
                    ObsoleteReason = 'This action will be handled by platform as part of the CreateFlowFromTemplate customaction';
                    ObsoleteState = Pending;
                    ObsoleteTag = '22.0';

                    trigger OnAction()
                    var
                        FlowServiceManagement: Codeunit "Flow Service Management";
                        FlowTemplateSelector: Page "Flow Template Selector";
                    begin
                        // Opens page 6400 where the user can use filtered templates to create new flows.
                        FlowTemplateSelector.SetSearchText(FlowServiceManagement.GetJournalTemplateFilter());
                        FlowTemplateSelector.Run();
                    end;
                }
#endif
#if not CLEAN21
                action(SeeFlows)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'See my flows';
                    Image = Flow;
                    RunObject = Page "Flow Selector";
                    ToolTip = 'View and configure Power Automate flows that you created.';
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'This action has been moved to the tab dedicated to Power Automate';
                    ObsoleteTag = '21.0';
                }
#endif
            }
            group(Approval)
            {
                Caption = 'Approval';
                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    ToolTip = 'Approve the requested changes.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.ApproveGenJournalLineRequest(Rec);
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Reject;
                    ToolTip = 'Reject the approval request.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.RejectGenJournalLineRequest(Rec);
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = All;
                    Caption = 'Delegate';
                    Image = Delegate;
                    ToolTip = 'Delegate the approval to a substitute approver.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.DelegateGenJournalLineRequest(Rec);
                    end;
                }
                action(Comments)
                {
                    ApplicationArea = All;
                    Caption = 'Comments';
                    Image = ViewComments;
                    ToolTip = 'View or add comments for the record.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        GenJournalBatch: Record "Gen. Journal Batch";
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if OpenApprovalEntriesOnJnlLineExist then
                            ApprovalsMgmt.GetApprovalComment(Rec)
                        else
                            if OpenApprovalEntriesOnJnlBatchExist then
                                if GenJournalBatch.Get("Journal Template Name", "Journal Batch Name") then
                                    ApprovalsMgmt.GetApprovalComment(GenJournalBatch);
                    end;
                }
            }
            group("Opening Balance")
            {
                Caption = 'Opening Balance';
                group("Prepare journal")
                {
                    Caption = 'Prepare journal';
                    Image = Journals;
                    action("G/L Accounts Opening balance ")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'G/L Accounts Opening balance';
                        Image = TransferToGeneralJournal;
                        ToolTip = 'Creates general journal line per G/L account to enable manual entry of G/L account open balances during the setup of a new company';

                        trigger OnAction()
                        var
                            GLAccount: Record "G/L Account";
                            CreateGLAccJournalLines: Report "Create G/L Acc. Journal Lines";
                            DocumentTypes: Option;
                        begin
                            GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
                            GLAccount.SetRange("Income/Balance", GLAccount."Income/Balance"::"Balance Sheet");
                            GLAccount.SetRange("Direct Posting", true);
                            GLAccount.SetRange(Blocked, false);
                            CreateGLAccJournalLines.SetTableView(GLAccount);
                            CreateGLAccJournalLines.InitializeRequest(DocumentTypes, GetPostingDate(), "Journal Template Name", "Journal Batch Name", '');
                            CreateGLAccJournalLines.UseRequestPage(false);
                            CreateGLAccJournalLines.SetDefaultDocumentNo(CurrentDocNo);
                            Commit();  // Commit is required for Create Lines.
                            CreateGLAccJournalLines.Run();
                        end;
                    }
                    action("Customers Opening balance")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Customers Opening balance';
                        Image = TransferToGeneralJournal;
                        ToolTip = 'Creates general journal line per Customer to enable manual entry of Customer open balances during the setup of a new company';

                        trigger OnAction()
                        var
                            Customer: Record Customer;
                            CreateCustomerJournalLines: Report "Create Customer Journal Lines";
                            DocumentTypes: Option;
                            PostingDate: Date;
                        begin
                            Customer.SetRange(Blocked, Customer.Blocked::" ");
                            CreateCustomerJournalLines.SetTableView(Customer);
                            PostingDate := GetPostingDate();
                            CreateCustomerJournalLines.InitializeRequest(DocumentTypes, PostingDate, PostingDate);
                            CreateCustomerJournalLines.InitializeRequestTemplate("Journal Template Name", "Journal Batch Name", '');
                            CreateCustomerJournalLines.UseRequestPage(false);
                            CreateCustomerJournalLines.SetDefaultDocumentNo(CurrentDocNo);
                            Commit();  // Commit is required for Create Lines.
                            CreateCustomerJournalLines.Run();
                        end;
                    }
                    action("Vendors Opening balance")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Vendors Opening balance';
                        Image = TransferToGeneralJournal;
                        ToolTip = 'Creates a general journal line for each vendor. This lets you manually enter open balances for vendors when you set up a new company.';

                        trigger OnAction()
                        var
                            Vendor: Record Vendor;
                            CreateVendorJournalLines: Report "Create Vendor Journal Lines";
                            DocumentTypes: Option;
                            PostingDate: Date;
                        begin
                            Vendor.SetRange(Blocked, Vendor.Blocked::" ");
                            CreateVendorJournalLines.SetTableView(Vendor);
                            PostingDate := GetPostingDate();
                            CreateVendorJournalLines.InitializeRequest(DocumentTypes, PostingDate, PostingDate);
                            CreateVendorJournalLines.InitializeRequestTemplate("Journal Template Name", "Journal Batch Name", '');
                            CreateVendorJournalLines.UseRequestPage(false);
                            CreateVendorJournalLines.SetDefaultDocumentNo(CurrentDocNo);
                            Commit();  // Commit is required for Create Lines.
                            CreateVendorJournalLines.Run();
                        end;
                    }
                }
            }
            group("Page")
            {
                Caption = 'Page';
                action(EditInExcel)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Edit in Excel';
                    Image = Excel;
                    ToolTip = 'Send the data in the journal to an Excel file for analysis or editing.';
                    Visible = IsSaaSExcelAddinEnabled;
                    AccessByPermission = System "Allow Action Export To Excel" = X;

                    trigger OnAction()
                    var
                        ODataUtility: Codeunit ODataUtility;
                    begin
                        ODataUtility.EditJournalWorksheetInExcel(CurrPage.Caption, CurrPage.ObjectId(false), "Journal Batch Name", "Journal Template Name");
                    end;
                }
                action(PreviousDocNumberTrx)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Previous Doc No.';
                    Image = PreviousRecord;
                    ToolTip = 'Navigate to previous document number for current batch.';
                    Visible = IsSimplePage;

                    trigger OnAction()
                    begin
                        IterateDocNumbers('+', -1);
                    end;
                }
                action(NextDocNumberTrx)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Next Doc No.';
                    Image = NextRecord;
                    ToolTip = 'Navigate to next document number for current batch.';
                    Visible = IsSimplePage;

                    trigger OnAction()
                    begin
                        IterateDocNumbers('-', 1);
                    end;
                }
                action(ClassicView)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show More Columns';
                    Image = SetupColumns;
                    ToolTip = 'View all available fields. Fields not frequently used are currently hidden.';
                    Visible = IsSimplePage;

                    trigger OnAction()
                    begin
                        // set journal preference for this page to be NOT simple mode (classic mode)
                        CurrPage.Close();
                        GenJnlManagement.SetJournalSimplePageModePreference(false, PAGE::"General Journal");
                        GenJnlManagement.SetLastViewedJournalBatchName(PAGE::"General Journal", CurrentJnlBatchName);
                        PAGE.Run(PAGE::"General Journal");
                    end;
                }
                action(SimpleView)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show Fewer Columns';
                    Image = SetupList;
                    ToolTip = 'Hide fields that are not frequently used.';
                    Visible = NOT IsSimplePage;

                    trigger OnAction()
                    begin
                        // set journal preference for this page to be simple mode
                        CurrPage.Close();
                        GenJnlManagement.SetJournalSimplePageModePreference(true, PAGE::"General Journal");
                        GenJnlManagement.SetLastViewedJournalBatchName(PAGE::"General Journal", CurrentJnlBatchName);
                        PAGE.Run(PAGE::"General Journal");
                    end;
                }
                action("New Doc No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'New Document Number';
                    Image = New;
                    ToolTip = 'Creates a new document number.';
                    Visible = IsSimplePage;

                    trigger OnAction()
                    begin
                        NewDocumentNo();
                    end;
                }
                group(Errors)
                {
                    Caption = 'Issues';
                    Image = ErrorLog;
                    Visible = BackgroundErrorCheck;
                    action(ShowLinesWithErrors)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Lines with Issues';
                        Image = Error;
                        Visible = BackgroundErrorCheck;
                        Enabled = not ShowAllLinesEnabled;
                        ToolTip = 'View a list of journal lines that have issues before you post the journal.';

                        trigger OnAction()
                        begin
                            SwitchLinesWithErrorsFilter(ShowAllLinesEnabled);
                        end;
                    }
                    action(ShowAllLines)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show All Lines';
                        Image = ExpandAll;
                        Visible = BackgroundErrorCheck;
                        Enabled = ShowAllLinesEnabled;
                        ToolTip = 'View all journal lines, including lines with and without issues.';

                        trigger OnAction()
                        begin
                            SwitchLinesWithErrorsFilter(ShowAllLinesEnabled);
                        end;
                    }
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';

                group(Category_Category9)
                {
                    Caption = 'Post/Print', Comment = 'Generated from the PromotedActionCategories property index 8.';
                    ShowAs = SplitButton;

#if not CLEAN21
                    actionref("Remove From Job Queue_Promoted"; "Remove From Job Queue")
                    {
                        Visible = false;
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Action is being demoted based on overall low usage.';
                        ObsoleteTag = '21.0';
                    }
#endif
                    actionref(Post_Promoted; Post)
                    {
                    }
                    actionref(Preview_Promoted; Preview)
                    {
                    }
                    actionref(PostAndPrint_Promoted; PostAndPrint)
                    {
                    }
                    actionref("Test Report_Promoted"; "Test Report")
                    {
                    }
                }
                actionref(GetStandardJournals_Promoted; GetStandardJournals)
                {
                }
                actionref("Renumber Document Numbers_Promoted"; "Renumber Document Numbers")
                {
                }
                actionref(Reconcile_Promoted; Reconcile)
                {
                }
                actionref("Apply Entries_Promoted"; "Apply Entries")
                {
                }
            }
            group(Category_Category7)
            {
                Caption = 'Approve', Comment = 'Generated from the PromotedActionCategories property index 6.';

                actionref(Approve_Promoted; Approve)
                {
                }
                actionref(Reject_Promoted; Reject)
                {
                }
                actionref(Comments_Promoted; Comments)
                {
                }
                actionref(Delegate_Promoted; Delegate)
                {
                }
            }
            group("Category_Request Approval")
            {
                Caption = 'Request Approval';

                group("Category_Send Approval Request")
                {
                    Caption = 'Send Approval Request';

                    actionref(SendApprovalRequestJournalBatch_Promoted; SendApprovalRequestJournalBatch)
                    {
                    }
                    actionref(SendApprovalRequestJournalLine_Promoted; SendApprovalRequestJournalLine)
                    {
                    }
                }
                group("Category_Cancel Approval Request")
                {
                    Caption = 'Cancel Approval Request';

                    actionref(CancelApprovalRequestJournalBatch_Promoted; CancelApprovalRequestJournalBatch)
                    {
                    }
                    actionref(CancelApprovalRequestJournalLine_Promoted; CancelApprovalRequestJournalLine)
                    {
                    }
                }
            }
            group(Category_Category4)
            {
                Caption = 'Bank', Comment = 'Generated from the PromotedActionCategories property index 3.';

                actionref(ImportBankStatement_Promoted; ImportBankStatement)
                {
                }
                actionref(ShowStatementLineDetails_Promoted; ShowStatementLineDetails)
                {
                }
            }
            group(Category_Category5)
            {
                Caption = 'Application', Comment = 'Generated from the PromotedActionCategories property index 4.';

                actionref(AddMappingRule_Promoted; AddMappingRule)
                {
                }
                actionref(Match_Promoted; Match)
                {
                }
            }
            group(Category_Category6)
            {
                Caption = 'Payroll', Comment = 'Generated from the PromotedActionCategories property index 5.';

                actionref(ImportPayrollFile_Promoted; ImportPayrollFile)
                {
                }
                actionref(ImportPayrollTransactions_Promoted; ImportPayrollTransactions)
                {
                }
            }
            group(Category_Category10)
            {
                Caption = 'Line', Comment = 'Generated from the PromotedActionCategories property index 9.';

                actionref(Dimensions_Promoted; Dimensions)
                {
                }
                actionref(Approvals_Promoted; Approvals)
                {
                }
            }
            group(Category_Category11)
            {
                Caption = 'Account', Comment = 'Generated from the PromotedActionCategories property index 10.';

#if not CLEAN21
                actionref(Card_Promoted; Card)
                {
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Action is being demoted based on overall low usage.';
                    ObsoleteTag = '21.0';
                }
#endif
#if not CLEAN21
                actionref("Ledger E&ntries_Promoted"; "Ledger E&ntries")
                {
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Action is being demoted based on overall low usage.';
                    ObsoleteTag = '21.0';
                }
#endif
            }
            group("Category_Incoming Document")
            {
                Caption = 'Incoming Document';

                actionref(IncomingDocAttachFile_Promoted; IncomingDocAttachFile)
                {
                }
                actionref(SelectIncomingDoc_Promoted; SelectIncomingDoc)
                {
                }
                actionref(IncomingDocCard_Promoted; IncomingDocCard)
                {
                }
                actionref(RemoveIncomingDoc_Promoted; RemoveIncomingDoc)
                {
                }
            }
            group(Category_Category8)
            {
                Caption = 'Page', Comment = 'Generated from the PromotedActionCategories property index 7.';

                actionref(SimpleView_Promoted; SimpleView)
                {
                }
                actionref(ClassicView_Promoted; ClassicView)
                {
                }
                actionref(NextDocNumberTrx_Promoted; NextDocNumberTrx)
                {
                }
                actionref(PreviousDocNumberTrx_Promoted; PreviousDocNumberTrx)
                {
                }
                actionref("New Doc No._Promoted"; "New Doc No.")
                {
                }
                actionref(EditInExcel_Promoted; EditInExcel)
                {
                }
                actionref(ShowLinesWithErrors_Promoted; ShowLinesWithErrors)
                {
                }
                actionref(ShowAllLines_Promoted; ShowAllLines)
                {
                }
            }
            group(Category_Report)
            {
                Caption = 'Report', Comment = 'Generated from the PromotedActionCategories property index 2.';
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        GenJnlManagement.GetAccounts(Rec, AccName, BalAccName);
        if ClientTypeManagement.GetCurrentClientType() <> CLIENTTYPE::ODataV4 then
            UpdateBalance();
        EnableApplyEntriesAction();
        SetControlAppearance();
        HasIncomingDocument := "Incoming Document Entry No." <> 0;
        CurrPage.IncomingDocAttachFactBox.PAGE.SetCurrentRecordID(RecordId);
        // PostedFromSimplePage is set to TRUE when 'POST' / 'POST+PRINT' action is executed in simple page mode.
        // It gets set to FALSE when OnNewRecord is called in the simple mode.
        // After posting we try to find the first record and filter on its document number
        // Executing LoaddataFromRecord for incomingDocAttachFactbox is also forcing this (PAG39) page to update
        // and for some reason after posting this page doesn't refresh with the filter set by POST / POST-PRINT action in simple mode.
        // To resolve this only call LoaddataFromRecord if PostedFromSimplePage is FALSE.
        if not PostedFromSimplePage then
            CurrPage.IncomingDocAttachFactBox.PAGE.LoadDataFromRecord(Rec);
        SetJobQueueVisibility();
    end;

    trigger OnAfterGetRecord()
    begin
        GenJnlManagement.GetAccounts(Rec, AccName, BalAccName);
        ShowShortcutDimCode(ShortcutDimCode);
        SetUserInteractions();
    end;

    trigger OnInit()
    var
        ClientTypeManagement: Codeunit "Client Type Management";
    begin
        OnBeforeOnInit(Rec);

        TotalBalanceVisible := true;
        BalanceVisible := true;
        AmountVisible := true;
        // Get simple / classic mode for this page except when called from a webservices (SOAP or ODATA)
        if ClientTypeManagement.GetCurrentClientType() in [CLIENTTYPE::SOAP, CLIENTTYPE::OData, CLIENTTYPE::ODataV4]
        then
            IsSimplePage := false
        else
            IsSimplePage := GenJnlManagement.GetJournalSimplePageModePreference(PAGE::"General Journal");

        GeneralLedgerSetup.Get();
        SetJobQueueVisibility();

#if not CLEAN22
        InitPowerAutomateTemplateVisibility();
#endif
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        CurrPage.IncomingDocAttachFactBox.PAGE.SetCurrentRecordID(RecordId);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        SetUserInteractions();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        UpdateBalance();
        EnableApplyEntriesAction();
        SetUpNewLine(xRec, Balance, BelowxRec);
        // set values from header for currency code, doc no. and posting date
        // for show less columns or simple page mode
        if IsSimplePage then begin
            PostedFromSimplePage := false;
            SetDataForSimpleModeOnNewRecord();
        end;
        Clear(ShortcutDimCode);
        Clear(AccName);
        SetUserInteractions();
    end;

    trigger OnOpenPage()
    var
        ServerSetting: Codeunit "Server Setting";
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
        LastGenJnlBatch: Code[10];
    begin
        IsSaaSExcelAddinEnabled := ServerSetting.GetIsSaasExcelAddinEnabled();
        VATDateEnabled := VATReportingDateMgt.IsVATDateEnabled();

        if ClientTypeManagement.GetCurrentClientType() = CLIENTTYPE::ODataV4 then
            exit;

        BalAccName := '';
        SetControlVisibility();
        SetDimensionVisibility();
        if OpenJournalFromBatch() then
            exit;

        SelectTemplate();

        OnOpenPageOnBeforeGetLastViewedJournalBatchName(CurrentJnlBatchName, GenJnlManagement);
        LastGenJnlBatch := GenJnlManagement.GetLastViewedJournalBatchName(PAGE::"General Journal");
        if LastGenJnlBatch <> '' then
            CurrentJnlBatchName := LastGenJnlBatch;
        OnOpenPageOnAfterAssignCurrentJnlBatchName(CurrentJnlBatchName);

        GenJnlManagement.OpenJnl(CurrentJnlBatchName, Rec);
        SetControlAppearanceFromBatch();

        SetDataForSimpleModeOnOpen();

        if IsSimplePage and (CurrentDocNo = '') and GenJnlManagement.IsBatchNoSeriesEmpty(CurrentJnlBatchName, Rec) then
            Message(DocumentNumberMsg);
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        GenJnlManagement: Codeunit GenJnlManagement;
        ReportPrint: Codeunit "Test Report-Print";
        PayrollManagement: Codeunit "Payroll Management";
        ClientTypeManagement: Codeunit "Client Type Management";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        JournalErrorsMgt: Codeunit "Journal Errors Mgt.";
        BackgroundErrorHandlingMgt: Codeunit "Background Error Handling Mgt.";
        ChangeExchangeRate: Page "Change Exchange Rate";
        GLReconcile: Page Reconciliation;
        CurrentJnlBatchName: Code[10];
        AccName: Text[100];
        BalAccName: Text[100];
        Balance: Decimal;
        TotalBalance: Decimal;
        NumberOfRecords: Integer;
        ShowBalance: Boolean;
        ShowTotalBalance: Boolean;
        Text000: Label 'General Journal lines have been successfully inserted from Standard General Journal %1.';
        Text001: Label 'Standard General Journal %1 has been successfully created.';
        HasIncomingDocument: Boolean;
        ApplyEntriesActionEnabled: Boolean;
        [InDataSet]
        BalanceVisible: Boolean;
        [InDataSet]
        TotalBalanceVisible: Boolean;
        StyleTxt: Text;
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesOnJnlBatchExist: Boolean;
        OpenApprovalEntriesOnJnlLineExist: Boolean;
        OpenApprovalEntriesOnBatchOrCurrJnlLineExist: Boolean;
        OpenApprovalEntriesOnBatchOrAnyJnlLineExist: Boolean;
        ShowWorkflowStatusOnBatch: Boolean;
        ShowWorkflowStatusOnLine: Boolean;
        CanCancelApprovalForJnlBatch: Boolean;
        CanCancelApprovalForJnlLine: Boolean;
        ImportPayrollTransactionsAvailable: Boolean;
        IsSaaSExcelAddinEnabled: Boolean;
        CanRequestFlowApprovalForBatch: Boolean;
        CanRequestFlowApprovalForBatchAndAllLines: Boolean;
        CanRequestFlowApprovalForBatchAndCurrentLine: Boolean;
        CanCancelFlowApprovalForBatch: Boolean;
        CanCancelFlowApprovalForLine: Boolean;
        AmountVisible: Boolean;
        DebitCreditVisible: Boolean;
        IsSaaS: Boolean;
        JobQueuesUsed: Boolean;
        JobQueueVisible: Boolean;
        BackgroundErrorCheck: Boolean;
        ShowAllLinesEnabled: Boolean;
        CurrentDocNo: Code[20];
        CurrentPostingDate: Date;
        CurrentCurrencyCode: Code[10];
        IsChangingDocNo: Boolean;
        [InDataSet]
        VATDateEnabled: Boolean;
        MissingExchangeRatesQst: Label 'There are no exchange rates for currency %1 and date %2. Do you want to add them now? Otherwise, the last change you made will be reverted.', Comment = '%1 - currency code, %2 - posting date';
        PostedFromSimplePage: Boolean;
        DocumentNumberMsg: Label 'Document No. must have a value in Gen. Journal Line.';

    protected var
        IsSimplePage: Boolean;
        ShortcutDimCode: array[8] of Code[20];
        DimVisible1: Boolean;
        DimVisible2: Boolean;
        DimVisible3: Boolean;
        DimVisible4: Boolean;
        DimVisible5: Boolean;
        DimVisible6: Boolean;
        DimVisible7: Boolean;
        DimVisible8: Boolean;

    protected procedure UpdateBalance()
    begin
        GenJnlManagement.CalcBalance(Rec, xRec, Balance, TotalBalance, ShowBalance, ShowTotalBalance);
        BalanceVisible := ShowBalance;
        TotalBalanceVisible := ShowTotalBalance;
        if ShowTotalBalance then
            NumberOfRecords := Rec.Count();
    end;

    local procedure EnableApplyEntriesAction()
    begin
        ApplyEntriesActionEnabled :=
          ("Account Type" in ["Account Type"::Customer, "Account Type"::Vendor, "Account Type"::Employee]) or
          ("Bal. Account Type" in ["Bal. Account Type"::Customer, "Bal. Account Type"::Vendor, "Bal. Account Type"::Employee]);

        OnAfterEnableApplyEntriesAction(Rec, ApplyEntriesActionEnabled);
    end;

    local procedure CurrentJnlBatchNameOnAfterVali()
    begin
        CurrPage.SaveRecord();
        GenJnlManagement.SetName(CurrentJnlBatchName, Rec);
        SetControlAppearanceFromBatch();
        CurrPage.Update(false);
    end;

    procedure SetUserInteractions()
    begin
        StyleTxt := GetStyle();
    end;

    local procedure GetCurrentlySelectedLines(var GenJournalLine: Record "Gen. Journal Line"): Boolean
    begin
        CurrPage.SetSelectionFilter(GenJournalLine);
        exit(GenJournalLine.FindSet());
    end;

    local procedure GetPostingDate(): Date
    begin
        if IsSimplePage then
            exit(CurrentPostingDate);
        exit(Workdate());
    end;

    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
        CanRequestFlowApprovalForLine: Boolean;
    begin
        OpenApprovalEntriesExistForCurrUser :=
          OpenApprovalEntriesExistForCurrUser or
          ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(RecordId);

        OpenApprovalEntriesOnJnlLineExist := ApprovalsMgmt.HasOpenApprovalEntries(RecordId);
        OpenApprovalEntriesOnBatchOrCurrJnlLineExist := OpenApprovalEntriesOnJnlBatchExist or OpenApprovalEntriesOnJnlLineExist;

        ShowWorkflowStatusOnLine := CurrPage.WorkflowStatusLine.PAGE.SetFilterOnWorkflowRecord(RecordId);

        CanCancelApprovalForJnlLine := ApprovalsMgmt.CanCancelApprovalForRecord(RecordId);

        SetPayrollAppearance();

        WorkflowWebhookManagement.GetCanRequestAndCanCancel(RecordId, CanRequestFlowApprovalForLine, CanCancelFlowApprovalForLine);
        CanRequestFlowApprovalForBatchAndCurrentLine := CanRequestFlowApprovalForBatch and CanRequestFlowApprovalForLine;
    end;

    local procedure IterateDocNumbers(FindTxt: Text; NextNum: Integer)
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        GenJournalLine: Record "Gen. Journal Line";
        CurrentDocNoWasFound: Boolean;
        NoLines: Boolean;
    begin
        if Count = 0 then
            NoLines := true;
        GenJournalLine.Reset();
        GenJournalLine.SetCurrentKey("Document No.", "Line No.");
        GenJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", "Journal Batch Name");
        // IF GenJournalLine.FIND('+') THEN
        if GenJournalLine.Find(FindTxt) then
            repeat
                if NoLines then begin
                    SetDataForSimpleMode(GenJournalLine);
                    exit;
                end;
                // Find the rec for current doc no.
                if not CurrentDocNoWasFound and (GenJournalLine."Document No." = CurrentDocNo) then
                    CurrentDocNoWasFound := true;
                if CurrentDocNoWasFound and (GenJournalLine."Document No." <> CurrentDocNo) then begin
                    SetDataForSimpleMode(GenJournalLine);
                    exit;
                end;
            until GenJournalLine.Next(NextNum) = 0;
    end;

    procedure NewDocumentNo()
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        GenJournalLine: Record "Gen. Journal Line";
        [SecurityFiltering(SecurityFilter::Filtered)]
        GenJnlBatch: Record "Gen. Journal Batch";
        LastDocNo: Code[20];
    begin
        if Count = 0 then
            exit;
        GenJnlBatch.Get("Journal Template Name", CurrentJnlBatchName);
        GenJournalLine.Reset();
        GenJournalLine.SetCurrentKey("Document No.");
        GenJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", "Journal Batch Name");
        if GenJournalLine.FindLast() then begin
            LastDocNo := GenJournalLine."Document No.";
            IncrementDocumentNo(GenJnlBatch, LastDocNo);
        end else
            LastDocNo := NoSeriesMgt.TryGetNextNo(GenJnlBatch."No. Series", "Posting Date");

        CurrentDocNo := LastDocNo;
        SetDocumentNumberFilter(CurrentDocNo);
    end;

    local procedure OpenJournalFromBatch() Result: Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOpenJournalFromBatch(Rec, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if IsOpenedFromBatch() then begin
            CurrentJnlBatchName := "Journal Batch Name";
            GenJnlManagement.OpenJnl(CurrentJnlBatchName, Rec);
            SetControlAppearanceFromBatch();
            SetDataForSimpleModeOnOpen();
            exit(true);
        end;
    end;

    local procedure SelectTemplate()
    var
        JnlSelected: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSelectTemplate(Rec, GenJnlManagement, IsHandled);
        if IsHandled then
            exit;

        GenJnlManagement.TemplateSelection(PAGE::"General Journal", "Gen. Journal Template Type"::General, false, Rec, JnlSelected);
        if not JnlSelected then
            Error('');
    end;

    local procedure SetPayrollAppearance()
    var
        TempPayrollServiceConnection: Record "Service Connection" temporary;
    begin
        PayrollManagement.OnRegisterPayrollService(TempPayrollServiceConnection);
        ImportPayrollTransactionsAvailable := not TempPayrollServiceConnection.IsEmpty();
    end;

    local procedure SetControlAppearanceFromBatch()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
        CanRequestFlowApprovalForAllLines: Boolean;
    begin
        if not GenJournalBatch.Get(GetRangeMax("Journal Template Name"), CurrentJnlBatchName) then
            exit;

        ShowWorkflowStatusOnBatch := CurrPage.WorkflowStatusBatch.PAGE.SetFilterOnWorkflowRecord(GenJournalBatch.RecordId);
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(GenJournalBatch.RecordId);
        OpenApprovalEntriesOnJnlBatchExist := ApprovalsMgmt.HasOpenApprovalEntries(GenJournalBatch.RecordId);

        OpenApprovalEntriesOnBatchOrAnyJnlLineExist :=
          OpenApprovalEntriesOnJnlBatchExist or
          ApprovalsMgmt.HasAnyOpenJournalLineApprovalEntries("Journal Template Name", "Journal Batch Name");

        CanCancelApprovalForJnlBatch := ApprovalsMgmt.CanCancelApprovalForRecord(GenJournalBatch.RecordId);

        WorkflowWebhookManagement.GetCanRequestAndCanCancelJournalBatch(
          GenJournalBatch, CanRequestFlowApprovalForBatch, CanCancelFlowApprovalForBatch, CanRequestFlowApprovalForAllLines);
        CanRequestFlowApprovalForBatchAndAllLines := CanRequestFlowApprovalForBatch and CanRequestFlowApprovalForAllLines;

        BackgroundErrorCheck := BackgroundErrorHandlingMgt.BackgroundValidationFeatureEnabled();
        ShowAllLinesEnabled := true;
        SwitchLinesWithErrorsFilter(ShowAllLinesEnabled);
        JournalErrorsMgt.SetFullBatchCheck(true);
    end;

    local procedure SetControlVisibility()
    var
        GLSetup: Record "General Ledger Setup";
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        IsSaaS := EnvironmentInfo.IsSaaS();
        GLSetup.Get();
        if IsSimplePage then begin
            AmountVisible := false;
            DebitCreditVisible := true;
        end else begin
            AmountVisible := not (GLSetup."Show Amounts" = GLSetup."Show Amounts"::"Debit/Credit Only");
            DebitCreditVisible := not (GLSetup."Show Amounts" = GLSetup."Show Amounts"::"Amount Only");
        end;
    end;

    local procedure SetDocumentNumberFilter(DocNoToSet: Code[20])
    var
        OriginalFilterGroup: Integer;
    begin
        OriginalFilterGroup := FilterGroup;
        FilterGroup := 25;
        SetFilter("Document No.", DocNoToSet);
        FilterGroup := OriginalFilterGroup;
    end;

    local procedure SetDimensionVisibility()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimVisible1 := false;
        DimVisible2 := false;
        DimVisible3 := false;
        DimVisible4 := false;
        DimVisible5 := false;
        DimVisible6 := false;
        DimVisible7 := false;
        DimVisible8 := false;

        if not IsSimplePage then
            DimMgt.UseShortcutDims(
              DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8);

        Clear(DimMgt);
    end;

    local procedure GetTotalDebitAmt(): Decimal
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        GenJournalLine: Record "Gen. Journal Line";
    begin
        if IsSimplePage then begin
            GenJournalLine.SetRange("Journal Template Name", "Journal Template Name");
            GenJournalLine.SetRange("Journal Batch Name", "Journal Batch Name");
            GenJournalLine.SetRange("Document No.", CurrentDocNo);
            GenJournalLine.CalcSums("Debit Amount");
            exit(GenJournalLine."Debit Amount");
        end
    end;

    local procedure GetTotalCreditAmt(): Decimal
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        if IsSimplePage then begin
            GenJournalLine.SetRange("Journal Template Name", "Journal Template Name");
            GenJournalLine.SetRange("Journal Batch Name", "Journal Batch Name");
            GenJournalLine.SetRange("Document No.", CurrentDocNo);
            GenJournalLine.CalcSums("Credit Amount");
            exit(GenJournalLine."Credit Amount");
        end
    end;

    local procedure SetDataForSimpleMode(GenJournalLine1: Record "Gen. Journal Line")
    begin
        CurrentDocNo := GenJournalLine1."Document No.";
        CurrentPostingDate := GenJournalLine1."Posting Date";
        CurrentCurrencyCode := GenJournalLine1."Currency Code";
        SetDocumentNumberFilter(CurrentDocNo);
    end;

    local procedure SetDataForSimpleModeOnOpen()
    begin
        if IsSimplePage then begin
            // Filter on the first record
            SetCurrentKey("Document No.", "Line No.");
            if FindFirst() then
                SetDataForSimpleMode(Rec)
            else begin
                // if no rec is found reset the currentposting date to workdate and currency code to empty
                CurrentPostingDate := WorkDate();
                Clear(CurrentCurrencyCode);
            end;
        end;
    end;

    local procedure SetDataForSimpleModeOnBatchChange()
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJnlManagement.SetLastViewedJournalBatchName(PAGE::"General Journal", CurrentJnlBatchName);
        // Need to set up simple page mode properties on batch change
        if IsSimplePage then begin
            GenJournalLine.Reset();
            GenJournalLine.SetRange("Journal Template Name", "Journal Template Name");
            GenJournalLine.SetRange("Journal Batch Name", CurrentJnlBatchName);
            IsChangingDocNo := false;
            if GenJournalLine.FindFirst() then
                SetDataForSimpleMode(GenJournalLine);
        end;
    end;

    local procedure SetDataForSimpleModeOnNewRecord()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        BankAccount: Record "Bank Account";
    begin
        // No lines shown
        if Count = 0 then
            // If xrec."Document No." is empty that means this is the first entry for a batch
            // In this case we want to assign current doc no. to the document no. of the record
            // But if user changes the doc no. then we want to use whatever value they enter for
            // current doc no.
            if ((xRec."Document No." = '') or (xRec."Journal Batch Name" <> "Journal Batch Name")) and (not IsChangingDocNo) then begin
                CurrentDocNo := "Document No.";
                IF xRec."Journal Batch Name" = '' THEN
                    IF GenJournalBatch.GET("Journal Template Name", "Journal Batch Name") THEN
                        IF GenJournalBatch."Bal. Account Type" = GenJournalBatch."Bal. Account Type"::"Bank Account" THEN
                            IF BankAccount.GET(GenJournalBatch."Bal. Account No.") THEN
                                CurrentCurrencyCode := BankAccount."Currency Code";
            end else begin
                "Document No." := CurrentDocNo;
                // Clear out credit / debit for empty page since these
                // might have been set if suggest balance amount is checked on the batch
                Validate("Credit Amount", 0);
                Validate("Debit Amount", 0);
            end
        else
            "Document No." := CurrentDocNo;

        "Currency Code" := CurrentCurrencyCode;
        if CurrentPostingDate <> 0D then
            Validate("Posting Date", CurrentPostingDate);
    end;

    local procedure SetDataForSimpleModeOnPropValidation(FieldNumber: Integer)
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        GenJournalLine: Record "Gen. Journal Line";
    begin
        if IsSimplePage then begin
            GenJournalLine.Reset();
            GenJournalLine.SetRange("Journal Template Name", "Journal Template Name");
            GenJournalLine.SetRange("Journal Batch Name", "Journal Batch Name");
            GenJournalLine.SetRange("Document No.", CurrentDocNo);
            if GenJournalLine.Findset(true, false) then
                repeat
                    case FieldNumber of
                        GenJournalLine.FieldNo("Currency Code"):
                            GenJournalLine.Validate("Currency Code", CurrentCurrencyCode);
                        GenJournalLine.FieldNo("Posting Date"):
                            GenJournalLine.Validate("Posting Date", CurrentPostingDate);
                    end;
                    GenJournalLine.Modify();
                until GenJournalLine.Next() = 0;
        end;
        CurrPage.Update(false);
    end;

    local procedure SetDataForSimpleModeOnPost()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSetDataForSimpleModeOnPost(Rec, IsSimplePage, IsHandled);
        if IsHandled then
            exit;

        PostedFromSimplePage := true;
        SetCurrentKey("Document No.", "Line No.");
        if FindFirst() then
            SetDataForSimpleMode(Rec)
    end;

    local procedure UpdateCurrencyFactor(FieldNo: Integer)
    var
        UpdateCurrencyExchangeRates: Codeunit "Update Currency Exchange Rates";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if CurrentCurrencyCode <> '' then
            if UpdateCurrencyExchangeRates.ExchangeRatesForCurrencyExist(CurrentPostingDate, CurrentCurrencyCode) then
                SetDataForSimpleModeOnPropValidation(FieldNo)
            else
                if ConfirmManagement.GetResponseOrDefault(
                     StrSubstNo(MissingExchangeRatesQst, CurrentCurrencyCode, CurrentPostingDate), true)
                then begin
                    UpdateCurrencyExchangeRates.OpenExchangeRatesPage(CurrentCurrencyCode);
                    UpdateCurrencyFactor(FieldNo);
                end else begin
                    CurrentCurrencyCode := "Currency Code";
                    CurrentPostingDate := "Posting Date";
                end
        else
            SetDataForSimpleModeOnPropValidation(FieldNo);
    end;

    local procedure SetJobQueueVisibility()
    begin
        JobQueueVisible := "Job Queue Status" = "Job Queue Status"::"Scheduled for Posting";
        JobQueuesUsed := GeneralLedgerSetup.JobQueueActive();
    end;

#if not CLEAN22
    var
        PowerAutomateTemplatesEnabled: Boolean;
        PowerAutomateTemplatesFeatureLbl: Label 'PowerAutomateTemplates', Locked = true;

    local procedure InitPowerAutomateTemplateVisibility()
    var
        FeatureKey: Record "Feature Key";
    begin
        PowerAutomateTemplatesEnabled := true;
        if FeatureKey.Get(PowerAutomateTemplatesFeatureLbl) then
            if FeatureKey.Enabled <> FeatureKey.Enabled::"All Users" then
                PowerAutomateTemplatesEnabled := false;
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateShortcutDimCode(var GenJournalLine: Record "Gen. Journal Line"; var ShortcutDimCode: array[8] of Code[20]; DimIndex: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateCurrentJnlBatchName(CurrentJnlBatchName: Code[10])
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeOnInit(var GenJnlLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeOpenJournalFromBatch(var GenJournalLine: Record "Gen. Journal Line"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSelectTemplate(var GenJournalLine: Record "Gen. Journal Line"; var GenJnlManagement: Codeunit GenJnlManagement; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetDataForSimpleModeOnPost(var GenJournalLine: Record "Gen. Journal Line"; IsSimplePage: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLookupCurrentJnlBatchNameOnAfterSetDataForSimpleModeOnBatchChange(CurrentJnlBatchName: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnOpenPageOnAfterAssignCurrentJnlBatchName(var CurrentJnlBatchName: Code[10])
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnOpenPageOnBeforeGetLastViewedJournalBatchName(var CurrentJnlBatchName: Code[10]; var GenJnlManagement: Codeunit GenJnlManagement)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterEnableApplyEntriesAction(GenJournalLine: Record "Gen. Journal Line"; var ApplyEntriesActionEnabled: Boolean)
    begin
    end;
}


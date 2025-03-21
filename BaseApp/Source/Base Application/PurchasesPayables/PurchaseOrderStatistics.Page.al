﻿page 403 "Purchase Order Statistics"
{
    Caption = 'Purchase Order Statistics';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    SourceTable = "Purchase Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(LineAmountGeneral; TotalPurchLine[1]."Line Amount")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = GetCaptionClass(Text002, false);
                    Caption = 'Amount';
                    Editable = false;
                    ToolTip = 'Specifies the net amount of all the lines in the purchase order. This amount does not include VAT or any invoice discount, but does include line discounts.';
                }
                field(InvDiscountAmount_General; TotalPurchLine[1]."Inv. Discount Amount")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    Caption = 'Inv. Discount Amount';
                    ToolTip = 'Specifies the invoice discount amount for the entire purchase order.';

                    trigger OnValidate()
                    begin
                        ActiveTab := ActiveTab::General;
                        UpdateInvDiscAmount(1);
                    end;
                }
                field(Total_General; TotalAmount1[1])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = GetCaptionClass(Text001, false);
                    Caption = 'Total';
                    ToolTip = 'Specifies the total amount, less any invoice discount amount and excluding VAT for the purchase order.';

                    trigger OnValidate()
                    begin
                        ActiveTab := ActiveTab::General;
                        UpdateTotalAmount(1);
                    end;
                }
                field("VATAmount[1]"; VATAmount[1])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = Format(VATAmountText[1]);
                    Caption = 'VAT Amount';
                    Editable = false;
                    ToolTip = 'Specifies the total VAT amount that has been calculated for all the lines in the purchase order.';
                }
                field(TotalInclVAT_General; TotalAmount2[1])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = GetCaptionClass(Text001, true);
                    Caption = 'Total Incl. VAT';
                    Editable = false;
                    ToolTip = 'Specifies the amount, including VAT. On the Invoicing FastTab, this is the amount that is posted to the vendor''s account for all the lines in the purchase order if you post the purchase order as invoiced.';
                }
                field("TotalPurchLineLCY[1].Amount"; TotalPurchLineLCY[1].Amount)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 1;
                    Caption = 'Purchase (LCY)';
                    Editable = false;
                    ToolTip = 'Specifies the amount in the Total field, converted to LCY.';
                }
                field(Quantity_General; TotalPurchLine[1].Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Quantity';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Specifies the total quantity of G/L account entries, fixed assets, and/or items in the purchase order.';
                }
                field("TotalPurchLine[1].""Units per Parcel"""; TotalPurchLine[1]."Units per Parcel")
                {
                    ApplicationArea = Suite;
                    Caption = 'Parcels';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Specifies the total number of parcels in the purchase order.';
                }
                field("TotalPurchLine[1].""Net Weight"""; TotalPurchLine[1]."Net Weight")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Net Weight';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Specifies the total net weight of the items in the purchase order.';
                }
                field("TotalPurchLine[1].""Gross Weight"""; TotalPurchLine[1]."Gross Weight")
                {
                    ApplicationArea = Suite;
                    Caption = 'Gross Weight';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Specifies the total gross weight of the items in the purchase order.';
                }
                field("TotalPurchLine[1].""Unit Volume"""; TotalPurchLine[1]."Unit Volume")
                {
                    ApplicationArea = Suite;
                    Caption = 'Volume';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Specifies the total volume of the items in the purchase order.';
                }
                field(NoOfVATLines_General; TempVATAmountLine1.Count)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'No. of Tax Lines';
                    DrillDown = true;
                    ToolTip = 'Specifies the number of lines on the purchase order that have VAT amounts.';

                    trigger OnDrillDown()
                    begin
                        VATLinesDrillDown(TempVATAmountLine1, false);
                        UpdateHeaderInfo(1, TempVATAmountLine1);
                    end;
                }
            }
            group(Invoicing)
            {
                Caption = 'Invoicing';
                field("TotalPurchLine[2].""Line Amount"""; TotalPurchLine[2]."Line Amount")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = GetCaptionClass(Text002, false);
                    Caption = 'Amount';
                    Editable = false;
                    ToolTip = 'Specifies the net amount of all the lines in the purchase order. This amount does not include VAT or any invoice discount, but does include line discounts.';
                }
                field(InvDiscountAmount_Invoicing; TotalPurchLine[2]."Inv. Discount Amount")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    Caption = 'Inv. Discount Amount';
                    ToolTip = 'Specifies the invoice discount amount.';

                    trigger OnValidate()
                    begin
                        ActiveTab := ActiveTab::Invoicing;
                        UpdateInvDiscAmount(2);
                    end;
                }
                field(Total_Invoicing; TotalAmount1[2])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = GetCaptionClass(Text001, false);
                    Caption = 'Total';
                    ToolTip = 'Specifies the total amount less any invoice discount amount and excluding VAT for the purchase order.';

                    trigger OnValidate()
                    begin
                        ActiveTab := ActiveTab::Invoicing;
                        UpdateTotalAmount(2);
                    end;
                }
                field(VATAmount_Invoicing; VATAmount[2])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = Format(VATAmountText[2]);
                    Caption = 'VAT Amount';
                    Editable = false;
                    ToolTip = 'Specifies the total VAT amount that has been calculated for all the lines in the purchase order.';
                }
                field(TotalInclVAT_Invoicing; TotalAmount2[2])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = GetCaptionClass(Text001, true);
                    Caption = 'Total Incl. VAT';
                    Editable = false;
                    ToolTip = 'Specifies the amount, including VAT. On the Invoicing FastTab, this is the amount that is posted to the vendor''s account for all the lines in the purchase order if you post the purchase order as invoiced.';
                }
                field("TotalPurchLineLCY[2].Amount"; TotalPurchLineLCY[2].Amount)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 1;
                    Caption = 'Purchase (LCY)';
                    Editable = false;
                    ToolTip = 'Specifies the amount in the Total field, converted to LCY.';
                }
                field(Quantity_Invoicing; TotalPurchLine[2].Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Quantity';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Specifies the total quantity of G/L account entries, fixed assets, and/or items in the purchase order.';
                }
                field("TotalPurchLine[2].""Units per Parcel"""; TotalPurchLine[2]."Units per Parcel")
                {
                    ApplicationArea = Suite;
                    Caption = 'Parcels';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Specifies the total number of parcels in the purchase order.';
                }
                field("TotalPurchLine[2].""Net Weight"""; TotalPurchLine[2]."Net Weight")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Net Weight';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Specifies the total net weight of the items in the purchase order.';
                }
                field("TotalPurchLine[2].""Gross Weight"""; TotalPurchLine[2]."Gross Weight")
                {
                    ApplicationArea = Suite;
                    Caption = 'Gross Weight';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Specifies the total gross weight of the items in the purchase order.';
                }
                field("TotalPurchLine[2].""Unit Volume"""; TotalPurchLine[2]."Unit Volume")
                {
                    ApplicationArea = Suite;
                    Caption = 'Volume';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Specifies the total volume of the items in the purchase order.';
                }
                field(NoOfVATLines_Invoicing; TempVATAmountLine2.Count)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'No. of Tax Lines';
                    DrillDown = true;
                    ToolTip = 'Specifies the number of lines on the purchase order that have VAT amounts.';

                    trigger OnDrillDown()
                    begin
                        ActiveTab := ActiveTab::Invoicing;
                        VATLinesDrillDown(TempVATAmountLine2, true);
                        UpdateHeaderInfo(2, TempVATAmountLine2);

                        if TempVATAmountLine2.GetAnyLineModified() then begin
                            UpdateVATOnPurchLines();
                            RefreshOnAfterGetRecord();
                        end;
                    end;
                }
            }
            group(Shipping)
            {
                Caption = 'Shipping';
                field("TotalPurchLine[3].""Line Amount"""; TotalPurchLine[3]."Line Amount")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = GetCaptionClass(Text002, false);
                    Caption = 'Amount';
                    Editable = false;
                    ToolTip = 'Specifies the net amount of all the lines in the purchase order. This amount does not include VAT or any invoice discount, but does include line discounts.';
                }
                field("TotalPurchLine[3].""Inv. Discount Amount"""; TotalPurchLine[3]."Inv. Discount Amount")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    Caption = 'Inv. Discount Amount';
                    Editable = false;
                    ToolTip = 'Specifies the invoice discount amount for the entire purchase order.';
                }
                field("TotalAmount1[3]"; TotalAmount1[3])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = GetCaptionClass(Text001, false);
                    Caption = 'Total';
                    Editable = false;
                    ToolTip = 'Specifies the total amount less any invoice discount amount and excluding VAT for the purchase order.';
                }
                field("VATAmount[3]"; VATAmount[3])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = Format(VATAmountText[3]);
                    Caption = 'VAT Amount';
                    Editable = false;
                    ToolTip = 'Specifies the total VAT amount that has been calculated for all the lines in the purchase order.';
                }
                field(TotalInclVAT_Shipping; TotalAmount2[3])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = GetCaptionClass(Text001, true);
                    Caption = 'Total Incl. VAT';
                    Editable = false;
                    ToolTip = 'Specifies the amount, including VAT. On the Invoicing FastTab, this is the amount that is posted to the vendor''s account for all the lines in the purchase order if you post the purchase order as invoiced.';
                }
                field("TotalPurchLineLCY[3].Amount"; TotalPurchLineLCY[3].Amount)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 1;
                    Caption = 'Purchase (LCY)';
                    Editable = false;
                    ToolTip = 'Specifies the amount in the Total field, converted to LCY.';
                }
                field(Quantity_Shipping; TotalPurchLine[3].Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Quantity';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Specifies the total quantity of G/L account entries, fixed assets, and/or items in the purchase order.';
                }
                field("TotalPurchLine[3].""Units per Parcel"""; TotalPurchLine[3]."Units per Parcel")
                {
                    ApplicationArea = Suite;
                    Caption = 'Parcels';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Specifies the total number of parcels in the purchase order.';
                }
                field("TotalPurchLine[3].""Net Weight"""; TotalPurchLine[3]."Net Weight")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Net Weight';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Specifies the total net weight of the items in the purchase order.';
                }
                field("TotalPurchLine[3].""Gross Weight"""; TotalPurchLine[3]."Gross Weight")
                {
                    ApplicationArea = Suite;
                    Caption = 'Gross Weight';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Specifies the total gross weight of the items in the purchase order.';
                }
                field("TotalPurchLine[3].""Unit Volume"""; TotalPurchLine[3]."Unit Volume")
                {
                    ApplicationArea = Suite;
                    Caption = 'Volume';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Specifies the total volume of the items in the purchase order.';
                }
                field("TempVATAmountLine3.COUNT"; TempVATAmountLine3.Count)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'No. of Tax Lines';
                    DrillDown = true;
                    ToolTip = 'Specifies the number of lines on the purchase order that have VAT amounts.';

                    trigger OnDrillDown()
                    begin
                        VATLinesDrillDown(TempVATAmountLine3, false);
                    end;
                }
            }
            group(Prepayment)
            {
                Caption = 'Prepayment';
                field(PrepmtTotalAmount; PrepmtTotalAmount)
                {
                    ApplicationArea = Prepayments;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = GetCaptionClass(Text006, false);

                    trigger OnValidate()
                    begin
                        ActiveTab := ActiveTab::Prepayment;
                        UpdatePrepmtAmount();
                    end;
                }
                field(PrepmtVATAmount; PrepmtVATAmount)
                {
                    ApplicationArea = Prepayments;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = Format(PrepmtVATAmountText);
                    Caption = 'Prepayment Amount Invoiced';
                    Editable = false;
                    ToolTip = 'Specifies the total prepayment amount that has been invoiced for the order.';
                }
                field(PrepmtTotalAmount2; PrepmtTotalAmount2)
                {
                    ApplicationArea = Prepayments;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = GetCaptionClass(Text006, true);
                    Caption = 'Prepmt. Amount Invoiced';
                    Editable = false;
                    ToolTip = 'Specifies the total prepayment amount that has been invoiced for the order.';

                    trigger OnValidate()
                    begin
                        OnBeforeValidatePrepmtTotalAmount2(Rec, PrepmtTotalAmount, PrepmtTotalAmount2);
                        UpdatePrepmtAmount();
                    end;
                }
                field("TotalPurchLine[1].""Prepmt. Amt. Inv."""; TotalPurchLine[1]."Prepmt. Amt. Inv.")
                {
                    ApplicationArea = Prepayments;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = GetCaptionClass(Text007, false);
                    Editable = false;
                }
                field(PrepmtInvPct; PrepmtInvPct)
                {
                    ApplicationArea = Prepayments;
                    Caption = 'Invoiced % of Prepayment Amt.';
                    ExtendedDatatype = Ratio;
                    ToolTip = 'Specifies the invoiced percentage of the prepayment amount.';
                }
                field("TotalPurchLine[1].""Prepmt Amt Deducted"""; TotalPurchLine[1]."Prepmt Amt Deducted")
                {
                    ApplicationArea = Prepayments;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = GetCaptionClass(Text008, false);
                    Editable = false;
                }
                field(PrepmtDeductedPct; PrepmtDeductedPct)
                {
                    ApplicationArea = Prepayments;
                    Caption = 'Deducted % of Prepayment Amt. to Deduct';
                    ExtendedDatatype = Ratio;
                    ToolTip = 'Specifies the deducted percentage of the prepayment amount to deduct.';
                }
                field("TotalPurchLine[1].""Prepmt Amt to Deduct"""; TotalPurchLine[1]."Prepmt Amt to Deduct")
                {
                    ApplicationArea = Prepayments;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = GetCaptionClass(Text009, false);
                    Editable = false;
                }
                field("TempVATAmountLine4.COUNT"; TempVATAmountLine4.Count)
                {
                    ApplicationArea = Suite;
                    Caption = 'No. of VAT Lines';
                    DrillDown = true;
                    ToolTip = 'Specifies the number of purchase order lines that are associated with the VAT ledger line.';

                    trigger OnDrillDown()
                    begin
                        VATLinesDrillDown(TempVATAmountLine4, true);
                    end;
                }
            }
            group(Vendor)
            {
                Caption = 'Vendor';
                field("Vend.""Balance (LCY)"""; Vend."Balance (LCY)")
                {
                    ApplicationArea = Suite;
                    AutoFormatType = 1;
                    Caption = 'Balance (LCY)';
                    Editable = false;
                    ToolTip = 'Specifies the balance (in LCY) due to the vendor.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        RefreshOnAfterGetRecord();
    end;

    trigger OnOpenPage()
    begin
        PurchSetup.Get();
        AllowInvDisc :=
          not (PurchSetup."Calc. Inv. Discount" and VendInvDiscRecExists(Rec."Invoice Disc. Code"));
        AllowVATDifference :=
          PurchSetup."Allow VAT Difference" and
          not (Rec."Document Type" in ["Purchase Document Type"::Quote, "Purchase Document Type"::"Blanket Order"]);
        OnOpenPageOnBeforeSetEditable(AllowInvDisc, AllowVATDifference, Rec, PurchSetup);
        VATLinesFormIsEditable := AllowVATDifference or AllowInvDisc;
        CurrPage.Editable := VATLinesFormIsEditable;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        PurchLine: Record "Purchase Line";
        ReleasePurchaseDocument: Codeunit "Release Purchase Document";
    begin
        GetVATSpecification(PrevTab);
        ReleasePurchaseDocument.CalcAndUpdateVATOnLines(Rec, PurchLine);
        exit(true);
    end;

    var
        Text000: Label 'Purchase %1 Statistics';
        Text001: Label 'Total';
        Text002: Label 'Amount';
        Text003: Label '%1 must not be 0.';
        Text004: Label '%1 must not be greater than %2.';
        Text005: Label 'You cannot change the invoice discount because there is a %1 record for %2 %3.';
        Vend: Record Vendor;
        TempVATAmountLine1: Record "VAT Amount Line" temporary;
        TempVATAmountLine2: Record "VAT Amount Line" temporary;
        TempVATAmountLine3: Record "VAT Amount Line" temporary;
        TempVATAmountLine4: Record "VAT Amount Line" temporary;
        PurchSetup: Record "Purchases & Payables Setup";
        VATLinesForm: Page "VAT Amount Lines";
        PrepmtTotalAmount: Decimal;
        PrepmtVATAmount: Decimal;
        PrepmtTotalAmount2: Decimal;
        VATAmountText: array[3] of Text[30];
        PrepmtVATAmountText: Text[30];
        PrepmtInvPct: Decimal;
        PrepmtDeductedPct: Decimal;
        i: Integer;
        PrevNo: Code[20];
        ActiveTab: Option General,Invoicing,Shipping,Prepayment;
        PrevTab: Option General,Invoicing,Shipping,Prepayment;
        VATLinesFormIsEditable: Boolean;
        AllowInvDisc: Boolean;
        AllowVATDifference: Boolean;
        Text006: Label 'Prepmt. Amount';
        Text007: Label 'Prepmt. Amt. Invoiced';
        Text008: Label 'Prepmt. Amt. Deducted';
        Text009: Label 'Prepmt. Amt. to Deduct';
        UpdateInvDiscountQst: Label 'One or more lines have been invoiced. The discount distributed to invoiced lines will not be taken into account.\\Do you want to update the invoice discount?';

    protected var
        TotalPurchLine: array[3] of Record "Purchase Line";
        TotalPurchLineLCY: array[3] of Record "Purchase Line";
        PurchPost: Codeunit "Purch.-Post";
        TotalAmount1: array[3] of Decimal;
        TotalAmount2: array[3] of Decimal;
        VATAmount: array[3] of Decimal;

    local procedure RefreshOnAfterGetRecord()
    var
        PurchLine: Record "Purchase Line";
        TempPurchLine: Record "Purchase Line" temporary;
        PurchPostPrepayments: Codeunit "Purchase-Post Prepayments";
        OptionValueOutOfRange: Integer;
        IsHandled: Boolean;
    begin
        CurrPage.Caption(StrSubstNo(Text000, "Document Type"));

        if PrevNo = Rec."No." then
            exit;
        PrevNo := Rec."No.";
        Rec.FilterGroup(2);
        Rec.SetRange("No.", PrevNo);
        Rec.FilterGroup(0);

        Clear(PurchLine);
        Clear(TotalPurchLine);
        Clear(TotalPurchLineLCY);

        for i := 1 to 3 do begin
            TempPurchLine.DeleteAll();
            Clear(TempPurchLine);
            Clear(PurchPost);
            PurchPost.GetPurchLines(Rec, TempPurchLine, i - 1);
            OnRefreshOnAfterGetRecordOnAfterGetPurchLines(Rec, TempPurchLine);
            Clear(PurchPost);
            case i of
                1:
                    PurchLine.CalcVATAmountLines(0, Rec, TempPurchLine, TempVATAmountLine1);
                2:
                    PurchLine.CalcVATAmountLines(0, Rec, TempPurchLine, TempVATAmountLine2);
                3:
                    PurchLine.CalcVATAmountLines(0, Rec, TempPurchLine, TempVATAmountLine3);
            end;

            PurchPost.SumPurchLinesTemp(
              Rec, TempPurchLine, i - 1, TotalPurchLine[i], TotalPurchLineLCY[i],
              VATAmount[i], VATAmountText[i]);

            IsHandled := false;
            OnRefreshOnAfterGetRecordAfterSumPurchLinesTemp(TempPurchLine, IsHandled);
            If not IsHandled then
                if Rec."Prices Including VAT" then begin
                    TotalAmount2[i] := TotalPurchLine[i].Amount;
                    TotalAmount1[i] := TotalAmount2[i] + VATAmount[i];
                    TotalPurchLine[i]."Line Amount" := TotalAmount1[i] + TotalPurchLine[i]."Inv. Discount Amount";
                end else begin
                    TotalAmount1[i] := TotalPurchLine[i].Amount;
                    TotalAmount2[i] := TotalPurchLine[i]."Amount Including VAT";
                end;
        end;
        TempPurchLine.DeleteAll();
        Clear(TempPurchLine);
        PurchPostPrepayments.GetPurchLines(Rec, 0, TempPurchLine);
        PurchPostPrepayments.SumPrepmt(Rec, TempPurchLine, TempVATAmountLine4, PrepmtTotalAmount, PrepmtVATAmount, PrepmtVATAmountText);
        PrepmtInvPct := Pct(TotalPurchLine[1]."Prepmt. Amt. Inv.", PrepmtTotalAmount);
        PrepmtDeductedPct := Pct(TotalPurchLine[1]."Prepmt Amt Deducted", TotalPurchLine[1]."Prepmt. Amt. Inv.");
        if Rec."Prices Including VAT" then begin
            PrepmtTotalAmount2 := PrepmtTotalAmount;
            PrepmtTotalAmount := PrepmtTotalAmount + PrepmtVATAmount;
        end else
            PrepmtTotalAmount2 := PrepmtTotalAmount + PrepmtVATAmount;

        if Vend.Get(Rec."Pay-to Vendor No.") then
            Vend.CalcFields("Balance (LCY)")
        else
            Clear(Vend);

        TempVATAmountLine1.ModifyAll(Modified, false);
        TempVATAmountLine2.ModifyAll(Modified, false);
        TempVATAmountLine3.ModifyAll(Modified, false);
        TempVATAmountLine4.ModifyAll(Modified, false);

        OptionValueOutOfRange := -1;
        PrevTab := OptionValueOutOfRange;
        UpdateHeaderInfo(2, TempVATAmountLine2);
    end;

    local procedure UpdateHeaderInfo(IndexNo: Integer; var VATAmountLine: Record "VAT Amount Line")
    var
        CurrExchRate: Record "Currency Exchange Rate";
        UseDate: Date;
    begin
        TotalPurchLine[IndexNo]."Inv. Discount Amount" := VATAmountLine.GetTotalInvDiscAmount();
        TotalAmount1[IndexNo] := TotalPurchLine[IndexNo]."Line Amount" - TotalPurchLine[IndexNo]."Inv. Discount Amount";
        VATAmount[IndexNo] := VATAmountLine.GetTotalVATAmount();
        if Rec."Prices Including VAT" then begin
            TotalAmount1[IndexNo] := VATAmountLine.GetTotalAmountInclVAT();
            TotalAmount2[IndexNo] := TotalAmount1[IndexNo] - VATAmount[IndexNo];
            TotalPurchLine[IndexNo]."Line Amount" := TotalAmount1[IndexNo] + TotalPurchLine[IndexNo]."Inv. Discount Amount";
        end else
            TotalAmount2[IndexNo] := TotalAmount1[IndexNo] + VATAmount[IndexNo];

        OnUpdateHeaderInfoAfterCalcTotalAmount(Rec, IndexNo);

        if Rec."Prices Including VAT" then
            TotalPurchLineLCY[IndexNo].Amount := TotalAmount2[IndexNo]
        else
            TotalPurchLineLCY[IndexNo].Amount := TotalAmount1[IndexNo];
        if Rec."Currency Code" <> '' then begin
            if Rec."Posting Date" = 0D then
                UseDate := WorkDate()
            else
                UseDate := Rec."Posting Date";

            TotalPurchLineLCY[IndexNo].Amount :=
              CurrExchRate.ExchangeAmtFCYToLCY(
                UseDate, "Currency Code", TotalPurchLineLCY[IndexNo].Amount, "Currency Factor");
        end;
    end;

    local procedure GetVATSpecification(QtyType: Option General,Invoicing,Shipping)
    begin
        case QtyType of
            QtyType::General:
                begin
                    VATLinesForm.GetTempVATAmountLine(TempVATAmountLine1);
                    if TempVATAmountLine1.GetAnyLineModified() then
                        UpdateHeaderInfo(1, TempVATAmountLine1);
                end;
            QtyType::Invoicing:
                begin
                    VATLinesForm.GetTempVATAmountLine(TempVATAmountLine2);
                    if TempVATAmountLine2.GetAnyLineModified() then
                        UpdateHeaderInfo(2, TempVATAmountLine2);
                end;
            QtyType::Shipping:
                VATLinesForm.GetTempVATAmountLine(TempVATAmountLine3);
        end;
    end;

    protected procedure UpdateTotalAmount(IndexNo: Integer)
    var
        SaveTotalAmount: Decimal;
    begin
        CheckAllowInvDisc();
        if Rec."Prices Including VAT" then begin
            SaveTotalAmount := TotalAmount1[IndexNo];
            UpdateInvDiscAmount(IndexNo);
            TotalAmount1[IndexNo] := SaveTotalAmount;
        end;
        with TotalPurchLine[IndexNo] do
            "Inv. Discount Amount" := "Line Amount" - TotalAmount1[IndexNo];
        UpdateInvDiscAmount(IndexNo);
    end;

    protected procedure UpdateInvDiscAmount(ModifiedIndexNo: Integer)
    var
        ConfirmManagement: Codeunit "Confirm Management";
        PartialInvoicing: Boolean;
        MaxIndexNo: Integer;
        IndexNo: array[2] of Integer;
        i: Integer;
        InvDiscBaseAmount: Decimal;
    begin
        CheckAllowInvDisc();
        if not (ModifiedIndexNo in [1, 2]) then
            exit;

        if InvoicedLineExists() then
            if not ConfirmManagement.GetResponseOrDefault(UpdateInvDiscountQst, true) then
                Error('');

        if ModifiedIndexNo = 1 then
            InvDiscBaseAmount := TempVATAmountLine1.GetTotalInvDiscBaseAmount(false, Rec."Currency Code")
        else
            InvDiscBaseAmount := TempVATAmountLine2.GetTotalInvDiscBaseAmount(false, Rec."Currency Code");

        if InvDiscBaseAmount = 0 then
            Error(Text003, TempVATAmountLine2.FieldCaption("Inv. Disc. Base Amount"));

        if TotalPurchLine[ModifiedIndexNo]."Inv. Discount Amount" / InvDiscBaseAmount > 1 then
            Error(
              Text004,
              TotalPurchLine[ModifiedIndexNo].FieldCaption("Inv. Discount Amount"),
              TempVATAmountLine2.FieldCaption("Inv. Disc. Base Amount"));

        PartialInvoicing := (TotalPurchLine[1]."Line Amount" <> TotalPurchLine[2]."Line Amount");

        IndexNo[1] := ModifiedIndexNo;
        IndexNo[2] := 3 - ModifiedIndexNo;
        if (ModifiedIndexNo = 2) and PartialInvoicing then
            MaxIndexNo := 1
        else
            MaxIndexNo := 2;

        if not PartialInvoicing then
            if ModifiedIndexNo = 1 then
                TotalPurchLine[2]."Inv. Discount Amount" := TotalPurchLine[1]."Inv. Discount Amount"
            else
                TotalPurchLine[1]."Inv. Discount Amount" := TotalPurchLine[2]."Inv. Discount Amount";

        for i := 1 to MaxIndexNo do
            with TotalPurchLine[IndexNo[i]] do begin
                if (i = 1) or not PartialInvoicing then
                    if IndexNo[i] = 1 then
                        TempVATAmountLine1.SetInvoiceDiscountAmount(
                          "Inv. Discount Amount", "Currency Code", Rec."Prices Including VAT", Rec."VAT Base Discount %")
                    else
                        TempVATAmountLine2.SetInvoiceDiscountAmount(
                          "Inv. Discount Amount", "Currency Code", Rec."Prices Including VAT", Rec."VAT Base Discount %");

                if (i = 2) and PartialInvoicing then
                    if IndexNo[i] = 1 then begin
                        InvDiscBaseAmount := TempVATAmountLine2.GetTotalInvDiscBaseAmount(false, "Currency Code");
                        if InvDiscBaseAmount = 0 then
                            TempVATAmountLine1.SetInvoiceDiscountPercent(
                              0, "Currency Code", Rec."Prices Including VAT", false, Rec."VAT Base Discount %")
                        else
                            TempVATAmountLine1.SetInvoiceDiscountPercent(
                              100 * TempVATAmountLine2.GetTotalInvDiscAmount() / InvDiscBaseAmount,
                              "Currency Code", Rec."Prices Including VAT", false, Rec."VAT Base Discount %");
                    end else begin
                        InvDiscBaseAmount := TempVATAmountLine1.GetTotalInvDiscBaseAmount(false, "Currency Code");
                        if InvDiscBaseAmount = 0 then
                            TempVATAmountLine2.SetInvoiceDiscountPercent(
                              0, "Currency Code", Rec."Prices Including VAT", false, Rec."VAT Base Discount %")
                        else
                            TempVATAmountLine2.SetInvoiceDiscountPercent(
                              100 * TempVATAmountLine1.GetTotalInvDiscAmount() / InvDiscBaseAmount,
                              "Currency Code", Rec."Prices Including VAT", false, Rec."VAT Base Discount %");
                    end;
            end;

        UpdateHeaderInfo(1, TempVATAmountLine1);
        UpdateHeaderInfo(2, TempVATAmountLine2);

        if ModifiedIndexNo = 1 then
            VATLinesForm.SetTempVATAmountLine(TempVATAmountLine1)
        else
            VATLinesForm.SetTempVATAmountLine(TempVATAmountLine2);

        Rec."Invoice Discount Calculation" := Rec."Invoice Discount Calculation"::Amount;
        Rec."Invoice Discount Value" := TotalPurchLine[1]."Inv. Discount Amount";
        Rec.Modify();
        UpdateVATOnPurchLines();
    end;

    local procedure UpdatePrepmtAmount()
    var
        TempPurchLine: Record "Purchase Line" temporary;
        PurchPostPrepmt: Codeunit "Purchase-Post Prepayments";
    begin
        PurchPostPrepmt.UpdatePrepmtAmountOnPurchLines(Rec, PrepmtTotalAmount);
        PurchPostPrepmt.GetPurchLines(Rec, 0, TempPurchLine);
        PurchPostPrepmt.SumPrepmt(Rec, TempPurchLine, TempVATAmountLine4, PrepmtTotalAmount, PrepmtVATAmount, PrepmtVATAmountText);
        PrepmtInvPct := Pct(TotalPurchLine[1]."Prepmt. Amt. Inv.", PrepmtTotalAmount);
        PrepmtDeductedPct := Pct(TotalPurchLine[1]."Prepmt Amt Deducted", TotalPurchLine[1]."Prepmt. Amt. Inv.");
        if Rec."Prices Including VAT" then begin
            PrepmtTotalAmount2 := PrepmtTotalAmount;
            PrepmtTotalAmount := PrepmtTotalAmount + PrepmtVATAmount;
        end else
            PrepmtTotalAmount2 := PrepmtTotalAmount + PrepmtVATAmount;
        Rec.Modify();
    end;

    protected procedure GetCaptionClass(FieldCaption: Text[100]; ReverseCaption: Boolean): Text[80]
    begin
        if Rec."Prices Including VAT" xor ReverseCaption then
            exit('2,1,' + FieldCaption);

        exit('2,0,' + FieldCaption);
    end;

    procedure UpdateVATOnPurchLines()
    var
        PurchLine: Record "Purchase Line";
    begin
        GetVATSpecification(ActiveTab);
        if TempVATAmountLine1.GetAnyLineModified() then
            PurchLine.UpdateVATOnLines(0, Rec, PurchLine, TempVATAmountLine1);
        if TempVATAmountLine2.GetAnyLineModified() then
            PurchLine.UpdateVATOnLines(1, Rec, PurchLine, TempVATAmountLine2);
        PrevNo := '';
    end;

    local procedure VendInvDiscRecExists(InvDiscCode: Code[20]): Boolean
    var
        VendInvDisc: Record "Vendor Invoice Disc.";
    begin
        VendInvDisc.SetRange(Code, InvDiscCode);
        exit(VendInvDisc.FindFirst());
    end;

    local procedure CheckAllowInvDisc()
    var
        VendInvDisc: Record "Vendor Invoice Disc.";
    begin
        if not AllowInvDisc then
            Error(
              Text005,
              VendInvDisc.TableCaption(), FieldCaption("Invoice Disc. Code"), "Invoice Disc. Code");
    end;

    local procedure Pct(Numerator: Decimal; Denominator: Decimal): Decimal
    begin
        if Denominator = 0 then
            exit(0);
        exit(Round(Numerator / Denominator * 10000, 1));
    end;

    local procedure VATLinesDrillDown(var VATLinesToDrillDown: Record "VAT Amount Line"; ThisTabAllowsVATEditing: Boolean)
    begin
        Clear(VATLinesForm);
        VATLinesForm.SetTempVATAmountLine(VATLinesToDrillDown);
        VATLinesForm.InitGlobals(
          "Currency Code", AllowVATDifference, AllowVATDifference and ThisTabAllowsVATEditing,
          "Prices Including VAT", AllowInvDisc, "VAT Base Discount %");
        VATLinesForm.RunModal();
        VATLinesForm.GetTempVATAmountLine(VATLinesToDrillDown);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnOpenPageOnBeforeSetEditable(var AllowInvDisc: Boolean; var AllowVATDifference: Boolean; PurchaseHeader: Record "Purchase Header"; PurchSetup: Record "Purchases & Payables Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidatePrepmtTotalAmount2(PurchaseHeader: Record "Purchase Header"; var PrepmtTotalAmount: Decimal; var PrepmtTotalAmount2: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRefreshOnAfterGetRecordOnAfterGetPurchLines(PuchaseHeader: Record "Purchase Header"; var TempPurchaseLine: Record "Purchase Line" temporary)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnRefreshOnAfterGetRecordAfterSumPurchLinesTemp(var TempPurchLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnUpdateHeaderInfoAfterCalcTotalAmount(var PurchaseHeader: Record "Purchase Header"; var IndexNo: Integer)
    begin
    end;
}


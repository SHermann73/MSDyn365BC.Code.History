permissionset 8785 "Recievables Journals - Edit"
{
    Access = Public;
    Assignable = false;
    Caption = 'Create entries in jnls. (S&R)';

    Permissions = tabledata "Bank Account" = R,
                  tabledata "Comment Line" = R,
                  tabledata Currency = R,
                  tabledata "Currency Exchange Rate" = R,
                  tabledata "Currency for Fin. Charge Terms" = R,
                  tabledata "Cust. Ledger Entry" = Rm,
                  tabledata Customer = R,
                  tabledata "Customer Bank Account" = R,
                  tabledata "Default Dimension" = R,
                  tabledata "Default Dimension Priority" = R,
                  tabledata "Detailed Cust. Ledg. Entry" = Ri,
                  tabledata "Finance Charge Terms" = R,
                  tabledata "G/L Account" = R,
                  tabledata "Gen. Business Posting Group" = R,
                  tabledata "Gen. Jnl. Allocation" = RIMD,
                  tabledata "Gen. Journal Batch" = RI,
                  tabledata "Gen. Journal Line" = RIMD,
                  tabledata "Gen. Journal Template" = RI,
                  tabledata "Gen. Product Posting Group" = R,
                  tabledata "General Ledger Setup" = RM,
                  tabledata "General Posting Setup" = R,
#if not CLEAN20
                  tabledata "Native - Payment" = RIMD,
#endif
                  tabledata "Payment Terms" = R,
                  tabledata "Reason Code" = R,
                  tabledata "Salesperson/Purchaser" = R,
                  tabledata "Source Code Setup" = R,
                  tabledata "Tax Area" = R,
                  tabledata "Tax Area Line" = R,
                  tabledata "Tax Detail" = R,
                  tabledata "Tax Group" = R,
                  tabledata "Tax Jurisdiction" = R,
                  tabledata "VAT Assisted Setup Bus. Grp." = R,
                  tabledata "VAT Assisted Setup Templates" = R,
                  tabledata "VAT Business Posting Group" = R,
                  tabledata "VAT Posting Setup" = R,
                  tabledata "VAT Product Posting Group" = R,
                  tabledata "VAT Rate Change Conversion" = R,
                  tabledata "VAT Rate Change Log Entry" = Ri,
                  tabledata "VAT Rate Change Setup" = R,
                  tabledata "VAT Setup Posting Groups" = R,
				  tabledata "VAT Setup" = R,
                  tabledata "VAT Posting Parameters" = R;
}

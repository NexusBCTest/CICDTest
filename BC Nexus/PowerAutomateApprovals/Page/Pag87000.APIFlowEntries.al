page 87000 "API Flow Entries"
{
    APIGroup = 'flow';
    APIPublisher = 'Nexus';
    APIVersion = 'v2.0';
    ApplicationArea = All;
    Caption = 'apiFlowEntries';
    EntityName = 'flowEntry';
    EntitySetName = 'flowEntries';
    PageType = API;
    SourceTable = "Workflow Webhook Entry";
    InsertAllowed = false;
    SourceTableView = sorting("Entry No.")
                      order(ascending);
    Editable = false;

    //Copie de la page 830 "Workflow Webhook Entries", mais en API
    //Ajout d'une action Cancel si jamais on veut utiliser un PowerAutomate pour annuler le workflow dans BC
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(RecordIDText; RecordIDText)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Record';
                    ToolTip = 'Specifies the record that is involved in the workflow. ';
                }
                field(dateTimeInitiated; Rec."Date-Time Initiated")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date and time of the workflow entries.';
                }
                field(initiatedByUserID; Rec."Initiated By User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the User ID which has initiated the workflow.';
                }
                field(response; Rec.Response)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the affected workflow response.';
                }
                field(lastModifiedByUserID; Rec."Last Modified By User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the user who last modified the workflow entry.';
                }
                field(lastDateTimeModified; Rec."Last Date-Time Modified")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies when the workflow entry was last modified.';
                }
                field(notificationStatusText; NotificationStatusText)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Notification Status';
                    ToolTip = 'Specifies status of workflow webhook notification';
                }
                field(notificationErrorText; NotificationErrorText)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Notification Error';
                    ToolTip = 'Specifies error occurred while sending workflow webhook notification.';
                }
                field(workflowStepInstanceID; Rec."Workflow Step Instance ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the workflow step instance ID.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        WorkflowWebhookNotification: Record "Workflow Webhook Notification";
        WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
    begin
        RecordIDText := Format(Rec."Record ID", 0, 1);
        CanCancel := WorkflowWebhookManagement.CanCancel(Rec);
        if FindWorkflowWebhookNotification(Rec."Workflow Step Instance ID", WorkflowWebhookNotification) then begin
            NotificationStatusText := Format(WorkflowWebhookNotification.Status);
            NotificationErrorText := WorkflowWebhookNotification."Error Message";
            CanResendNotification := WorkflowWebhookNotification.Status = WorkflowWebhookNotification.Status::Failed;
        end else begin
            Clear(NotificationStatusText);
            Clear(NotificationErrorText);
            CanResendNotification := false;
        end;

    end;

    var
        CanCancel: Boolean;
        RecordIDText: Text;
        NotificationStatusText: Text;
        NotificationErrorText: Text;
        CanResendNotification: Boolean;


    local procedure FindWorkflowWebhookNotification(WorkflowStepInstanceID: Guid; var WorkflowWebhookNotification: Record "Workflow Webhook Notification"): Boolean
    begin
        WorkflowWebhookNotification.SetRange("Workflow Step Instance ID", WorkflowStepInstanceID);
        exit(WorkflowWebhookNotification.FindFirst());
    end;


    [ServiceEnabled]
    [Scope('Cloud')]
    procedure Cancel(var Actioncontext: WebServiceActionContext)
    var
        WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
    begin
        WorkflowWebhookManagement.Cancel(Rec);
    end;

}

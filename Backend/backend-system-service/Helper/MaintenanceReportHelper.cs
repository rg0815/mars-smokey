using Core.Entities;
using QuestPDF.Fluent;
using QuestPDF.Previewer;

namespace backend_system_service.Helper;

public class MaintenanceReportHelper
{
    public static void GenerateMaintenanceReport(SmokeDetectorMaintenance model)
    {
        var document = Document.Create(container =>
        {
            container.Page(page =>
            {
                
            });
        });
        
        document.ShowInPreviewer();
        





    }
}
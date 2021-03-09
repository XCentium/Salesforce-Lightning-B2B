@isTest
public class HighlightPanelConfigTest {
	@isTest
    private static void ContructorTest() {
        HighlightPanelConfig controller = new HighlightPanelConfig();
        system.assertEquals('Account', controller.selectedObject);
        system.assert(controller.Fields != null);
        system.assert(controller.NumberFields != null);
    }
    
	@isTest
    private static void getObjectTest() {
        HighlightPanelConfig controller = new HighlightPanelConfig();
        List<SelectOption> options = controller.getObjects();
        system.assertEquals(3, options.size());
    }
}
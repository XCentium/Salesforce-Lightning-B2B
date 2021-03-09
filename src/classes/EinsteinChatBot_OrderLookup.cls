public class EinsteinChatBot_OrderLookup {
	@InvocableMethod(label='Get Order Status')
    public static List<Order> getOrderStatus()
    {
        List<Order> orders = [SELECT Name, Status FROM Order where OrderNumber = '00000229'];
        return orders;
    }
}
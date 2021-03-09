global class GetURLValue {
    @InvocableMethod
   	public static List<String> getURLParam() {
      List<String> vProductId = new List<String>();
      vProductId.add(apexPages.currentPage().getParameters().get('vProductId'));
      return vProductId;
   }
}
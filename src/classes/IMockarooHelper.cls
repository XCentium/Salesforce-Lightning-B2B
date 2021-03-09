public interface IMockarooHelper {
	List<List<String>> getData(String dataUrl, Boolean skipHeaders);
	String validateDataURL(String dataUrl);
	List<String> getSchemaFieldNames(String dataUrl);
}
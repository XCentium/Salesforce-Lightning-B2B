public class PSDemoUtils
{
  private static Map<String, String> stateLongMap = new Map<String, String>();

  static
  {
    stateLongMap.put('Alabama', 'AL');
    stateLongMap.put('Alaska', 'AK');
    stateLongMap.put('Arizona', 'AZ');
    stateLongMap.put('Arkansas', 'AR');
    stateLongMap.put('California', 'CA');
    stateLongMap.put('Colorado', 'CO');
    stateLongMap.put('Connecticut', 'CT');
    stateLongMap.put('Delaware', 'DE');
    stateLongMap.put('Florida', 'FL');
    stateLongMap.put('Georgia', 'GA');
    stateLongMap.put('Hawaii', 'HI');
    stateLongMap.put('Idaho', 'ID');
    stateLongMap.put('Illinois', 'IL');
    stateLongMap.put('Indiana', 'IN');
    stateLongMap.put('Iowa', 'IA');
    stateLongMap.put('Kansas', 'KS');
    stateLongMap.put('Kentucky', 'KY');
    stateLongMap.put('Louisiana', 'LA');
    stateLongMap.put('Maine', 'ME');
    stateLongMap.put('Maryland', 'MD');
    stateLongMap.put('Massachusetts', 'MA');
    stateLongMap.put('Michigan', 'MI');
    stateLongMap.put('Minnesota', 'MN');
    stateLongMap.put('Mississippi', 'MS');
    stateLongMap.put('Missouri', 'MO');
    stateLongMap.put('Montana', 'MT');
    stateLongMap.put('Nebraska', 'NE');
    stateLongMap.put('Nevada', 'NV');
    stateLongMap.put('New Hampshire', 'NH');
    stateLongMap.put('New Jersey', 'NJ');
    stateLongMap.put('New Mexico', 'NM');
    stateLongMap.put('New York', 'NY');
    stateLongMap.put('North Carolina', 'NC');
    stateLongMap.put('North Dakota', 'ND');
    stateLongMap.put('Ohio', 'OH');
    stateLongMap.put('Oklahoma', 'OK');
    stateLongMap.put('Oregon', 'OR');
    stateLongMap.put('Pennsylvania', 'PA');
    stateLongMap.put('Rhode Island', 'RI');
    stateLongMap.put('South Carolina', 'SC');
    stateLongMap.put('South Dakota', 'SD');
    stateLongMap.put('Tennessee', 'TN');
    stateLongMap.put('Texas', 'TX');
    stateLongMap.put('Utah', 'UT');
    stateLongMap.put('Vermont', 'VT');
    stateLongMap.put('Virginia', 'VA');
    stateLongMap.put('Washington', 'WA');
    stateLongMap.put('West Virginia', 'WV');
    stateLongMap.put('Wisconsin', 'WI');
    stateLongMap.put('Wyoming', 'WY');
  }

  public PSDemoUtils()
  {

  }

  public static List<String> parseCSVString(String str)
  {
    return parseDelimitedString(str, ',');
  }
    
  public static List<String> parseDelimitedString(String str, String delim)
  {
    List<String> optList = new List<String>();
    for (String key : str.split(delim))
    {
      optList.add(key.trim());
    }

    return optList;
  }

  public static String convertStateToShort(String stateLong)
  {
    if (stateLongMap.containsKey(stateLong))
    {
      return stateLongMap.get(stateLong);
    }
    else
    {
      return '';
    }
  }

  public static String readStaticResourceJsonFile(String name)
  {
    StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = :name];
    if (sr != null)
    {
      String replaceIllegal = sr.Body.toString().replaceAll('\n', '').replaceAll('\r', '');
      return replaceIllegal;
    }
    return null;
  }

  public static String n2s(String val)
  {
    if (val == null)
    {
      return '';
    }
    else
    {
      return val;
    }
  }
}
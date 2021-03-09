public with sharing class CSV_RowIterator implements Iterator<String>, Iterable<String>
{
	private string m_Data;
	private Integer m_index = 0;
	private Integer csvStringLength = 0;
	private static string COMMA = ',';
	private static string NL = '\n';
	private static string QUOTE = '"';
	private static string DOUBLE_QUOTE = '""';
	public CSV_RowIterator(string fileData)
	{
		m_Data = fileData;
		csvStringLength = m_Data.length();
	}
	public Boolean hasNext()
	{
		return m_index < csvStringLength ? true : false;
	}
	public String next()
	{
		Integer startPos = m_index;
		String currentValue;
		Integer cAt, nlAt, foundAt;
		List<String> tmpValues = new  List<String>();
		while (m_index < csvStringLength)
		{
			cAt = this.m_Data.indexOf(COMMA, m_index);
			nlAt = this.m_Data.indexOf(NL, m_index);
			foundAt = Math.min(cAt, nlAt);
			if(foundAt == -1)
			{
				foundAt = Math.max(cAt, nlAt);
			}
			if(foundAt == -1)
			{
				currentValue = this.m_Data.substring(startPos);
				m_index = this.csvStringLength;
			}
			else
			{
				currentValue = this.m_Data.substring(startPos, foundAt);
				m_index = foundAt + 1;
			}
			if(!currentValue.startsWith(QUOTE) || (currentValue.endsWith(QUOTE) && !currentValue.endsWith(DOUBLE_QUOTE)))
			{
				tmpValues.add(currentValue);
				if(foundAt == nlAt)
				{
					break;
				}
				startPos = m_index;
			}
		}
		return String.join(tmpValues, ',');
	}
	public Iterator<String> Iterator()
	{
		return this;
	}
}
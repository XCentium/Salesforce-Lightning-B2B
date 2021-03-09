public with sharing virtual class WaveCsvDataRetriever implements IMockarooHelper {
	
	public WaveCsvDataRetriever() {
		
	}

	public List<List<String>> getData(String dataUrl, Boolean skipHeaders){
		
		String contents = this.mockarooCallout(dataUrl);
        Utility_RowIterator r = New Utility_RowIterator(contents, '\n');
        List<String> lines = new List<String>();

        while(r.hasNext()) {
            
            // We quit the '\r' character
            String rawLine = r.next();
            String line = rawLine.replaceAll('\r', '');
            
            // check for blank CSV lines (only commas)
            if (!String.isBlank(line.replaceAll(',',''))){
                lines.add(line);            
            }
        }

        List<List<String>> allFields = CSVReader.Parse(String.join(lines, '\n'));

        if(skipHeaders){
        	allFields.remove(0);
        }

        return allFields;
	}

	public String validateDataURL(String dataUrl){
		String validationMessage = '';
		return validationMessage;
	}

	public List<String> getSchemaFieldNames(String dataUrl){
		List<String> lstFields = new List<String>();

		String contents = this.mockarooCallout(dataUrl);
		
		if(!String.isBlank(contents)){
			List<String> lines = contents.split('\n');

			if(lines.size() > 0){
				String headers = lines.get(0);
				lstFields = headers.trim().split(',');
			}
		}

		return lstFields;
	}

	protected String mockarooCallout(String url){

		HttpRequest req = new HttpRequest();
		req.setEndpoint(url);
        req.setMethod('GET');
        req.setTimeout(120000);

		Http http = new Http();
        HTTPResponse res = http.send(req);

        if(res.getStatusCode() == 200){
        	return res.getBody();
        }

        return '';
	}
}
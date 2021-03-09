public with sharing class PSEsriGeocodeResponse {
	public PSEsriGeocodeResponse() {
		
	}

	public SpatialReference spatialReference;
	public List<Candidates> candidates;

	public class SpatialReference
	{
		public Integer wkid;
		public Integer latestWkid;
	}

	public class Candidates
	{
       public String address;
       public Location location;
       public Integer score;
       public Extent extent;
	}

	public class Location
	{
		public Decimal x;
		public Decimal y;
	}

	public class Extent
	{
		public Decimal xmin;
		public Decimal ymin;
		public Decimal xmax;
		public Decimal ymax;
	}
}
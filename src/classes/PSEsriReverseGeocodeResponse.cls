public with sharing class PSEsriReverseGeocodeResponse {
    public PSEsriReverseGeocodeResponse() {
        
    }
    
    public Address address;
    public Location location;
    
    public class Address
    {
        public String Address;
        public String Neighborhood;
        public String City;
        public String Subregion;
        public String Region;
        public String Postal;
        public String PostalExt;
        public String CountryCode;
        public String Match_addr;
        public String Loc_name;
        public String Addr_type;
    }
    
    public class Location
    {
        public Decimal x;
        public Decimal y;
        public SpatialReference spatialReference;
    }
    
    public class SpatialReference
    {
        public Integer wkid;
        public Integer latestWkid;
    }
    
    public String getFullAddress()
    {
        String tmpAddr = '';
        
        if (address.Address != null && address.Address.length() > 0)
        {
            tmpAddr = address.Address;
        }
        
        if (address.City != null && address.City.length() > 0)
        {
            if (tmpAddr.length() > 0)
            {
                tmpAddr += ', ' + address.City;
            }
            else
            {
                tmpAddr = address.City;
            }
        }
        
        if (address.Region != null && address.Region.length() > 0)
        {
            if (tmpAddr.length() > 0)
            {
                tmpAddr += ', ' + address.Region;
            }
            else
            {
                tmpAddr = address.Region;
            }
        }
        
        if (address.Postal != null && address.Postal.length() > 0)
        {
            if (tmpAddr.length() > 0)
            {
                tmpAddr += ' ' + address.Postal;
            }
            else
            {
                tmpAddr = address.Postal;
            }
        }
        
        return tmpAddr;
        
    }
}
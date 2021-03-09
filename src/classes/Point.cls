global with sharing class Point {
	
    public Double latitude {get; set;}
    public Double longitude {get; set;}

	public Point(Double lat, Double lng){
      latitude=Modulo(lat, 180);
      longitude=Modulo(lng, 180);
    }
    public Point(Decimal lat, Decimal lng){
      latitude=Modulo((Double)lat, 180);
      longitude=Modulo((Double)lng, 180);
    }

    public Double LatitudeToRad(){
      return latitude * (Math.PI / 180);
    }

    public Double LongitudeToRad(){
      return longitude * (Math.PI / 180);
    }

	private Static Double Modulo(Decimal a, Decimal b){
    Integer sign = 1;
    if (a<0){
      sign = -1;
      a = a * -1;
    }
    while(a>=b){
      a-=b;
    }
    return (Double)a * sign;
  }
}
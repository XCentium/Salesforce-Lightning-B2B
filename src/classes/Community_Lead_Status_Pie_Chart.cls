public class Community_Lead_Status_Pie_Chart {

    public List<PieWedgeData> getPieData() {
        String ownerID = UserInfo.getUserID();
        List<AggregateResult> leadlist = [Select COUNT(Name) c, Status s From Lead Where OwnerID =: UserInfo.getUserId() GROUP BY Status];
        List<PieWedgeData> data = new List<PieWedgeData>();
        for(AggregateResult a : leadlist) {
            data.add(new PieWedgeData(String.valueOf(a.get('s')), Integer.Valueof(a.get('c'))));
        }
        return data;
    }

    // Wrapper class
    public class PieWedgeData {
        public String name { get; set; }
        public Integer data { get; set; }

        public PieWedgeData(String name, Integer data) {
            this.name = name;
            this.data = data;
        }
    }
}
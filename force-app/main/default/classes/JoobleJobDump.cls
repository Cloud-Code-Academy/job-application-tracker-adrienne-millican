/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-12-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class JoobleJobDump {
  public Integer totalCount;
  public List<JoobleJob> jobsLst;
  public class JoobleJob {
    public String title { get; private set; }
    public String location { get; private set; }
    public String snippet { get; private set; }
    public String salary { get; private set; }
    public String source { get; private set; }
    public String type { get; private set; }
    public String link { get; private set; }
    public String company { get; private set; }
    public String updated { get; private set; }
    public String id { get; private set; }
  }
  public static JoobleJobDump parse(String jsonStr) {
    return (JoobleJobDump) JSON.deserialize(jsonStr, JoobleJobDump.class);
  }
}
/*
 * Generated by the Jasper component of Apache Tomcat
 * Version: JspC/ApacheTomcat9
 * Generated at: 2024-10-09 09:01:53 UTC
 * Note: The last modified time of this file was set to
 *       the last modified time of the source file after
 *       generation to assist with modification tracking.
 */
package jsp.includes.js;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;
import com.atlassian.jira.config.properties.ApplicationProperties;
import com.atlassian.jira.config.properties.APKeys;
import com.atlassian.jira.component.ComponentAccessor;
import com.atlassian.jira.config.properties.LookAndFeelBean;

public final class ts_005fpicker_jsp extends org.apache.jasper.runtime.HttpJspBase
    implements org.apache.jasper.runtime.JspSourceDependent,
                 org.apache.jasper.runtime.JspSourceImports {

  private static final javax.servlet.jsp.JspFactory _jspxFactory =
          javax.servlet.jsp.JspFactory.getDefaultFactory();

  private static java.util.Map<java.lang.String,java.lang.Long> _jspx_dependants;

  private static final java.util.Set<java.lang.String> _jspx_imports_packages;

  private static final java.util.Set<java.lang.String> _jspx_imports_classes;

  static {
    _jspx_imports_packages = new java.util.HashSet<>();
    _jspx_imports_packages.add("javax.servlet");
    _jspx_imports_packages.add("javax.servlet.http");
    _jspx_imports_packages.add("javax.servlet.jsp");
    _jspx_imports_classes = new java.util.HashSet<>();
    _jspx_imports_classes.add("com.atlassian.jira.config.properties.LookAndFeelBean");
    _jspx_imports_classes.add("com.atlassian.jira.config.properties.ApplicationProperties");
    _jspx_imports_classes.add("com.atlassian.jira.component.ComponentAccessor");
    _jspx_imports_classes.add("com.atlassian.jira.config.properties.APKeys");
  }

  private volatile javax.el.ExpressionFactory _el_expressionfactory;
  private volatile org.apache.tomcat.InstanceManager _jsp_instancemanager;

  public java.util.Map<java.lang.String,java.lang.Long> getDependants() {
    return _jspx_dependants;
  }

  public java.util.Set<java.lang.String> getPackageImports() {
    return _jspx_imports_packages;
  }

  public java.util.Set<java.lang.String> getClassImports() {
    return _jspx_imports_classes;
  }

  public javax.el.ExpressionFactory _jsp_getExpressionFactory() {
    if (_el_expressionfactory == null) {
      synchronized (this) {
        if (_el_expressionfactory == null) {
          _el_expressionfactory = _jspxFactory.getJspApplicationContext(getServletConfig().getServletContext()).getExpressionFactory();
        }
      }
    }
    return _el_expressionfactory;
  }

  public org.apache.tomcat.InstanceManager _jsp_getInstanceManager() {
    if (_jsp_instancemanager == null) {
      synchronized (this) {
        if (_jsp_instancemanager == null) {
          _jsp_instancemanager = org.apache.jasper.runtime.InstanceManagerFactory.getInstanceManager(getServletConfig());
        }
      }
    }
    return _jsp_instancemanager;
  }

  public void _jspInit() {
  }

  public void _jspDestroy() {
  }

  public void _jspService(final javax.servlet.http.HttpServletRequest request, final javax.servlet.http.HttpServletResponse response)
      throws java.io.IOException, javax.servlet.ServletException {

    if (!javax.servlet.DispatcherType.ERROR.equals(request.getDispatcherType())) {
      final java.lang.String _jspx_method = request.getMethod();
      if ("OPTIONS".equals(_jspx_method)) {
        response.setHeader("Allow","GET, HEAD, POST, OPTIONS");
        return;
      }
      if (!"GET".equals(_jspx_method) && !"POST".equals(_jspx_method) && !"HEAD".equals(_jspx_method)) {
        response.setHeader("Allow","GET, HEAD, POST, OPTIONS");
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "JSPs only permit GET, POST or HEAD. Jasper also permits OPTIONS");
        return;
      }
    }

    final javax.servlet.jsp.PageContext pageContext;
    javax.servlet.http.HttpSession session = null;
    final javax.servlet.ServletContext application;
    final javax.servlet.ServletConfig config;
    javax.servlet.jsp.JspWriter out = null;
    final java.lang.Object page = this;
    javax.servlet.jsp.JspWriter _jspx_out = null;
    javax.servlet.jsp.PageContext _jspx_page_context = null;


    try {
      response.setContentType("text/html");
      pageContext = _jspxFactory.getPageContext(this, request, response,
      			null, true, 8192, true);
      _jspx_page_context = pageContext;
      application = pageContext.getServletContext();
      config = pageContext.getServletConfig();
      session = pageContext.getSession();
      out = pageContext.getOut();
      _jspx_out = out;

      out.write('\n');
      out.write('\n');

    //this file needs to be a jsp so that we can process the look and feel of it.
    ApplicationProperties ap = ComponentAccessor.getApplicationProperties();
    final LookAndFeelBean lookAndFeelBeanTSPicker = LookAndFeelBean.getInstance(ap);
    String topBgColour = lookAndFeelBeanTSPicker.getTopBackgroundColour();
    String topTxtColour = lookAndFeelBeanTSPicker.getTopTxtColour();

      out.write("\n\n// Title: Timestamp picker\n// Description: See the demo at url\n// URL: http://www.softcomplex.com/products/tigra_calendar/\n// Version: 1.0\n// Date: 12-05-2001 (mm-dd-yyyy)\n// Author: Denis Gritcyuk <denis@softcomplex.com>\n// Notes: Permission given to use this script in any kind of applications if\n//    header lines are left unchanged. Feel free to contact the author\n//    for feature requests and/or donations\n\nfunction show_calendar(context_path, formName, formObj, element)\n{\n    show_calendar_func(context_path, 'document.' + formName + '.elements[\\'' + element + '\\']', formObj.elements[element].value, formObj.elements[element].value);\n}\n\nfunction show_calendar_func(context_path, str_target, str_datetime, str_month)\n{\n    escapeTarget(str_target);\n\tvar arr_months = [\"January\", \"February\", \"March\", \"April\", \"May\", \"June\", \"July\", \"August\", \"September\", \"October\", \"November\", \"December\"];\n\tvar week_days = [\"Su\", \"Mo\", \"Tu\", \"We\", \"Th\", \"Fr\", \"Sa\"];\n\tvar n_weekstart = 1; // day week starts from (normally 0 or 1)\n");
      out.write("\n\tvar dt_datetime = (str_datetime == null || str_datetime ==\"\" ?  new Date() : str2dt2(str_datetime));\n\tvar dt_month = (str_month == null || str_month ==\"\" ?  new Date() : str2dt2(str_month));\n\tvar dt_prev_month = new Date(dt_month);\n\tdt_prev_month.setMonth(dt_month.getMonth()-1);\n\tif (dt_month.getMonth()%12 != (dt_prev_month.getMonth()+1)%12)\n    {\n\t\tdt_prev_month.setMonth(dt_month.getMonth());\n\t\tdt_prev_month.setDate(0);\n\t}\n\tvar dt_next_month = new Date(dt_month);\n\tdt_next_month.setMonth(dt_month.getMonth()+1);\n\tif ((dt_month.getMonth() + 1)%12 != dt_next_month.getMonth()%12)\n\t\tdt_next_month.setDate(0);\n\n\tvar dt_firstday = new Date(dt_month);\n\tdt_firstday.setDate(1);\n\tdt_firstday.setDate(1-(7+dt_firstday.getDay()-n_weekstart)%7);\n\tvar dt_lastday = new Date(dt_next_month);\n\tdt_lastday.setDate(0);\n\n\t// html generation (feel free to tune it for your particular application)\n\t// print calendar header\n\tvar str_buffer = new String\n    (\n\t\t\"<html>\\n\"+\n\t\t\"<head>\\n\"+\n\t\t\"\t<title>Calendar</title>\\n\"+\n\t\t\"</head>\\n\"+\n\t\t\"<body bgcolor=\\\"f0f0f0\\\" leftmargin=\\\"0\\\" topmargin=\\\"0\\\" marginwidth=\\\"0\\\" marginheight=\\\"0\\\">\\n\"+\n");
      out.write("\t\t\"<table class=\\\"clsOTable\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" border=\\\"0\\\" width=\\\"100%\\\">\\n\"+\n\t\t\"<tr>\\n\t<td bgcolor=\\\"");
      out.print( topBgColour );
      out.write("\\\" width=1% nowrap>&nbsp;<a href=\\\"javascript:window.opener.show_calendar_func('\" + context_path + \"', '\"+\n\t\tescapeTarget(str_target)+\"', '\"+ dt2dtstr2(dt_datetime)+\"', '\"+ dt2dtstr2(dt_prev_month)+\"');\\\">\"+\n\t\t\"<img src=\\\"\"+context_path+\"/images/icons/prev.gif\\\" width=\\\"16\\\" height=\\\"16\\\" border=\\\"0\\\"\"+\n\t\t\" alt=\\\"previous month\\\"></a></td>\\n\"+\n\t\t\"\t<td bgcolor=\\\"");
      out.print( topBgColour );
      out.write("\\\" align=center width=100%>\"+\n\t\t\"<font color=\\\"");
      out.print( topTxtColour );
      out.write("\\\" face=\\\"Verdana, Sans-Serif\\\" size=\\\"2\\\"><b>\"\n\t\t+arr_months[dt_month.getMonth()]+\" \"+dt_month.getFullYear()+\"</b></font></td>\\n\"+\n\t\t\"\t<td bgcolor=\\\"");
      out.print( topBgColour );
      out.write("\\\"  width=1% align=\\\"right\\\" nowrap><a href=\\\"javascript:window.opener.show_calendar_func('\" + context_path + \"', '\"\n\t\t+escapeTarget(str_target)+\"', '\"+ dt2dtstr2(dt_datetime)+\"', '\"+ dt2dtstr2(dt_next_month)+\"');\\\">\"+\n\t\t\"<img src=\\\"\"+context_path+\"/images/icons/next.gif\\\" width=\\\"16\\\" height=\\\"16\\\" border=\\\"0\\\"\"+\n\t\t\" alt=\\\"next month\\\"></a>&nbsp;</td>\\n</tr>\\n\" +\n\t\t\"<tr><td colspan=3 bgcolor=\\\"#bbbbbb\\\">\\n\"+\n\t\t\"<table cellspacing=\\\"1\\\" cellpadding=\\\"3\\\" border=\\\"0\\\" width=\\\"100%\\\">\\n\"\n    );\n\n\tvar dt_current_day = new Date(dt_firstday);\n\t// print weekdays titles\n\tstr_buffer += \"<tr>\\n\";\n\tfor (var n=0; n<7; n++)\n\t\tstr_buffer += \"\t<td bgcolor=\\\"#f0f0f0\\\" align=center>\"+\n\t\t\"<font face=\\\"Verdana, Sans-Serif\\\" size=\\\"2\\\">\"+\n\t\tweek_days[(n_weekstart+n)%7]+\"</font></td>\\n\";\n\t// print calendar table\n\tstr_buffer += \"</tr>\\n\";\n\twhile (dt_current_day.getMonth() == dt_month.getMonth() ||\n\t\tdt_current_day.getMonth() == dt_firstday.getMonth()) {\n\t\t// print row header\n\t\tstr_buffer += \"<tr>\\n\";\n\t\tfor (var n_current_wday=0; n_current_wday<7; n_current_wday++) {\n");
      out.write("\t\t\t\tif (dt_current_day.getDate() == dt_datetime.getDate() &&\n\t\t\t\t\tdt_current_day.getMonth() == dt_datetime.getMonth())\n\t\t\t\t\t// print current date\n\t\t\t\t\tstr_buffer += \"\t<td bgcolor=\\\"#DBEAF5\\\" align=\\\"right\\\">\";\n\t\t\t\telse if (dt_current_day.getDay() == 0 || dt_current_day.getDay() == 6)\n\t\t\t\t\t// weekend days\n\t\t\t\t\tstr_buffer += \"\t<td bgcolor=\\\"#fffff0\\\" align=\\\"right\\\">\";\n\t\t\t\telse\n\t\t\t\t\t// print working days of current month\n\t\t\t\t\tstr_buffer += \"\t<td bgcolor=\\\"white\\\" align=\\\"right\\\">\";\n\n\t\t\t\tif (dt_current_day.getMonth() == dt_month.getMonth())\n\t\t\t\t\t// print days of current month\n\t\t\t\t\tstr_buffer += \"<a href=\\\"javascript:window.opener.\"+str_target+\n\t\t\t\t\t\".value='\"+dt2dtstr2(dt_current_day)+\"'; window.close();\\\">\"+\n\t\t\t\t\t\"<font color=\\\"black\\\" face=\\\"Verdana, Sans-Serif\\\" size=\\\"2\\\">\";\n\t\t\t\telse\n\t\t\t\t\t// print days of other months\n\t\t\t\t\tstr_buffer += \"<a href=\\\"javascript:window.opener.\"+str_target+\n\t\t\t\t\t\".value='\"+dt2dtstr2(dt_current_day)+\"'; window.close();\\\">\"+\n\t\t\t\t\t\"<font color=\\\"gray\\\" face=\\\"Verdana, Sans-Serif\\\" size=\\\"2\\\">\";\n");
      out.write("\t\t\t\tstr_buffer += dt_current_day.getDate()+\"</font></a></td>\\n\";\n\t\t\t\tdt_current_day.setDate(dt_current_day.getDate()+1);\n\t\t}\n\t\t// print row footer\n\t\tstr_buffer += \"</tr>\\n\";\n\t}\n\t// print calendar footer\n\tstr_buffer +=\n        \"<tr><td colspan=7 bgcolor=#f0f0f0 align=center><font size=\\\"1\\\" face=\\\"Verdana, Sans-Serif\\\">\\n\" +\n        \"<a href=\\\"javascript:window.opener.\"+str_target+\n\t\t\".value='\"+dt2dtstr2(new Date())+\"'; window.close();\\\">Today</a> | \\n\" +\n        \"<a href=\\\"javascript:window.opener.\"+str_target+\".value=''; window.close();\\\">Clear</a>\\n\" +\n        \"</font>\\n\" +\n\t\t\"</td></tr></table>\\n\" +\n\t\t\"</tr>\\n</td>\\n</table>\\n\" +\n        \"<table border=\\\"0\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" width=\\\"100%\\\">\\n\" +\n        \"<tr>\\n\" +\n        \"<td height=12 background=\\\"\"+context_path+\"/images/border/border_bottom.gif\\\"><img src=\\\"\"+context_path+\"/images/border/spacer.gif\\\" width=\\\"1\\\" height=\\\"1\\\" border=\\\"0\\\"></td>\\n\" +\n        \"</tr>\\n\" +\n        \"</table>\\n\" +\n\t\t\"</body>\\n\" +\n\t\t\"</html>\\n\";\n\n\tvar vWinCal = window.open(\"\", \"Calendar\",\n");
      out.write("\t\t\"width=220,height=220,status=no,resizable=yes,top=220,left=200\");\n\tvWinCal.opener = self;\n\tvWinCal.focus();\n\tvar calc_doc = vWinCal.document;\n\tcalc_doc.write (str_buffer);\n\tcalc_doc.close();\n}\n\n// datetime parsing and formatting routimes. modify them if you wish other datetime format\nfunction month2int (str_month)\n{\n    switch (str_month) {\n        case \"Jan\":\n            return 0;\n        break;\n        case \"Feb\":\n            return 1;\n        break;\n        case \"Mar\":\n            return 2;\n        break;\n        case \"Apr\":\n            return 3;\n        break;\n        case \"May\":\n            return 4;\n        break;\n        case \"Jun\":\n            return 5;\n        break;\n        case \"Jul\":\n            return 6;\n        break;\n        case \"Aug\":\n            return 7;\n        break;\n        case \"Sep\":\n            return 8;\n        break;\n        case \"Oct\":\n            return 9;\n        break;\n        case \"Nov\":\n            return 10;\n        break;\n        case \"Dec\":\n            return 11;\n        break;\n");
      out.write("    }\n}\n\nfunction str2dt2 (str_datetime)\n{\n\tvar re_date = /^(\\d+)\\-(...)\\-(\\d+)$/;\n\tif (!re_date.exec(str_datetime))\n\t\treturn alert(\"Invalid Datetime format: \"+ str_datetime);\n\treturn (new Date (RegExp.$3, month2int(RegExp.$2), RegExp.$1));\n}\nfunction dt2dtstr2 (dt_datetime)\n{\n    var monthsShort = [\"Jan\", \"Feb\", \"Mar\", \"Apr\",\n                       \"May\", \"Jun\", \"Jul\", \"Aug\", \"Sep\",\n                       \"Oct\", \"Nov\", \"Dec\"];\n\treturn (new String (dt_datetime.getDate()+\"-\"+monthsShort[(dt_datetime.getMonth())]+\"-\"+dt_datetime.getFullYear()));\n}\nfunction escapeTarget(srcTarget)\n{\n    var splitUp = srcTarget.split(\"'\");\n    var returnString = \"\";\n    for (var i=0;i<splitUp.length;i++)\n    {\n        returnString += splitUp[i] + \"\\\\'\";\n    }\n    return returnString.substr(0,returnString.length-2);\n}\n");
    } catch (java.lang.Throwable t) {
      if (!(t instanceof javax.servlet.jsp.SkipPageException)){
        out = _jspx_out;
        if (out != null && out.getBufferSize() != 0)
          try {
            if (response.isCommitted()) {
              out.flush();
            } else {
              out.clearBuffer();
            }
          } catch (java.io.IOException e) {}
        if (_jspx_page_context != null) _jspx_page_context.handlePageException(t);
        else throw new ServletException(t);
      }
    } finally {
      _jspxFactory.releasePageContext(_jspx_page_context);
    }
  }
}
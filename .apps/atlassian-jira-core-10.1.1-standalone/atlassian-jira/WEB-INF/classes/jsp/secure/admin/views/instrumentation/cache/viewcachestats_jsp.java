/*
 * Generated by the Jasper component of Apache Tomcat
 * Version: JspC/ApacheTomcat9
 * Generated at: 2024-10-09 09:01:56 UTC
 * Note: The last modified time of this file was set to
 *       the last modified time of the source file after
 *       generation to assist with modification tracking.
 */
package jsp.secure.admin.views.instrumentation.cache;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;

public final class viewcachestats_jsp extends org.apache.jasper.runtime.HttpJspBase
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
    _jspx_imports_classes = null;
  }

  private org.apache.jasper.runtime.TagHandlerPool _005fjspx_005ftagPool_005fww_005ftext_0026_005fname_005fnobody;
  private org.apache.jasper.runtime.TagHandlerPool _005fjspx_005ftagPool_005fww_005fiterator_0026_005fvalue;
  private org.apache.jasper.runtime.TagHandlerPool _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody;

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
    _005fjspx_005ftagPool_005fww_005ftext_0026_005fname_005fnobody = org.apache.jasper.runtime.TagHandlerPool.getTagHandlerPool(getServletConfig());
    _005fjspx_005ftagPool_005fww_005fiterator_0026_005fvalue = org.apache.jasper.runtime.TagHandlerPool.getTagHandlerPool(getServletConfig());
    _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody = org.apache.jasper.runtime.TagHandlerPool.getTagHandlerPool(getServletConfig());
  }

  public void _jspDestroy() {
    _005fjspx_005ftagPool_005fww_005ftext_0026_005fname_005fnobody.release();
    _005fjspx_005ftagPool_005fww_005fiterator_0026_005fvalue.release();
    _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody.release();
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

      out.write("\n\n<html>\n<head>\n    <meta name=\"admin.active.section\" content=\"admin_system_menu/top_system_section/troubleshooting_and_support\"/>\n    <meta name=\"admin.active.tab\" content=\"instrumentation\"/>\n    <title>");
      if (_jspx_meth_ww_005ftext_005f0(_jspx_page_context))
        return;
      out.write("</title>\n\n    <script type=\"text/javascript\" src=\"https://www.google.com/jsapi\"></script>\n    <script>\n        try\n        {\n            google.load(\"visualization\", \"1.0\", {packages: [\"table\", \"corechart\", 'controls']});\n            google.setOnLoadCallback(drawChart);\n            var data = null;\n            function drawChart()\n            {\n                data = google.visualization.arrayToDataTable([\n                    [\"Name\", \"Name\", \"Type\", \"Hit Count\", \"Hit Count\", \"Miss Count\", \"Load Time(ns)\", \"Size\"],\n                    ");
      if (_jspx_meth_ww_005fiterator_005f0(_jspx_page_context))
        return;
      out.write("\n                ]);\n\n                // Format the data in the table.\n                var formatter = new google.visualization.PatternFormat('<a href=\"ViewCacheDetails.jspa?name={0}\">{1}</a>');\n                formatter.format(data, [0, 1]);\n\n                var hitCountFormatter = new google.visualization.BarFormat({width: 100});\n                hitCountFormatter.format(data, 3);\n\n                var loadTimeFormatter = new google.visualization.NumberFormat({pattern: '#0.00'});\n                loadTimeFormatter.format(data, 6);\n\n                var sizeFormatter = new google.visualization.NumberFormat({pattern: '####'});\n                sizeFormatter.format(data, 7);\n\n                // Build wrapper so we  can tie it to the filters\n                var table = new google.visualization.ChartWrapper(\n                {\n                    chartType: 'Table',\n                    containerId: 'chart',\n                    view: {columns: [0, 2, 3, 5, 6, 7]},\n                    options:\n                    {\n                        vAxis: {textStyle: {fontSize: 12}, gridLines: {count: '5'}},\n");
      out.write("                        bar: {groupWidth: '100%'},\n                        sortAscending: false,\n                        sortColumn: 2,\n                        allowHtml: true\n                    }\n                });\n\n\n                var dashboard = new google.visualization.Dashboard(document.querySelector('#dashboard'));\n\n                var stringFilter = new google.visualization.ControlWrapper(\n                {\n                    controlType: 'StringFilter',\n                    containerId: 'string_filter_div',\n                    options:\n                    {\n                        filterColumnIndex: 0,\n                        matchType: 'any',\n                        caseSensitive: false,\n                        ui: {label: 'Search'}\n                    }\n                });\n\n                dashboard.bind([stringFilter], [table]);\n                dashboard.draw(data)\n            }\n\n            // Convert the DataView to a CSV\n            function downloadCSV()\n            {\n                var dv = new google.visualization.DataView(data);\n");
      out.write("                dv.hideColumns([0, 3]);\n                var filteredTable = dv.toDataTable();\n\n                var blob = new Blob([google.visualization.dataTableToCsv(filteredTable)], {type: 'text/csv;charset=utf-8'});\n                var url = window.URL || window.webkitURL;\n                var link = document.createElementNS(\"http://www.w3.org/1999/xhtml\", \"a\");\n                link.href = url.createObjectURL(blob);\n                link.download = \"download.csv\";\n\n                var event = document.createEvent(\"MouseEvents\");\n                event.initEvent(\"click\", true, false);\n                link.dispatchEvent(event);\n            }\n        }\n        catch(err)\n        {\n            // who cares for now\n        }\n    </script>\n</head>\n<body>\n<h2>Cache Statistics</h2>\n<div id=\"dashboard\">\n    <div style=\"float:right\"><a href='javascript:downloadCSV()'>CSV</a></div>\n    <div id=\"string_filter_div\"></div>\n    <div id=\"chart\"></div>\n</div>\n</body>\n</html>\n");
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

  private boolean _jspx_meth_ww_005ftext_005f0(javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  ww:text
    com.atlassian.jira.web.tags.TextTag _jspx_th_ww_005ftext_005f0 = (com.atlassian.jira.web.tags.TextTag) _005fjspx_005ftagPool_005fww_005ftext_0026_005fname_005fnobody.get(com.atlassian.jira.web.tags.TextTag.class);
    boolean _jspx_th_ww_005ftext_005f0_reused = false;
    try {
      _jspx_th_ww_005ftext_005f0.setPageContext(_jspx_page_context);
      _jspx_th_ww_005ftext_005f0.setParent(null);
      // /secure/admin/views/instrumentation/cache/viewcachestats.jsp(7,11) name = name type = java.lang.String reqTime = false required = true fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ww_005ftext_005f0.setName("'admin.instrumentation.page.title'");
      int _jspx_eval_ww_005ftext_005f0 = _jspx_th_ww_005ftext_005f0.doStartTag();
      if (_jspx_th_ww_005ftext_005f0.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005fww_005ftext_0026_005fname_005fnobody.reuse(_jspx_th_ww_005ftext_005f0);
      _jspx_th_ww_005ftext_005f0_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_ww_005ftext_005f0, _jsp_getInstanceManager(), _jspx_th_ww_005ftext_005f0_reused);
    }
    return false;
  }

  private boolean _jspx_meth_ww_005fiterator_005f0(javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  ww:iterator
    webwork.view.taglib.IteratorTag _jspx_th_ww_005fiterator_005f0 = (webwork.view.taglib.IteratorTag) _005fjspx_005ftagPool_005fww_005fiterator_0026_005fvalue.get(webwork.view.taglib.IteratorTag.class);
    boolean _jspx_th_ww_005fiterator_005f0_reused = false;
    try {
      _jspx_th_ww_005fiterator_005f0.setPageContext(_jspx_page_context);
      _jspx_th_ww_005fiterator_005f0.setParent(null);
      // /secure/admin/views/instrumentation/cache/viewcachestats.jsp(20,20) name = value type = java.lang.String reqTime = false required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ww_005fiterator_005f0.setValue("cacheStats");
      int _jspx_eval_ww_005fiterator_005f0 = _jspx_th_ww_005fiterator_005f0.doStartTag();
      if (_jspx_eval_ww_005fiterator_005f0 != javax.servlet.jsp.tagext.Tag.SKIP_BODY) {
        if (_jspx_eval_ww_005fiterator_005f0 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
          out = org.apache.jasper.runtime.JspRuntimeLibrary.startBufferedBody(_jspx_page_context, _jspx_th_ww_005fiterator_005f0);
        }
        do {
          out.write("\n                        ['");
          if (_jspx_meth_ww_005fproperty_005f0(_jspx_th_ww_005fiterator_005f0, _jspx_page_context))
            return true;
          out.write("', '");
          if (_jspx_meth_ww_005fproperty_005f1(_jspx_th_ww_005fiterator_005f0, _jspx_page_context))
            return true;
          out.write("', '");
          if (_jspx_meth_ww_005fproperty_005f2(_jspx_th_ww_005fiterator_005f0, _jspx_page_context))
            return true;
          out.write('\'');
          out.write(',');
          out.write(' ');
          if (_jspx_meth_ww_005fproperty_005f3(_jspx_th_ww_005fiterator_005f0, _jspx_page_context))
            return true;
          out.write(',');
          out.write(' ');
          if (_jspx_meth_ww_005fproperty_005f4(_jspx_th_ww_005fiterator_005f0, _jspx_page_context))
            return true;
          out.write(',');
          out.write(' ');
          if (_jspx_meth_ww_005fproperty_005f5(_jspx_th_ww_005fiterator_005f0, _jspx_page_context))
            return true;
          out.write(',');
          out.write(' ');
          if (_jspx_meth_ww_005fproperty_005f6(_jspx_th_ww_005fiterator_005f0, _jspx_page_context))
            return true;
          out.write(',');
          out.write(' ');
          if (_jspx_meth_ww_005fproperty_005f7(_jspx_th_ww_005fiterator_005f0, _jspx_page_context))
            return true;
          out.write("],\n                    ");
          int evalDoAfterBody = _jspx_th_ww_005fiterator_005f0.doAfterBody();
          if (evalDoAfterBody != javax.servlet.jsp.tagext.BodyTag.EVAL_BODY_AGAIN)
            break;
        } while (true);
        if (_jspx_eval_ww_005fiterator_005f0 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
          out = _jspx_page_context.popBody();
        }
      }
      if (_jspx_th_ww_005fiterator_005f0.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005fww_005fiterator_0026_005fvalue.reuse(_jspx_th_ww_005fiterator_005f0);
      _jspx_th_ww_005fiterator_005f0_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_ww_005fiterator_005f0, _jsp_getInstanceManager(), _jspx_th_ww_005fiterator_005f0_reused);
    }
    return false;
  }

  private boolean _jspx_meth_ww_005fproperty_005f0(javax.servlet.jsp.tagext.JspTag _jspx_th_ww_005fiterator_005f0, javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  ww:property
    webwork.view.taglib.PropertyTag _jspx_th_ww_005fproperty_005f0 = (webwork.view.taglib.PropertyTag) _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody.get(webwork.view.taglib.PropertyTag.class);
    boolean _jspx_th_ww_005fproperty_005f0_reused = false;
    try {
      _jspx_th_ww_005fproperty_005f0.setPageContext(_jspx_page_context);
      _jspx_th_ww_005fproperty_005f0.setParent((javax.servlet.jsp.tagext.Tag) _jspx_th_ww_005fiterator_005f0);
      // /secure/admin/views/instrumentation/cache/viewcachestats.jsp(21,26) name = value type = null reqTime = true required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ww_005fproperty_005f0.setValue("./name");
      int _jspx_eval_ww_005fproperty_005f0 = _jspx_th_ww_005fproperty_005f0.doStartTag();
      if (_jspx_th_ww_005fproperty_005f0.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody.reuse(_jspx_th_ww_005fproperty_005f0);
      _jspx_th_ww_005fproperty_005f0_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_ww_005fproperty_005f0, _jsp_getInstanceManager(), _jspx_th_ww_005fproperty_005f0_reused);
    }
    return false;
  }

  private boolean _jspx_meth_ww_005fproperty_005f1(javax.servlet.jsp.tagext.JspTag _jspx_th_ww_005fiterator_005f0, javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  ww:property
    webwork.view.taglib.PropertyTag _jspx_th_ww_005fproperty_005f1 = (webwork.view.taglib.PropertyTag) _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody.get(webwork.view.taglib.PropertyTag.class);
    boolean _jspx_th_ww_005fproperty_005f1_reused = false;
    try {
      _jspx_th_ww_005fproperty_005f1.setPageContext(_jspx_page_context);
      _jspx_th_ww_005fproperty_005f1.setParent((javax.servlet.jsp.tagext.Tag) _jspx_th_ww_005fiterator_005f0);
      // /secure/admin/views/instrumentation/cache/viewcachestats.jsp(21,59) name = value type = null reqTime = true required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ww_005fproperty_005f1.setValue("./shortName");
      int _jspx_eval_ww_005fproperty_005f1 = _jspx_th_ww_005fproperty_005f1.doStartTag();
      if (_jspx_th_ww_005fproperty_005f1.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody.reuse(_jspx_th_ww_005fproperty_005f1);
      _jspx_th_ww_005fproperty_005f1_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_ww_005fproperty_005f1, _jsp_getInstanceManager(), _jspx_th_ww_005fproperty_005f1_reused);
    }
    return false;
  }

  private boolean _jspx_meth_ww_005fproperty_005f2(javax.servlet.jsp.tagext.JspTag _jspx_th_ww_005fiterator_005f0, javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  ww:property
    webwork.view.taglib.PropertyTag _jspx_th_ww_005fproperty_005f2 = (webwork.view.taglib.PropertyTag) _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody.get(webwork.view.taglib.PropertyTag.class);
    boolean _jspx_th_ww_005fproperty_005f2_reused = false;
    try {
      _jspx_th_ww_005fproperty_005f2.setPageContext(_jspx_page_context);
      _jspx_th_ww_005fproperty_005f2.setParent((javax.servlet.jsp.tagext.Tag) _jspx_th_ww_005fiterator_005f0);
      // /secure/admin/views/instrumentation/cache/viewcachestats.jsp(21,97) name = value type = null reqTime = true required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ww_005fproperty_005f2.setValue("./cacheType");
      int _jspx_eval_ww_005fproperty_005f2 = _jspx_th_ww_005fproperty_005f2.doStartTag();
      if (_jspx_th_ww_005fproperty_005f2.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody.reuse(_jspx_th_ww_005fproperty_005f2);
      _jspx_th_ww_005fproperty_005f2_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_ww_005fproperty_005f2, _jsp_getInstanceManager(), _jspx_th_ww_005fproperty_005f2_reused);
    }
    return false;
  }

  private boolean _jspx_meth_ww_005fproperty_005f3(javax.servlet.jsp.tagext.JspTag _jspx_th_ww_005fiterator_005f0, javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  ww:property
    webwork.view.taglib.PropertyTag _jspx_th_ww_005fproperty_005f3 = (webwork.view.taglib.PropertyTag) _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody.get(webwork.view.taglib.PropertyTag.class);
    boolean _jspx_th_ww_005fproperty_005f3_reused = false;
    try {
      _jspx_th_ww_005fproperty_005f3.setPageContext(_jspx_page_context);
      _jspx_th_ww_005fproperty_005f3.setParent((javax.servlet.jsp.tagext.Tag) _jspx_th_ww_005fiterator_005f0);
      // /secure/admin/views/instrumentation/cache/viewcachestats.jsp(21,134) name = value type = null reqTime = true required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ww_005fproperty_005f3.setValue("./hitCount");
      int _jspx_eval_ww_005fproperty_005f3 = _jspx_th_ww_005fproperty_005f3.doStartTag();
      if (_jspx_th_ww_005fproperty_005f3.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody.reuse(_jspx_th_ww_005fproperty_005f3);
      _jspx_th_ww_005fproperty_005f3_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_ww_005fproperty_005f3, _jsp_getInstanceManager(), _jspx_th_ww_005fproperty_005f3_reused);
    }
    return false;
  }

  private boolean _jspx_meth_ww_005fproperty_005f4(javax.servlet.jsp.tagext.JspTag _jspx_th_ww_005fiterator_005f0, javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  ww:property
    webwork.view.taglib.PropertyTag _jspx_th_ww_005fproperty_005f4 = (webwork.view.taglib.PropertyTag) _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody.get(webwork.view.taglib.PropertyTag.class);
    boolean _jspx_th_ww_005fproperty_005f4_reused = false;
    try {
      _jspx_th_ww_005fproperty_005f4.setPageContext(_jspx_page_context);
      _jspx_th_ww_005fproperty_005f4.setParent((javax.servlet.jsp.tagext.Tag) _jspx_th_ww_005fiterator_005f0);
      // /secure/admin/views/instrumentation/cache/viewcachestats.jsp(21,169) name = value type = null reqTime = true required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ww_005fproperty_005f4.setValue("./hitCount");
      int _jspx_eval_ww_005fproperty_005f4 = _jspx_th_ww_005fproperty_005f4.doStartTag();
      if (_jspx_th_ww_005fproperty_005f4.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody.reuse(_jspx_th_ww_005fproperty_005f4);
      _jspx_th_ww_005fproperty_005f4_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_ww_005fproperty_005f4, _jsp_getInstanceManager(), _jspx_th_ww_005fproperty_005f4_reused);
    }
    return false;
  }

  private boolean _jspx_meth_ww_005fproperty_005f5(javax.servlet.jsp.tagext.JspTag _jspx_th_ww_005fiterator_005f0, javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  ww:property
    webwork.view.taglib.PropertyTag _jspx_th_ww_005fproperty_005f5 = (webwork.view.taglib.PropertyTag) _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody.get(webwork.view.taglib.PropertyTag.class);
    boolean _jspx_th_ww_005fproperty_005f5_reused = false;
    try {
      _jspx_th_ww_005fproperty_005f5.setPageContext(_jspx_page_context);
      _jspx_th_ww_005fproperty_005f5.setParent((javax.servlet.jsp.tagext.Tag) _jspx_th_ww_005fiterator_005f0);
      // /secure/admin/views/instrumentation/cache/viewcachestats.jsp(21,204) name = value type = null reqTime = true required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ww_005fproperty_005f5.setValue("./missCount");
      int _jspx_eval_ww_005fproperty_005f5 = _jspx_th_ww_005fproperty_005f5.doStartTag();
      if (_jspx_th_ww_005fproperty_005f5.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody.reuse(_jspx_th_ww_005fproperty_005f5);
      _jspx_th_ww_005fproperty_005f5_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_ww_005fproperty_005f5, _jsp_getInstanceManager(), _jspx_th_ww_005fproperty_005f5_reused);
    }
    return false;
  }

  private boolean _jspx_meth_ww_005fproperty_005f6(javax.servlet.jsp.tagext.JspTag _jspx_th_ww_005fiterator_005f0, javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  ww:property
    webwork.view.taglib.PropertyTag _jspx_th_ww_005fproperty_005f6 = (webwork.view.taglib.PropertyTag) _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody.get(webwork.view.taglib.PropertyTag.class);
    boolean _jspx_th_ww_005fproperty_005f6_reused = false;
    try {
      _jspx_th_ww_005fproperty_005f6.setPageContext(_jspx_page_context);
      _jspx_th_ww_005fproperty_005f6.setParent((javax.servlet.jsp.tagext.Tag) _jspx_th_ww_005fiterator_005f0);
      // /secure/admin/views/instrumentation/cache/viewcachestats.jsp(21,240) name = value type = null reqTime = true required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ww_005fproperty_005f6.setValue("./avgLoadTime");
      int _jspx_eval_ww_005fproperty_005f6 = _jspx_th_ww_005fproperty_005f6.doStartTag();
      if (_jspx_th_ww_005fproperty_005f6.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody.reuse(_jspx_th_ww_005fproperty_005f6);
      _jspx_th_ww_005fproperty_005f6_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_ww_005fproperty_005f6, _jsp_getInstanceManager(), _jspx_th_ww_005fproperty_005f6_reused);
    }
    return false;
  }

  private boolean _jspx_meth_ww_005fproperty_005f7(javax.servlet.jsp.tagext.JspTag _jspx_th_ww_005fiterator_005f0, javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  ww:property
    webwork.view.taglib.PropertyTag _jspx_th_ww_005fproperty_005f7 = (webwork.view.taglib.PropertyTag) _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody.get(webwork.view.taglib.PropertyTag.class);
    boolean _jspx_th_ww_005fproperty_005f7_reused = false;
    try {
      _jspx_th_ww_005fproperty_005f7.setPageContext(_jspx_page_context);
      _jspx_th_ww_005fproperty_005f7.setParent((javax.servlet.jsp.tagext.Tag) _jspx_th_ww_005fiterator_005f0);
      // /secure/admin/views/instrumentation/cache/viewcachestats.jsp(21,278) name = value type = null reqTime = true required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ww_005fproperty_005f7.setValue("./size");
      int _jspx_eval_ww_005fproperty_005f7 = _jspx_th_ww_005fproperty_005f7.doStartTag();
      if (_jspx_th_ww_005fproperty_005f7.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody.reuse(_jspx_th_ww_005fproperty_005f7);
      _jspx_th_ww_005fproperty_005f7_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_ww_005fproperty_005f7, _jsp_getInstanceManager(), _jspx_th_ww_005fproperty_005f7_reused);
    }
    return false;
  }
}
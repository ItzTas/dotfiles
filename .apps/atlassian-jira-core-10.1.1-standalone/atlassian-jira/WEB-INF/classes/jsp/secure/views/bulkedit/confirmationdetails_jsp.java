/*
 * Generated by the Jasper component of Apache Tomcat
 * Version: JspC/ApacheTomcat9
 * Generated at: 2024-10-09 09:01:54 UTC
 * Note: The last modified time of this file was set to
 *       the last modified time of the source file after
 *       generation to assist with modification tracking.
 */
package jsp.secure.views.bulkedit;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;

public final class confirmationdetails_jsp extends org.apache.jasper.runtime.HttpJspBase
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

      out.write("\n\n<!-- Issue Targets Table - Target Project and Issue Type -->\n\n<ww:property id=\"issueToSubtaskClass\" value=\"''\" />\n<ww:if test=\"/subtaskToIssue(.) == true\">\n    <ww:property id=\"issueToSubtaskClass\" value=\"' subtask-to-issue'\" />\n</ww:if>\n<ww:property id=\"subtaskToIssueClass\" value=\"''\" />\n<ww:if test=\"/issueToSubtask(.) == true\">\n    <ww:property id=\"subtaskToIssueClass\" value=\"' issue-to-subtask'\" />\n</ww:if>\n<ww:property id=\"subtaskToSubtaskClass\" value=\"''\" />\n<ww:if test=\"/subtaskToSubtask(.) == true\">\n    <ww:property id=\"subtaskToSubtaskClass\" value=\"' subtask-to-subtask'\" />\n</ww:if>\n\n<table id=\"move_confirm_table\" class=\"aui aui-table-rowhover bulk-group<ww:property value=\"@issueToSubtaskClass\" /><ww:property value=\"@subtaskToIssueClass\" /><ww:property value=\"@subtaskToSubtaskClass\" />\">\n    <thead>\n        <tr>\n            <th colspan=\"2\"><ww:text name=\"'bulk.move.issuetargets'\" /></th>\n        </tr>\n    </thead>\n    <tbody>\n        <tr>\n            <td style=\"max-width: 200px; width: 200px; word-wrap: break-word;\"><ww:text name=\"'bulk.move.targetproject'\" /></td>\n");
      out.write("            <td data-target-project=\"<ww:property value=\"./targetProject/name\" />\">\n                <img alt=\"\" src=\"<ww:url value=\"'/secure/projectavatar'\" atltoken=\"false\"><ww:param name=\"'pid'\" value=\"./targetProject/id\" /><ww:param name=\"'size'\" value=\"'small'\" /></ww:url>\" height=\"24\" width=\"24\"/>\n                <ww:property value=\"./targetProject/name\" />\n            </td>\n        </tr>\n    <ww:if test=\"./targetIssueType\">\n        <tr>\n            <td><ww:text name=\"'bulk.move.targetissuetype'\" /></td>\n            <td data-target-issuetype=\"<ww:property value=\"./targetIssueType/name\" />\">\n                <ww:component name=\"'issuetype'\" template=\"constanticon.jsp\">\n                  <ww:param name=\"'contextPath'\">");
      out.print( request.getContextPath() );
      out.write("</ww:param>\n                  <ww:param name=\"'iconurl'\" value=\"./targetIssueType/iconUrl\" />\n                  <ww:param name=\"'alt'\"><ww:property value=\"./targetIssueType/name\" /></ww:param>\n                </ww:component>\n                <ww:property value=\"/nameTranslation(./targetIssueType)\" />\n            </td>\n        </tr>\n    </ww:if>\n\n    <ww:if test=\"./parentIssueKey != null\">\n        <tr>\n            <td><ww:text name=\"'convert.issue.to.subtask.details.targetparentissue'\"/></td>\n            <td data-parent-issue-key=\"<ww:property value=\"./parentIssueKey\" />\">\n                <ww:property value=\"./parentIssueKey\" />\n            </td>\n        </tr>\n    </ww:if>\n\n    </tbody>\n</table>\n\n\n<!-- Workflow/Status Table - Target Workflow and Status Mappings -->\n<ww:property value=\"./statusMapHolder\">\n    <ww:if test=\". != null && ./empty == false\">\n        <table id=\"status_map_table\" class=\"aui aui-table-rowhover\">\n            <thead>\n                <tr>\n                    <th colspan=\"2\"><ww:text name=\"'bulk.move.workflow'\"/></th>\n");
      out.write("                </tr>\n            </thead>\n            <tbody>\n                <tr>\n                    <td style=\"max-width: 200px; width: 200px; word-wrap: break-word;\"><ww:text name=\"'bulk.move.targetworkflow'\" /></td>\n                    <td><ww:property value=\"../targetWorkflow/name\" /></td>\n                </tr>\n                <tr>\n                    <td style=\"max-width: 200px; width: 200px; word-wrap: break-word;\"><ww:text name=\"'bulk.move.status.mapping.confirm'\" /></td>\n                    <td>\n                        <table class=\"bordered\">\n                            <tr>\n                                <th nowrap><ww:text name=\"'bulk.move.status.original'\" /></th>\n                                <th>&nbsp;</th>\n                                <th nowrap><ww:text name=\"'bulk.move.targetstatus'\" /></th>\n                            </tr>\n                            <ww:iterator value=\".\">\n                                <tr>\n                                    <td width=\"1%\" nowrap>\n                                        <ww:component name=\"'status'\" template=\"issuestatus.jsp\" theme=\"'aui'\">\n");
      out.write("                                            <ww:param name=\"'issueStatus'\" value=\"/constantsManager/statusObject(./key)\"/>\n                                            <ww:param name=\"'isSubtle'\" value=\"false\"/>\n                                            <ww:param name=\"'isCompact'\" value=\"false\"/>\n                                        </ww:component>\n                                    </td>\n                                    <td width=\"1%\">\n                                        <img src=\"");
      out.print( request.getContextPath() );
      out.write("/images/icons/arrow-move.svg\" alt=\"?\">\n                                    </td>\n                                    <td nowrap>\n                                        <ww:component name=\"'status'\" template=\"issuestatus.jsp\" theme=\"'aui'\">\n                                            <ww:param name=\"'issueStatus'\" value=\"/constantsManager/statusObject(./value)\"/>\n                                            <ww:param name=\"'isSubtle'\" value=\"false\"/>\n                                            <ww:param name=\"'isCompact'\" value=\"false\"/>\n                                        </ww:component>\n                                    </td>\n                                </tr>\n                            </ww:iterator>\n                        </table>\n                    </td>\n                </tr>\n            </tbody>\n        </table>\n    </ww:if>\n</ww:property>\n\n\n<!-- Updated Fields Table -->\n<ww:property value=\"./moveFieldLayoutItems\">\n    <ww:if test=\". != null && . /empty == false\">\n        <table id=\"field_map_table\" class=\"aui aui-table-rowhover movedFields\">\n");
      out.write("            <thead>\n                <tr>\n                    <th><ww:text name=\"'bulk.move.updatedfields'\" /></th>\n                    <th><ww:text name=\"'bulk.move.newvalue'\"/></th>\n                </tr>\n            </thead>\n            <tbody>\n            <ww:iterator value=\".\">\n                <tr>\n                    <td style=\"max-width: 200px; width: 200px; word-wrap: break-word;\"><ww:property value=\"/fieldName(./orderableField)\" /></td>\n                    <td>\n                        <ww:if test=\"/fieldUsingSubstitutions(../.., ./orderableField) == true\" >\n                            <table id=\"<ww:property value=\"../../key\" /><ww:property value=\"./orderableField/id\" />\">\n                                <ww:iterator value=\"/substitutionsForField(../.., ./orderableField)/entrySet\">\n                                    <tr>\n                                        <td width=\"1%\" nowrap><ww:property value=\"/mappingViewHtml(../../.., ../orderableField, ./key, 'true')\" escape=\"'false'\" /></td>\n                                        <td width=\"1%\">\n");
      out.write("                                            <img src=\"");
      out.print( request.getContextPath() );
      out.write("/images/icons/arrow-move.svg\" alt=\"?\">\n                                        </td>\n                                        <td nowrap><ww:property value=\"/mappingViewHtml(../../.., ../orderableField, ./value, 'false')\" escape=\"'false'\" /></td>\n                                    </tr>\n                                </ww:iterator>\n                            </table>\n                        </ww:if>\n                        <ww:else>\n                            <ww:property value=\"/newViewHtml(../.., ./orderableField)\" escape=\"'false'\" />\n                        </ww:else>\n                    </td>\n                </tr>\n            </ww:iterator>\n            </tbody>\n        </table>\n    </ww:if>\n</ww:property>\n\n<!-- Removed Fields Table -->\n<ww:property value=\"./removedFields\">\n    <ww:if test=\". != null && . /empty == false\">\n        <table id=\"removed_fields_table\" class=\"aui aui-table-rowhover\">\n            <thead>\n                <tr>\n                    <th><ww:text name=\"'bulk.move.removedfields'\" /></th>\n");
      out.write("                </tr>\n            </thead>\n            <tbody>\n            <ww:iterator value=\".\">\n                <tr>\n                    <td><ww:property value=\"/fieldName(.)\" /></td>\n                </tr>\n            </ww:iterator>\n            </tbody>\n        </table>\n    </ww:if>\n</ww:property>\n");
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
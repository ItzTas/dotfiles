/*
 * Generated by the Jasper component of Apache Tomcat
 * Version: JspC/ApacheTomcat9
 * Generated at: 2024-10-09 09:01:56 UTC
 * Note: The last modified time of this file was set to
 *       the last modified time of the source file after
 *       generation to assist with modification tracking.
 */
package jsp.decorators;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;
import com.atlassian.jira.component.ComponentAccessor;
import com.atlassian.jira.config.properties.APKeys;
import com.atlassian.jira.config.properties.ApplicationProperties;
import com.atlassian.jira.web.util.ProductVersionDataBeanProvider;
import com.atlassian.webresource.api.assembler.PageBuilderService;
import com.opensymphony.util.TextUtils;

public final class setup_jsp extends org.apache.jasper.runtime.HttpJspBase
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
    _jspx_imports_classes.add("com.atlassian.jira.web.util.ProductVersionDataBeanProvider");
    _jspx_imports_classes.add("com.opensymphony.util.TextUtils");
    _jspx_imports_classes.add("com.atlassian.jira.config.properties.ApplicationProperties");
    _jspx_imports_classes.add("com.atlassian.webresource.api.assembler.PageBuilderService");
    _jspx_imports_classes.add("com.atlassian.jira.component.ComponentAccessor");
    _jspx_imports_classes.add("com.atlassian.jira.config.properties.APKeys");
  }

  private org.apache.jasper.runtime.TagHandlerPool _005fjspx_005ftagPool_005fdecorator_005ftitle_005fnobody;
  private org.apache.jasper.runtime.TagHandlerPool _005fjspx_005ftagPool_005fdecorator_005fhead_005fnobody;
  private org.apache.jasper.runtime.TagHandlerPool _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody;
  private org.apache.jasper.runtime.TagHandlerPool _005fjspx_005ftagPool_005fdecorator_005fgetProperty_0026_005fproperty_005fnobody;
  private org.apache.jasper.runtime.TagHandlerPool _005fjspx_005ftagPool_005fui_005fsoy_0026_005ftemplate_005fmoduleKey;
  private org.apache.jasper.runtime.TagHandlerPool _005fjspx_005ftagPool_005fui_005fparam_0026_005fname;
  private org.apache.jasper.runtime.TagHandlerPool _005fjspx_005ftagPool_005fdecorator_005fbody_005fnobody;

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
    _005fjspx_005ftagPool_005fdecorator_005ftitle_005fnobody = org.apache.jasper.runtime.TagHandlerPool.getTagHandlerPool(getServletConfig());
    _005fjspx_005ftagPool_005fdecorator_005fhead_005fnobody = org.apache.jasper.runtime.TagHandlerPool.getTagHandlerPool(getServletConfig());
    _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody = org.apache.jasper.runtime.TagHandlerPool.getTagHandlerPool(getServletConfig());
    _005fjspx_005ftagPool_005fdecorator_005fgetProperty_0026_005fproperty_005fnobody = org.apache.jasper.runtime.TagHandlerPool.getTagHandlerPool(getServletConfig());
    _005fjspx_005ftagPool_005fui_005fsoy_0026_005ftemplate_005fmoduleKey = org.apache.jasper.runtime.TagHandlerPool.getTagHandlerPool(getServletConfig());
    _005fjspx_005ftagPool_005fui_005fparam_0026_005fname = org.apache.jasper.runtime.TagHandlerPool.getTagHandlerPool(getServletConfig());
    _005fjspx_005ftagPool_005fdecorator_005fbody_005fnobody = org.apache.jasper.runtime.TagHandlerPool.getTagHandlerPool(getServletConfig());
  }

  public void _jspDestroy() {
    _005fjspx_005ftagPool_005fdecorator_005ftitle_005fnobody.release();
    _005fjspx_005ftagPool_005fdecorator_005fhead_005fnobody.release();
    _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody.release();
    _005fjspx_005ftagPool_005fdecorator_005fgetProperty_0026_005fproperty_005fnobody.release();
    _005fjspx_005ftagPool_005fui_005fsoy_0026_005ftemplate_005fmoduleKey.release();
    _005fjspx_005ftagPool_005fui_005fparam_0026_005fname.release();
    _005fjspx_005ftagPool_005fdecorator_005fbody_005fnobody.release();
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

      out.write("\n\n\n\n\n\n\n\n\n\n");

    final ApplicationProperties applicationProperties = ComponentAccessor.getComponentOfType(ApplicationProperties.class);
    final String jiraTitle = applicationProperties.getDefaultBackedString(APKeys.JIRA_TITLE);
    final String jiraLogoUrl = applicationProperties.getDefaultBackedString(APKeys.JIRA_LF_LOGO_URL);

      out.write("\n<!DOCTYPE html>\n<html lang=\"");
      out.print( ComponentAccessor.getJiraAuthenticationContext().getI18nHelper().getLocale().getLanguage() );
      out.write("\">\n<head>\n    <title>");
      out.print( TextUtils.htmlEncode(jiraTitle) );
      out.write(' ');
      out.write('-');
      out.write(' ');
      if (_jspx_meth_decorator_005ftitle_005f0(_jspx_page_context))
        return;
      out.write("</title>\n    <meta http-equiv=\"Content-Type\" content=\"");
      out.print( applicationProperties.getContentType() );
      out.write("\" />\n    <link rel=\"shortcut icon\" href=\"");
      out.print(request.getContextPath());
      out.write("/favicon.ico\" />\n    ");
      if (_jspx_meth_decorator_005fhead_005f0(_jspx_page_context))
        return;
      out.write('\n');

    final PageBuilderService pbs = ComponentAccessor.getComponent(PageBuilderService.class);
    pbs.assembler().resources().requireWebResource("jira.webresources:jira-setup");
    pbs.assembler().assembled().drainIncludedResources().writeHtmlTags(out, com.atlassian.webresource.api.UrlMode.RELATIVE);

      out.write("\n    <meta name=\"ajs-setup-session-id\" content=\"");
      if (_jspx_meth_ww_005fproperty_005f0(_jspx_page_context))
        return;
      out.write("\"/>\n    <meta name=\"ajs-server-id\" content=\"");
      if (_jspx_meth_ww_005fproperty_005f1(_jspx_page_context))
        return;
      out.write("\"/>\n    <meta name=\"ajs-instant-setup\" content=\"");
      if (_jspx_meth_ww_005fproperty_005f2(_jspx_page_context))
        return;
      out.write("\"/>\n    <meta name=\"ajs-setup-analytics-iframe-url\" content=\"");
      if (_jspx_meth_ww_005fproperty_005f3(_jspx_page_context))
        return;
      out.write("\"/>\n    <meta name=\"ajs-license-product-key\" content=\"");
      if (_jspx_meth_ww_005fproperty_005f4(_jspx_page_context))
        return;
      out.write("\"/>\n</head>\n<body id=\"jira\" class=\"aui-layout aui-theme-default aui-page-focused aui-page-focused-large ");
      if (_jspx_meth_decorator_005fgetProperty_005f0(_jspx_page_context))
        return;
      out.write('"');
      out.write(' ');
      out.print( ComponentAccessor.getComponent(ProductVersionDataBeanProvider.class).get().getBodyHtmlAttributes() );
      out.write(">\n<div id=\"page\">\n    <header id=\"header\" role=\"banner\">\n        <nav class=\"aui-header\" role=\"navigation\">\n            <div class=\"aui-header-inner\">\n                <div class=\"aui-header-primary\">\n                    <h1 id=\"logo\" class=\"aui-header-logo\">\n                        <img src=\"");
      out.print(request.getContextPath() + TextUtils.htmlEncode(jiraLogoUrl));
      out.write("\" alt=\"");
      out.print(TextUtils.htmlEncode(jiraTitle));
      out.write("\"/>\n                    </h1>\n                </div>\n            </div>\n        </nav>\n    </header>\n    <div id=\"content\">\n        ");
      if (_jspx_meth_ui_005fsoy_005f0(_jspx_page_context))
        return;
      out.write("\n    </div>\n    <footer id=\"footer\" role=\"contentinfo\"></footer>\n</div>\n</body>\n</html>\n");
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

  private boolean _jspx_meth_decorator_005ftitle_005f0(javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  decorator:title
    com.opensymphony.module.sitemesh.taglib.decorator.TitleTag _jspx_th_decorator_005ftitle_005f0 = (com.opensymphony.module.sitemesh.taglib.decorator.TitleTag) _005fjspx_005ftagPool_005fdecorator_005ftitle_005fnobody.get(com.opensymphony.module.sitemesh.taglib.decorator.TitleTag.class);
    boolean _jspx_th_decorator_005ftitle_005f0_reused = false;
    try {
      _jspx_th_decorator_005ftitle_005f0.setPageContext(_jspx_page_context);
      _jspx_th_decorator_005ftitle_005f0.setParent(null);
      int _jspx_eval_decorator_005ftitle_005f0 = _jspx_th_decorator_005ftitle_005f0.doStartTag();
      if (_jspx_th_decorator_005ftitle_005f0.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005fdecorator_005ftitle_005fnobody.reuse(_jspx_th_decorator_005ftitle_005f0);
      _jspx_th_decorator_005ftitle_005f0_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_decorator_005ftitle_005f0, _jsp_getInstanceManager(), _jspx_th_decorator_005ftitle_005f0_reused);
    }
    return false;
  }

  private boolean _jspx_meth_decorator_005fhead_005f0(javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  decorator:head
    com.opensymphony.module.sitemesh.taglib.decorator.HeadTag _jspx_th_decorator_005fhead_005f0 = (com.opensymphony.module.sitemesh.taglib.decorator.HeadTag) _005fjspx_005ftagPool_005fdecorator_005fhead_005fnobody.get(com.opensymphony.module.sitemesh.taglib.decorator.HeadTag.class);
    boolean _jspx_th_decorator_005fhead_005f0_reused = false;
    try {
      _jspx_th_decorator_005fhead_005f0.setPageContext(_jspx_page_context);
      _jspx_th_decorator_005fhead_005f0.setParent(null);
      int _jspx_eval_decorator_005fhead_005f0 = _jspx_th_decorator_005fhead_005f0.doStartTag();
      if (_jspx_th_decorator_005fhead_005f0.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005fdecorator_005fhead_005fnobody.reuse(_jspx_th_decorator_005fhead_005f0);
      _jspx_th_decorator_005fhead_005f0_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_decorator_005fhead_005f0, _jsp_getInstanceManager(), _jspx_th_decorator_005fhead_005f0_reused);
    }
    return false;
  }

  private boolean _jspx_meth_ww_005fproperty_005f0(javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  ww:property
    webwork.view.taglib.PropertyTag _jspx_th_ww_005fproperty_005f0 = (webwork.view.taglib.PropertyTag) _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody.get(webwork.view.taglib.PropertyTag.class);
    boolean _jspx_th_ww_005fproperty_005f0_reused = false;
    try {
      _jspx_th_ww_005fproperty_005f0.setPageContext(_jspx_page_context);
      _jspx_th_ww_005fproperty_005f0.setParent(null);
      // /decorators/setup.jsp(28,47) name = value type = null reqTime = true required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ww_005fproperty_005f0.setValue("/setupSessionId");
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

  private boolean _jspx_meth_ww_005fproperty_005f1(javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  ww:property
    webwork.view.taglib.PropertyTag _jspx_th_ww_005fproperty_005f1 = (webwork.view.taglib.PropertyTag) _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody.get(webwork.view.taglib.PropertyTag.class);
    boolean _jspx_th_ww_005fproperty_005f1_reused = false;
    try {
      _jspx_th_ww_005fproperty_005f1.setPageContext(_jspx_page_context);
      _jspx_th_ww_005fproperty_005f1.setParent(null);
      // /decorators/setup.jsp(29,40) name = value type = null reqTime = true required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ww_005fproperty_005f1.setValue("/serverId");
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

  private boolean _jspx_meth_ww_005fproperty_005f2(javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  ww:property
    webwork.view.taglib.PropertyTag _jspx_th_ww_005fproperty_005f2 = (webwork.view.taglib.PropertyTag) _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody.get(webwork.view.taglib.PropertyTag.class);
    boolean _jspx_th_ww_005fproperty_005f2_reused = false;
    try {
      _jspx_th_ww_005fproperty_005f2.setPageContext(_jspx_page_context);
      _jspx_th_ww_005fproperty_005f2.setParent(null);
      // /decorators/setup.jsp(30,44) name = value type = null reqTime = true required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ww_005fproperty_005f2.setValue("/instantSetup");
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

  private boolean _jspx_meth_ww_005fproperty_005f3(javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  ww:property
    webwork.view.taglib.PropertyTag _jspx_th_ww_005fproperty_005f3 = (webwork.view.taglib.PropertyTag) _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody.get(webwork.view.taglib.PropertyTag.class);
    boolean _jspx_th_ww_005fproperty_005f3_reused = false;
    try {
      _jspx_th_ww_005fproperty_005f3.setPageContext(_jspx_page_context);
      _jspx_th_ww_005fproperty_005f3.setParent(null);
      // /decorators/setup.jsp(31,57) name = value type = null reqTime = true required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ww_005fproperty_005f3.setValue("/analyticsIframeUrl");
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

  private boolean _jspx_meth_ww_005fproperty_005f4(javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  ww:property
    webwork.view.taglib.PropertyTag _jspx_th_ww_005fproperty_005f4 = (webwork.view.taglib.PropertyTag) _005fjspx_005ftagPool_005fww_005fproperty_0026_005fvalue_005fnobody.get(webwork.view.taglib.PropertyTag.class);
    boolean _jspx_th_ww_005fproperty_005f4_reused = false;
    try {
      _jspx_th_ww_005fproperty_005f4.setPageContext(_jspx_page_context);
      _jspx_th_ww_005fproperty_005f4.setParent(null);
      // /decorators/setup.jsp(32,50) name = value type = null reqTime = true required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ww_005fproperty_005f4.setValue("/licenseProductKey");
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

  private boolean _jspx_meth_decorator_005fgetProperty_005f0(javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  decorator:getProperty
    com.opensymphony.module.sitemesh.taglib.decorator.PropertyTag _jspx_th_decorator_005fgetProperty_005f0 = (com.opensymphony.module.sitemesh.taglib.decorator.PropertyTag) _005fjspx_005ftagPool_005fdecorator_005fgetProperty_0026_005fproperty_005fnobody.get(com.opensymphony.module.sitemesh.taglib.decorator.PropertyTag.class);
    boolean _jspx_th_decorator_005fgetProperty_005f0_reused = false;
    try {
      _jspx_th_decorator_005fgetProperty_005f0.setPageContext(_jspx_page_context);
      _jspx_th_decorator_005fgetProperty_005f0.setParent(null);
      // /decorators/setup.jsp(34,92) name = property type = null reqTime = true required = true fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_decorator_005fgetProperty_005f0.setProperty("body.class");
      int _jspx_eval_decorator_005fgetProperty_005f0 = _jspx_th_decorator_005fgetProperty_005f0.doStartTag();
      if (_jspx_th_decorator_005fgetProperty_005f0.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005fdecorator_005fgetProperty_0026_005fproperty_005fnobody.reuse(_jspx_th_decorator_005fgetProperty_005f0);
      _jspx_th_decorator_005fgetProperty_005f0_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_decorator_005fgetProperty_005f0, _jsp_getInstanceManager(), _jspx_th_decorator_005fgetProperty_005f0_reused);
    }
    return false;
  }

  private boolean _jspx_meth_ui_005fsoy_005f0(javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  ui:soy
    com.atlassian.jira.web.tags.SoyTemplateTag _jspx_th_ui_005fsoy_005f0 = (com.atlassian.jira.web.tags.SoyTemplateTag) _005fjspx_005ftagPool_005fui_005fsoy_0026_005ftemplate_005fmoduleKey.get(com.atlassian.jira.web.tags.SoyTemplateTag.class);
    boolean _jspx_th_ui_005fsoy_005f0_reused = false;
    try {
      _jspx_th_ui_005fsoy_005f0.setPageContext(_jspx_page_context);
      _jspx_th_ui_005fsoy_005f0.setParent(null);
      // /decorators/setup.jsp(48,8) name = moduleKey type = java.lang.String reqTime = false required = true fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ui_005fsoy_005f0.setModuleKey("'com.atlassian.auiplugin:soy'");
      // /decorators/setup.jsp(48,8) name = template type = java.lang.String reqTime = false required = true fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ui_005fsoy_005f0.setTemplate("'aui.page.pagePanel'");
      int _jspx_eval_ui_005fsoy_005f0 = _jspx_th_ui_005fsoy_005f0.doStartTag();
      if (_jspx_eval_ui_005fsoy_005f0 != javax.servlet.jsp.tagext.Tag.SKIP_BODY) {
        if (_jspx_eval_ui_005fsoy_005f0 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
          out = org.apache.jasper.runtime.JspRuntimeLibrary.startBufferedBody(_jspx_page_context, _jspx_th_ui_005fsoy_005f0);
        }
        do {
          out.write("\n            ");
          if (_jspx_meth_ui_005fparam_005f0(_jspx_th_ui_005fsoy_005f0, _jspx_page_context))
            return true;
          out.write("\n            ");
          if (_jspx_meth_ui_005fparam_005f1(_jspx_th_ui_005fsoy_005f0, _jspx_page_context))
            return true;
          out.write("\n        ");
          int evalDoAfterBody = _jspx_th_ui_005fsoy_005f0.doAfterBody();
          if (evalDoAfterBody != javax.servlet.jsp.tagext.BodyTag.EVAL_BODY_AGAIN)
            break;
        } while (true);
        if (_jspx_eval_ui_005fsoy_005f0 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
          out = _jspx_page_context.popBody();
        }
      }
      if (_jspx_th_ui_005fsoy_005f0.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005fui_005fsoy_0026_005ftemplate_005fmoduleKey.reuse(_jspx_th_ui_005fsoy_005f0);
      _jspx_th_ui_005fsoy_005f0_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_ui_005fsoy_005f0, _jsp_getInstanceManager(), _jspx_th_ui_005fsoy_005f0_reused);
    }
    return false;
  }

  private boolean _jspx_meth_ui_005fparam_005f0(javax.servlet.jsp.tagext.JspTag _jspx_th_ui_005fsoy_005f0, javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  ui:param
    webwork.view.taglib.ParamTag _jspx_th_ui_005fparam_005f0 = (webwork.view.taglib.ParamTag) _005fjspx_005ftagPool_005fui_005fparam_0026_005fname.get(webwork.view.taglib.ParamTag.class);
    boolean _jspx_th_ui_005fparam_005f0_reused = false;
    try {
      _jspx_th_ui_005fparam_005f0.setPageContext(_jspx_page_context);
      _jspx_th_ui_005fparam_005f0.setParent((javax.servlet.jsp.tagext.Tag) _jspx_th_ui_005fsoy_005f0);
      // /decorators/setup.jsp(49,12) name = name type = java.lang.String reqTime = false required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ui_005fparam_005f0.setName("'extraClasses'");
      int _jspx_eval_ui_005fparam_005f0 = _jspx_th_ui_005fparam_005f0.doStartTag();
      if (_jspx_eval_ui_005fparam_005f0 != javax.servlet.jsp.tagext.Tag.SKIP_BODY) {
        if (_jspx_eval_ui_005fparam_005f0 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
          out = org.apache.jasper.runtime.JspRuntimeLibrary.startBufferedBody(_jspx_page_context, _jspx_th_ui_005fparam_005f0);
        }
        do {
          out.write("margin-fix");
          int evalDoAfterBody = _jspx_th_ui_005fparam_005f0.doAfterBody();
          if (evalDoAfterBody != javax.servlet.jsp.tagext.BodyTag.EVAL_BODY_AGAIN)
            break;
        } while (true);
        if (_jspx_eval_ui_005fparam_005f0 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
          out = _jspx_page_context.popBody();
        }
      }
      if (_jspx_th_ui_005fparam_005f0.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005fui_005fparam_0026_005fname.reuse(_jspx_th_ui_005fparam_005f0);
      _jspx_th_ui_005fparam_005f0_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_ui_005fparam_005f0, _jsp_getInstanceManager(), _jspx_th_ui_005fparam_005f0_reused);
    }
    return false;
  }

  private boolean _jspx_meth_ui_005fparam_005f1(javax.servlet.jsp.tagext.JspTag _jspx_th_ui_005fsoy_005f0, javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  ui:param
    webwork.view.taglib.ParamTag _jspx_th_ui_005fparam_005f1 = (webwork.view.taglib.ParamTag) _005fjspx_005ftagPool_005fui_005fparam_0026_005fname.get(webwork.view.taglib.ParamTag.class);
    boolean _jspx_th_ui_005fparam_005f1_reused = false;
    try {
      _jspx_th_ui_005fparam_005f1.setPageContext(_jspx_page_context);
      _jspx_th_ui_005fparam_005f1.setParent((javax.servlet.jsp.tagext.Tag) _jspx_th_ui_005fsoy_005f0);
      // /decorators/setup.jsp(50,12) name = name type = java.lang.String reqTime = false required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ui_005fparam_005f1.setName("'content'");
      int _jspx_eval_ui_005fparam_005f1 = _jspx_th_ui_005fparam_005f1.doStartTag();
      if (_jspx_eval_ui_005fparam_005f1 != javax.servlet.jsp.tagext.Tag.SKIP_BODY) {
        if (_jspx_eval_ui_005fparam_005f1 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
          out = org.apache.jasper.runtime.JspRuntimeLibrary.startBufferedBody(_jspx_page_context, _jspx_th_ui_005fparam_005f1);
        }
        do {
          out.write("\n                ");
          if (_jspx_meth_ui_005fsoy_005f1(_jspx_th_ui_005fparam_005f1, _jspx_page_context))
            return true;
          out.write("\n            ");
          int evalDoAfterBody = _jspx_th_ui_005fparam_005f1.doAfterBody();
          if (evalDoAfterBody != javax.servlet.jsp.tagext.BodyTag.EVAL_BODY_AGAIN)
            break;
        } while (true);
        if (_jspx_eval_ui_005fparam_005f1 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
          out = _jspx_page_context.popBody();
        }
      }
      if (_jspx_th_ui_005fparam_005f1.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005fui_005fparam_0026_005fname.reuse(_jspx_th_ui_005fparam_005f1);
      _jspx_th_ui_005fparam_005f1_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_ui_005fparam_005f1, _jsp_getInstanceManager(), _jspx_th_ui_005fparam_005f1_reused);
    }
    return false;
  }

  private boolean _jspx_meth_ui_005fsoy_005f1(javax.servlet.jsp.tagext.JspTag _jspx_th_ui_005fparam_005f1, javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  ui:soy
    com.atlassian.jira.web.tags.SoyTemplateTag _jspx_th_ui_005fsoy_005f1 = (com.atlassian.jira.web.tags.SoyTemplateTag) _005fjspx_005ftagPool_005fui_005fsoy_0026_005ftemplate_005fmoduleKey.get(com.atlassian.jira.web.tags.SoyTemplateTag.class);
    boolean _jspx_th_ui_005fsoy_005f1_reused = false;
    try {
      _jspx_th_ui_005fsoy_005f1.setPageContext(_jspx_page_context);
      _jspx_th_ui_005fsoy_005f1.setParent((javax.servlet.jsp.tagext.Tag) _jspx_th_ui_005fparam_005f1);
      // /decorators/setup.jsp(51,16) name = moduleKey type = java.lang.String reqTime = false required = true fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ui_005fsoy_005f1.setModuleKey("'com.atlassian.auiplugin:soy'");
      // /decorators/setup.jsp(51,16) name = template type = java.lang.String reqTime = false required = true fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ui_005fsoy_005f1.setTemplate("'aui.page.pagePanelContent'");
      int _jspx_eval_ui_005fsoy_005f1 = _jspx_th_ui_005fsoy_005f1.doStartTag();
      if (_jspx_eval_ui_005fsoy_005f1 != javax.servlet.jsp.tagext.Tag.SKIP_BODY) {
        if (_jspx_eval_ui_005fsoy_005f1 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
          out = org.apache.jasper.runtime.JspRuntimeLibrary.startBufferedBody(_jspx_page_context, _jspx_th_ui_005fsoy_005f1);
        }
        do {
          out.write("\n                    ");
          if (_jspx_meth_ui_005fparam_005f2(_jspx_th_ui_005fsoy_005f1, _jspx_page_context))
            return true;
          out.write("\n                ");
          int evalDoAfterBody = _jspx_th_ui_005fsoy_005f1.doAfterBody();
          if (evalDoAfterBody != javax.servlet.jsp.tagext.BodyTag.EVAL_BODY_AGAIN)
            break;
        } while (true);
        if (_jspx_eval_ui_005fsoy_005f1 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
          out = _jspx_page_context.popBody();
        }
      }
      if (_jspx_th_ui_005fsoy_005f1.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005fui_005fsoy_0026_005ftemplate_005fmoduleKey.reuse(_jspx_th_ui_005fsoy_005f1);
      _jspx_th_ui_005fsoy_005f1_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_ui_005fsoy_005f1, _jsp_getInstanceManager(), _jspx_th_ui_005fsoy_005f1_reused);
    }
    return false;
  }

  private boolean _jspx_meth_ui_005fparam_005f2(javax.servlet.jsp.tagext.JspTag _jspx_th_ui_005fsoy_005f1, javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  ui:param
    webwork.view.taglib.ParamTag _jspx_th_ui_005fparam_005f2 = (webwork.view.taglib.ParamTag) _005fjspx_005ftagPool_005fui_005fparam_0026_005fname.get(webwork.view.taglib.ParamTag.class);
    boolean _jspx_th_ui_005fparam_005f2_reused = false;
    try {
      _jspx_th_ui_005fparam_005f2.setPageContext(_jspx_page_context);
      _jspx_th_ui_005fparam_005f2.setParent((javax.servlet.jsp.tagext.Tag) _jspx_th_ui_005fsoy_005f1);
      // /decorators/setup.jsp(52,20) name = name type = java.lang.String reqTime = false required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ui_005fparam_005f2.setName("'content'");
      int _jspx_eval_ui_005fparam_005f2 = _jspx_th_ui_005fparam_005f2.doStartTag();
      if (_jspx_eval_ui_005fparam_005f2 != javax.servlet.jsp.tagext.Tag.SKIP_BODY) {
        if (_jspx_eval_ui_005fparam_005f2 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
          out = org.apache.jasper.runtime.JspRuntimeLibrary.startBufferedBody(_jspx_page_context, _jspx_th_ui_005fparam_005f2);
        }
        do {
          out.write("\n                        ");
          if (_jspx_meth_decorator_005fbody_005f0(_jspx_th_ui_005fparam_005f2, _jspx_page_context))
            return true;
          out.write("\n                    ");
          int evalDoAfterBody = _jspx_th_ui_005fparam_005f2.doAfterBody();
          if (evalDoAfterBody != javax.servlet.jsp.tagext.BodyTag.EVAL_BODY_AGAIN)
            break;
        } while (true);
        if (_jspx_eval_ui_005fparam_005f2 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
          out = _jspx_page_context.popBody();
        }
      }
      if (_jspx_th_ui_005fparam_005f2.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005fui_005fparam_0026_005fname.reuse(_jspx_th_ui_005fparam_005f2);
      _jspx_th_ui_005fparam_005f2_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_ui_005fparam_005f2, _jsp_getInstanceManager(), _jspx_th_ui_005fparam_005f2_reused);
    }
    return false;
  }

  private boolean _jspx_meth_decorator_005fbody_005f0(javax.servlet.jsp.tagext.JspTag _jspx_th_ui_005fparam_005f2, javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  decorator:body
    com.opensymphony.module.sitemesh.taglib.decorator.BodyTag _jspx_th_decorator_005fbody_005f0 = (com.opensymphony.module.sitemesh.taglib.decorator.BodyTag) _005fjspx_005ftagPool_005fdecorator_005fbody_005fnobody.get(com.opensymphony.module.sitemesh.taglib.decorator.BodyTag.class);
    boolean _jspx_th_decorator_005fbody_005f0_reused = false;
    try {
      _jspx_th_decorator_005fbody_005f0.setPageContext(_jspx_page_context);
      _jspx_th_decorator_005fbody_005f0.setParent((javax.servlet.jsp.tagext.Tag) _jspx_th_ui_005fparam_005f2);
      int _jspx_eval_decorator_005fbody_005f0 = _jspx_th_decorator_005fbody_005f0.doStartTag();
      if (_jspx_th_decorator_005fbody_005f0.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005fdecorator_005fbody_005fnobody.reuse(_jspx_th_decorator_005fbody_005f0);
      _jspx_th_decorator_005fbody_005f0_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_decorator_005fbody_005f0, _jsp_getInstanceManager(), _jspx_th_decorator_005fbody_005f0_reused);
    }
    return false;
  }
}
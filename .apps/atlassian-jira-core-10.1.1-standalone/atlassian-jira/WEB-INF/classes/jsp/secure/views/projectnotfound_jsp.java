/*
 * Generated by the Jasper component of Apache Tomcat
 * Version: JspC/ApacheTomcat9
 * Generated at: 2024-10-09 09:01:56 UTC
 * Note: The last modified time of this file was set to
 *       the last modified time of the source file after
 *       generation to assist with modification tracking.
 */
package jsp.secure.views;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;

public final class projectnotfound_jsp extends org.apache.jasper.runtime.HttpJspBase
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
  private org.apache.jasper.runtime.TagHandlerPool _005fjspx_005ftagPool_005faui_005fcomponent_0026_005ftheme_005ftemplate;
  private org.apache.jasper.runtime.TagHandlerPool _005fjspx_005ftagPool_005faui_005fparam_0026_005fname;
  private org.apache.jasper.runtime.TagHandlerPool _005fjspx_005ftagPool_005fww_005ftext_0026_005fname;
  private org.apache.jasper.runtime.TagHandlerPool _005fjspx_005ftagPool_005fww_005fparam_0026_005fname;

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
    _005fjspx_005ftagPool_005faui_005fcomponent_0026_005ftheme_005ftemplate = org.apache.jasper.runtime.TagHandlerPool.getTagHandlerPool(getServletConfig());
    _005fjspx_005ftagPool_005faui_005fparam_0026_005fname = org.apache.jasper.runtime.TagHandlerPool.getTagHandlerPool(getServletConfig());
    _005fjspx_005ftagPool_005fww_005ftext_0026_005fname = org.apache.jasper.runtime.TagHandlerPool.getTagHandlerPool(getServletConfig());
    _005fjspx_005ftagPool_005fww_005fparam_0026_005fname = org.apache.jasper.runtime.TagHandlerPool.getTagHandlerPool(getServletConfig());
  }

  public void _jspDestroy() {
    _005fjspx_005ftagPool_005fww_005ftext_0026_005fname_005fnobody.release();
    _005fjspx_005ftagPool_005faui_005fcomponent_0026_005ftheme_005ftemplate.release();
    _005fjspx_005ftagPool_005faui_005fparam_0026_005fname.release();
    _005fjspx_005ftagPool_005fww_005ftext_0026_005fname.release();
    _005fjspx_005ftagPool_005fww_005fparam_0026_005fname.release();
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

      out.write("\n\n<html>\n<head>\n\t<title>");
      if (_jspx_meth_ww_005ftext_005f0(_jspx_page_context))
        return;
      out.write("</title>\n    <meta name=\"decorator\" content=\"message\" />\n</head>\n<body>\n    <div class=\"form-body\">\n        <header>\n            <h1>");
      if (_jspx_meth_ww_005ftext_005f1(_jspx_page_context))
        return;
      out.write("</h1>\n        </header>\n        ");
      //  aui:component
      webwork.view.taglib.ui.ComponentTag _jspx_th_aui_005fcomponent_005f0 = (webwork.view.taglib.ui.ComponentTag) _005fjspx_005ftagPool_005faui_005fcomponent_0026_005ftheme_005ftemplate.get(webwork.view.taglib.ui.ComponentTag.class);
      boolean _jspx_th_aui_005fcomponent_005f0_reused = false;
      try {
        _jspx_th_aui_005fcomponent_005f0.setPageContext(_jspx_page_context);
        _jspx_th_aui_005fcomponent_005f0.setParent(null);
        // /secure/views/projectnotfound.jsp(13,8) name = template type = java.lang.String reqTime = false required = true fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
        _jspx_th_aui_005fcomponent_005f0.setTemplate("auimessage.jsp");
        // /secure/views/projectnotfound.jsp(13,8) name = theme type = java.lang.String reqTime = false required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
        _jspx_th_aui_005fcomponent_005f0.setTheme("'aui'");
        int _jspx_eval_aui_005fcomponent_005f0 = _jspx_th_aui_005fcomponent_005f0.doStartTag();
        if (_jspx_eval_aui_005fcomponent_005f0 != javax.servlet.jsp.tagext.Tag.SKIP_BODY) {
          if (_jspx_eval_aui_005fcomponent_005f0 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
            out = org.apache.jasper.runtime.JspRuntimeLibrary.startBufferedBody(_jspx_page_context, _jspx_th_aui_005fcomponent_005f0);
          }
          do {
            out.write("\n            ");
            if (_jspx_meth_aui_005fparam_005f0(_jspx_th_aui_005fcomponent_005f0, _jspx_page_context))
              return;
            out.write("\n            ");
            if (_jspx_meth_aui_005fparam_005f1(_jspx_th_aui_005fcomponent_005f0, _jspx_page_context))
              return;
            out.write("\n            ");
            //  aui:param
            webwork.view.taglib.ParamTag _jspx_th_aui_005fparam_005f2 = (webwork.view.taglib.ParamTag) _005fjspx_005ftagPool_005faui_005fparam_0026_005fname.get(webwork.view.taglib.ParamTag.class);
            boolean _jspx_th_aui_005fparam_005f2_reused = false;
            try {
              _jspx_th_aui_005fparam_005f2.setPageContext(_jspx_page_context);
              _jspx_th_aui_005fparam_005f2.setParent((javax.servlet.jsp.tagext.Tag) _jspx_th_aui_005fcomponent_005f0);
              // /secure/views/projectnotfound.jsp(16,12) name = name type = java.lang.String reqTime = false required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
              _jspx_th_aui_005fparam_005f2.setName("'messageHtml'");
              int _jspx_eval_aui_005fparam_005f2 = _jspx_th_aui_005fparam_005f2.doStartTag();
              if (_jspx_eval_aui_005fparam_005f2 != javax.servlet.jsp.tagext.Tag.SKIP_BODY) {
                if (_jspx_eval_aui_005fparam_005f2 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
                  out = org.apache.jasper.runtime.JspRuntimeLibrary.startBufferedBody(_jspx_page_context, _jspx_th_aui_005fparam_005f2);
                }
                do {
                  out.write("\n                <p>\n                    ");
                  //  ww:text
                  com.atlassian.jira.web.tags.TextTag _jspx_th_ww_005ftext_005f3 = (com.atlassian.jira.web.tags.TextTag) _005fjspx_005ftagPool_005fww_005ftext_0026_005fname.get(com.atlassian.jira.web.tags.TextTag.class);
                  boolean _jspx_th_ww_005ftext_005f3_reused = false;
                  try {
                    _jspx_th_ww_005ftext_005f3.setPageContext(_jspx_page_context);
                    _jspx_th_ww_005ftext_005f3.setParent((javax.servlet.jsp.tagext.Tag) _jspx_th_aui_005fparam_005f2);
                    // /secure/views/projectnotfound.jsp(18,20) name = name type = java.lang.String reqTime = false required = true fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
                    _jspx_th_ww_005ftext_005f3.setName("'project.does.not.exist.desc'");
                    int _jspx_eval_ww_005ftext_005f3 = _jspx_th_ww_005ftext_005f3.doStartTag();
                    if (_jspx_eval_ww_005ftext_005f3 != javax.servlet.jsp.tagext.Tag.SKIP_BODY) {
                      if (_jspx_eval_ww_005ftext_005f3 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
                        out = org.apache.jasper.runtime.JspRuntimeLibrary.startBufferedBody(_jspx_page_context, _jspx_th_ww_005ftext_005f3);
                      }
                      do {
                        out.write("\n                        ");
                        //  ww:param
                        webwork.view.taglib.ParamTag _jspx_th_ww_005fparam_005f0 = (webwork.view.taglib.ParamTag) _005fjspx_005ftagPool_005fww_005fparam_0026_005fname.get(webwork.view.taglib.ParamTag.class);
                        boolean _jspx_th_ww_005fparam_005f0_reused = false;
                        try {
                          _jspx_th_ww_005fparam_005f0.setPageContext(_jspx_page_context);
                          _jspx_th_ww_005fparam_005f0.setParent((javax.servlet.jsp.tagext.Tag) _jspx_th_ww_005ftext_005f3);
                          // /secure/views/projectnotfound.jsp(19,24) name = name type = java.lang.String reqTime = false required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
                          _jspx_th_ww_005fparam_005f0.setName("'value0'");
                          int _jspx_eval_ww_005fparam_005f0 = _jspx_th_ww_005fparam_005f0.doStartTag();
                          if (_jspx_eval_ww_005fparam_005f0 != javax.servlet.jsp.tagext.Tag.SKIP_BODY) {
                            if (_jspx_eval_ww_005fparam_005f0 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
                              out = org.apache.jasper.runtime.JspRuntimeLibrary.startBufferedBody(_jspx_page_context, _jspx_th_ww_005fparam_005f0);
                            }
                            do {
                              out.write("<a href=\"");
                              out.print( request.getContextPath());
                              out.write("/secure/BrowseProjects.jspa?selectedCategory=all\">");
                              int evalDoAfterBody = _jspx_th_ww_005fparam_005f0.doAfterBody();
                              if (evalDoAfterBody != javax.servlet.jsp.tagext.BodyTag.EVAL_BODY_AGAIN)
                              break;
                            } while (true);
                            if (_jspx_eval_ww_005fparam_005f0 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
                              out = _jspx_page_context.popBody();
                            }
                          }
                          if (_jspx_th_ww_005fparam_005f0.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
                            return;
                          }
                          _005fjspx_005ftagPool_005fww_005fparam_0026_005fname.reuse(_jspx_th_ww_005fparam_005f0);
                          _jspx_th_ww_005fparam_005f0_reused = true;
                        } finally {
                          org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_ww_005fparam_005f0, _jsp_getInstanceManager(), _jspx_th_ww_005fparam_005f0_reused);
                        }
                        out.write("\n                        ");
                        if (_jspx_meth_ww_005fparam_005f1(_jspx_th_ww_005ftext_005f3, _jspx_page_context))
                          return;
                        out.write("\n                    ");
                        int evalDoAfterBody = _jspx_th_ww_005ftext_005f3.doAfterBody();
                        if (evalDoAfterBody != javax.servlet.jsp.tagext.BodyTag.EVAL_BODY_AGAIN)
                          break;
                      } while (true);
                      if (_jspx_eval_ww_005ftext_005f3 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
                        out = _jspx_page_context.popBody();
                      }
                    }
                    if (_jspx_th_ww_005ftext_005f3.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
                      return;
                    }
                    _005fjspx_005ftagPool_005fww_005ftext_0026_005fname.reuse(_jspx_th_ww_005ftext_005f3);
                    _jspx_th_ww_005ftext_005f3_reused = true;
                  } finally {
                    org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_ww_005ftext_005f3, _jsp_getInstanceManager(), _jspx_th_ww_005ftext_005f3_reused);
                  }
                  out.write("\n                </p>\n                <p>\n                    ");
                  //  ww:text
                  com.atlassian.jira.web.tags.TextTag _jspx_th_ww_005ftext_005f4 = (com.atlassian.jira.web.tags.TextTag) _005fjspx_005ftagPool_005fww_005ftext_0026_005fname.get(com.atlassian.jira.web.tags.TextTag.class);
                  boolean _jspx_th_ww_005ftext_005f4_reused = false;
                  try {
                    _jspx_th_ww_005ftext_005f4.setPageContext(_jspx_page_context);
                    _jspx_th_ww_005ftext_005f4.setParent((javax.servlet.jsp.tagext.Tag) _jspx_th_aui_005fparam_005f2);
                    // /secure/views/projectnotfound.jsp(24,20) name = name type = java.lang.String reqTime = false required = true fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
                    _jspx_th_ww_005ftext_005f4.setName("'contact.admin.for.perm'");
                    int _jspx_eval_ww_005ftext_005f4 = _jspx_th_ww_005ftext_005f4.doStartTag();
                    if (_jspx_eval_ww_005ftext_005f4 != javax.servlet.jsp.tagext.Tag.SKIP_BODY) {
                      if (_jspx_eval_ww_005ftext_005f4 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
                        out = org.apache.jasper.runtime.JspRuntimeLibrary.startBufferedBody(_jspx_page_context, _jspx_th_ww_005ftext_005f4);
                      }
                      do {
                        out.write("\n                        ");
                        //  ww:param
                        webwork.view.taglib.ParamTag _jspx_th_ww_005fparam_005f2 = (webwork.view.taglib.ParamTag) _005fjspx_005ftagPool_005fww_005fparam_0026_005fname.get(webwork.view.taglib.ParamTag.class);
                        boolean _jspx_th_ww_005fparam_005f2_reused = false;
                        try {
                          _jspx_th_ww_005fparam_005f2.setPageContext(_jspx_page_context);
                          _jspx_th_ww_005fparam_005f2.setParent((javax.servlet.jsp.tagext.Tag) _jspx_th_ww_005ftext_005f4);
                          // /secure/views/projectnotfound.jsp(25,24) name = name type = java.lang.String reqTime = false required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
                          _jspx_th_ww_005fparam_005f2.setName("'value0'");
                          int _jspx_eval_ww_005fparam_005f2 = _jspx_th_ww_005fparam_005f2.doStartTag();
                          if (_jspx_eval_ww_005fparam_005f2 != javax.servlet.jsp.tagext.Tag.SKIP_BODY) {
                            if (_jspx_eval_ww_005fparam_005f2 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
                              out = org.apache.jasper.runtime.JspRuntimeLibrary.startBufferedBody(_jspx_page_context, _jspx_th_ww_005fparam_005f2);
                            }
                            do {
                              out.print( request.getAttribute("administratorContactLink"));
                              int evalDoAfterBody = _jspx_th_ww_005fparam_005f2.doAfterBody();
                              if (evalDoAfterBody != javax.servlet.jsp.tagext.BodyTag.EVAL_BODY_AGAIN)
                              break;
                            } while (true);
                            if (_jspx_eval_ww_005fparam_005f2 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
                              out = _jspx_page_context.popBody();
                            }
                          }
                          if (_jspx_th_ww_005fparam_005f2.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
                            return;
                          }
                          _005fjspx_005ftagPool_005fww_005fparam_0026_005fname.reuse(_jspx_th_ww_005fparam_005f2);
                          _jspx_th_ww_005fparam_005f2_reused = true;
                        } finally {
                          org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_ww_005fparam_005f2, _jsp_getInstanceManager(), _jspx_th_ww_005fparam_005f2_reused);
                        }
                        out.write("\n                    ");
                        int evalDoAfterBody = _jspx_th_ww_005ftext_005f4.doAfterBody();
                        if (evalDoAfterBody != javax.servlet.jsp.tagext.BodyTag.EVAL_BODY_AGAIN)
                          break;
                      } while (true);
                      if (_jspx_eval_ww_005ftext_005f4 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
                        out = _jspx_page_context.popBody();
                      }
                    }
                    if (_jspx_th_ww_005ftext_005f4.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
                      return;
                    }
                    _005fjspx_005ftagPool_005fww_005ftext_0026_005fname.reuse(_jspx_th_ww_005ftext_005f4);
                    _jspx_th_ww_005ftext_005f4_reused = true;
                  } finally {
                    org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_ww_005ftext_005f4, _jsp_getInstanceManager(), _jspx_th_ww_005ftext_005f4_reused);
                  }
                  out.write("\n                </p>\n            ");
                  int evalDoAfterBody = _jspx_th_aui_005fparam_005f2.doAfterBody();
                  if (evalDoAfterBody != javax.servlet.jsp.tagext.BodyTag.EVAL_BODY_AGAIN)
                    break;
                } while (true);
                if (_jspx_eval_aui_005fparam_005f2 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
                  out = _jspx_page_context.popBody();
                }
              }
              if (_jspx_th_aui_005fparam_005f2.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
                return;
              }
              _005fjspx_005ftagPool_005faui_005fparam_0026_005fname.reuse(_jspx_th_aui_005fparam_005f2);
              _jspx_th_aui_005fparam_005f2_reused = true;
            } finally {
              org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_aui_005fparam_005f2, _jsp_getInstanceManager(), _jspx_th_aui_005fparam_005f2_reused);
            }
            out.write("\n        ");
            int evalDoAfterBody = _jspx_th_aui_005fcomponent_005f0.doAfterBody();
            if (evalDoAfterBody != javax.servlet.jsp.tagext.BodyTag.EVAL_BODY_AGAIN)
              break;
          } while (true);
          if (_jspx_eval_aui_005fcomponent_005f0 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
            out = _jspx_page_context.popBody();
          }
        }
        if (_jspx_th_aui_005fcomponent_005f0.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
          return;
        }
        _005fjspx_005ftagPool_005faui_005fcomponent_0026_005ftheme_005ftemplate.reuse(_jspx_th_aui_005fcomponent_005f0);
        _jspx_th_aui_005fcomponent_005f0_reused = true;
      } finally {
        org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_aui_005fcomponent_005f0, _jsp_getInstanceManager(), _jspx_th_aui_005fcomponent_005f0_reused);
      }
      out.write("\n    </div>\n</body>\n</html>");
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
      // /secure/views/projectnotfound.jsp(5,8) name = name type = java.lang.String reqTime = false required = true fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ww_005ftext_005f0.setName("'project.does.not.exist.title'");
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

  private boolean _jspx_meth_ww_005ftext_005f1(javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  ww:text
    com.atlassian.jira.web.tags.TextTag _jspx_th_ww_005ftext_005f1 = (com.atlassian.jira.web.tags.TextTag) _005fjspx_005ftagPool_005fww_005ftext_0026_005fname_005fnobody.get(com.atlassian.jira.web.tags.TextTag.class);
    boolean _jspx_th_ww_005ftext_005f1_reused = false;
    try {
      _jspx_th_ww_005ftext_005f1.setPageContext(_jspx_page_context);
      _jspx_th_ww_005ftext_005f1.setParent(null);
      // /secure/views/projectnotfound.jsp(11,16) name = name type = java.lang.String reqTime = false required = true fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ww_005ftext_005f1.setName("'project.does.not.exist.title'");
      int _jspx_eval_ww_005ftext_005f1 = _jspx_th_ww_005ftext_005f1.doStartTag();
      if (_jspx_th_ww_005ftext_005f1.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005fww_005ftext_0026_005fname_005fnobody.reuse(_jspx_th_ww_005ftext_005f1);
      _jspx_th_ww_005ftext_005f1_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_ww_005ftext_005f1, _jsp_getInstanceManager(), _jspx_th_ww_005ftext_005f1_reused);
    }
    return false;
  }

  private boolean _jspx_meth_aui_005fparam_005f0(javax.servlet.jsp.tagext.JspTag _jspx_th_aui_005fcomponent_005f0, javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  aui:param
    webwork.view.taglib.ParamTag _jspx_th_aui_005fparam_005f0 = (webwork.view.taglib.ParamTag) _005fjspx_005ftagPool_005faui_005fparam_0026_005fname.get(webwork.view.taglib.ParamTag.class);
    boolean _jspx_th_aui_005fparam_005f0_reused = false;
    try {
      _jspx_th_aui_005fparam_005f0.setPageContext(_jspx_page_context);
      _jspx_th_aui_005fparam_005f0.setParent((javax.servlet.jsp.tagext.Tag) _jspx_th_aui_005fcomponent_005f0);
      // /secure/views/projectnotfound.jsp(14,12) name = name type = java.lang.String reqTime = false required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_aui_005fparam_005f0.setName("'messageType'");
      int _jspx_eval_aui_005fparam_005f0 = _jspx_th_aui_005fparam_005f0.doStartTag();
      if (_jspx_eval_aui_005fparam_005f0 != javax.servlet.jsp.tagext.Tag.SKIP_BODY) {
        if (_jspx_eval_aui_005fparam_005f0 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
          out = org.apache.jasper.runtime.JspRuntimeLibrary.startBufferedBody(_jspx_page_context, _jspx_th_aui_005fparam_005f0);
        }
        do {
          out.write("error");
          int evalDoAfterBody = _jspx_th_aui_005fparam_005f0.doAfterBody();
          if (evalDoAfterBody != javax.servlet.jsp.tagext.BodyTag.EVAL_BODY_AGAIN)
            break;
        } while (true);
        if (_jspx_eval_aui_005fparam_005f0 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
          out = _jspx_page_context.popBody();
        }
      }
      if (_jspx_th_aui_005fparam_005f0.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005faui_005fparam_0026_005fname.reuse(_jspx_th_aui_005fparam_005f0);
      _jspx_th_aui_005fparam_005f0_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_aui_005fparam_005f0, _jsp_getInstanceManager(), _jspx_th_aui_005fparam_005f0_reused);
    }
    return false;
  }

  private boolean _jspx_meth_aui_005fparam_005f1(javax.servlet.jsp.tagext.JspTag _jspx_th_aui_005fcomponent_005f0, javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  aui:param
    webwork.view.taglib.ParamTag _jspx_th_aui_005fparam_005f1 = (webwork.view.taglib.ParamTag) _005fjspx_005ftagPool_005faui_005fparam_0026_005fname.get(webwork.view.taglib.ParamTag.class);
    boolean _jspx_th_aui_005fparam_005f1_reused = false;
    try {
      _jspx_th_aui_005fparam_005f1.setPageContext(_jspx_page_context);
      _jspx_th_aui_005fparam_005f1.setParent((javax.servlet.jsp.tagext.Tag) _jspx_th_aui_005fcomponent_005f0);
      // /secure/views/projectnotfound.jsp(15,12) name = name type = java.lang.String reqTime = false required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_aui_005fparam_005f1.setName("'iconText'");
      int _jspx_eval_aui_005fparam_005f1 = _jspx_th_aui_005fparam_005f1.doStartTag();
      if (_jspx_eval_aui_005fparam_005f1 != javax.servlet.jsp.tagext.Tag.SKIP_BODY) {
        if (_jspx_eval_aui_005fparam_005f1 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
          out = org.apache.jasper.runtime.JspRuntimeLibrary.startBufferedBody(_jspx_page_context, _jspx_th_aui_005fparam_005f1);
        }
        do {
          if (_jspx_meth_ww_005ftext_005f2(_jspx_th_aui_005fparam_005f1, _jspx_page_context))
            return true;
          int evalDoAfterBody = _jspx_th_aui_005fparam_005f1.doAfterBody();
          if (evalDoAfterBody != javax.servlet.jsp.tagext.BodyTag.EVAL_BODY_AGAIN)
            break;
        } while (true);
        if (_jspx_eval_aui_005fparam_005f1 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
          out = _jspx_page_context.popBody();
        }
      }
      if (_jspx_th_aui_005fparam_005f1.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005faui_005fparam_0026_005fname.reuse(_jspx_th_aui_005fparam_005f1);
      _jspx_th_aui_005fparam_005f1_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_aui_005fparam_005f1, _jsp_getInstanceManager(), _jspx_th_aui_005fparam_005f1_reused);
    }
    return false;
  }

  private boolean _jspx_meth_ww_005ftext_005f2(javax.servlet.jsp.tagext.JspTag _jspx_th_aui_005fparam_005f1, javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  ww:text
    com.atlassian.jira.web.tags.TextTag _jspx_th_ww_005ftext_005f2 = (com.atlassian.jira.web.tags.TextTag) _005fjspx_005ftagPool_005fww_005ftext_0026_005fname_005fnobody.get(com.atlassian.jira.web.tags.TextTag.class);
    boolean _jspx_th_ww_005ftext_005f2_reused = false;
    try {
      _jspx_th_ww_005ftext_005f2.setPageContext(_jspx_page_context);
      _jspx_th_ww_005ftext_005f2.setParent((javax.servlet.jsp.tagext.Tag) _jspx_th_aui_005fparam_005f1);
      // /secure/views/projectnotfound.jsp(15,41) name = name type = java.lang.String reqTime = false required = true fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ww_005ftext_005f2.setName("'common.words.error'");
      int _jspx_eval_ww_005ftext_005f2 = _jspx_th_ww_005ftext_005f2.doStartTag();
      if (_jspx_th_ww_005ftext_005f2.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005fww_005ftext_0026_005fname_005fnobody.reuse(_jspx_th_ww_005ftext_005f2);
      _jspx_th_ww_005ftext_005f2_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_ww_005ftext_005f2, _jsp_getInstanceManager(), _jspx_th_ww_005ftext_005f2_reused);
    }
    return false;
  }

  private boolean _jspx_meth_ww_005fparam_005f1(javax.servlet.jsp.tagext.JspTag _jspx_th_ww_005ftext_005f3, javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  ww:param
    webwork.view.taglib.ParamTag _jspx_th_ww_005fparam_005f1 = (webwork.view.taglib.ParamTag) _005fjspx_005ftagPool_005fww_005fparam_0026_005fname.get(webwork.view.taglib.ParamTag.class);
    boolean _jspx_th_ww_005fparam_005f1_reused = false;
    try {
      _jspx_th_ww_005fparam_005f1.setPageContext(_jspx_page_context);
      _jspx_th_ww_005fparam_005f1.setParent((javax.servlet.jsp.tagext.Tag) _jspx_th_ww_005ftext_005f3);
      // /secure/views/projectnotfound.jsp(20,24) name = name type = java.lang.String reqTime = false required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_ww_005fparam_005f1.setName("'value1'");
      int _jspx_eval_ww_005fparam_005f1 = _jspx_th_ww_005fparam_005f1.doStartTag();
      if (_jspx_eval_ww_005fparam_005f1 != javax.servlet.jsp.tagext.Tag.SKIP_BODY) {
        if (_jspx_eval_ww_005fparam_005f1 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
          out = org.apache.jasper.runtime.JspRuntimeLibrary.startBufferedBody(_jspx_page_context, _jspx_th_ww_005fparam_005f1);
        }
        do {
          out.write("</a>");
          int evalDoAfterBody = _jspx_th_ww_005fparam_005f1.doAfterBody();
          if (evalDoAfterBody != javax.servlet.jsp.tagext.BodyTag.EVAL_BODY_AGAIN)
            break;
        } while (true);
        if (_jspx_eval_ww_005fparam_005f1 != javax.servlet.jsp.tagext.Tag.EVAL_BODY_INCLUDE) {
          out = _jspx_page_context.popBody();
        }
      }
      if (_jspx_th_ww_005fparam_005f1.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005fww_005fparam_0026_005fname.reuse(_jspx_th_ww_005fparam_005f1);
      _jspx_th_ww_005fparam_005f1_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_ww_005fparam_005f1, _jsp_getInstanceManager(), _jspx_th_ww_005fparam_005f1_reused);
    }
    return false;
  }
}
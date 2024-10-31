<%@ page import="com.opensymphony.util.TextUtils" %>
<%@ taglib uri="webwork" prefix="ww" %>
<%@ taglib uri="webwork" prefix="ui" %>
<%@ taglib uri="sitemesh-page" prefix="page" %>
<html>
<head>
	<title><ww:text name="'admin.issuefields.fieldconfigurations.view.field.configuration'"/></title>
    <meta name="admin.active.section" content="admin_issues_menu/element_options_section/fields_section"/>
    <meta name="admin.active.tab" content="field_configuration"/>
</head>
<body>
    <div id="fieldConfigurationContainer" data-field-id="<%= TextUtils.htmlEncode(request.getParameter("id")) %>"></div>
</body>
</html>

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
    <%-- We are explicitly passing null value to tell React to fetch default configuration--%>
    <div id="fieldConfigurationContainer" data-field-id="null"></div>
</body>
</html>

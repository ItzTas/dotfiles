/**
 * A dictionary of event types that JIRA will fire from time to time.
 *
 * @module jira/util/events/types
 * @deprecated Use {@link module:jira/api/events/types}
 */
// eslint-disable-next-line @atlassian/module-checks/no-invalid-define
define('jira/util/events/types', /** @alias module:jira/util/events/types */require('jira/api/events/types'));
AJS.namespace('JIRA.Events', null, require('jira/util/events/types'));
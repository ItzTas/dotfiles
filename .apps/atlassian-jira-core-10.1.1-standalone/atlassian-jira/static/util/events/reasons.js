/**
 * A dictionary of reasons for events being triggered in JIRA.
 * Typically used in conjunction with {@link module:jira/util/events/types} to
 * denote the specifics of why the event was fired.
 *
 * @module jira/util/events/reasons
 * @deprecated Use {@link module:jira/api/events/reasons}
 */
// eslint-disable-next-line @atlassian/module-checks/no-invalid-define
define('jira/util/events/reasons', /** @alias module:jira/util/events/reasons */require('jira/api/events/reasons'));
AJS.namespace('JIRA.CONTENT_ADDED_REASON', null, require('jira/util/events/reasons'));
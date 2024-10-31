/**
 * @deprecated Use jira/api/backbone-1.6
 */
define('backbone', [
    'jquery',
    'underscore',
    'atlassian/libs/factories/backbone-1.0.0',
    'jira/backbone-queryparams'
], function($, _, BackboneFactory, BackboneQueryparams) {

    var backbone = BackboneFactory(_, $);
    BackboneQueryparams(backbone);

    return backbone;
});
AJS.test.require(['jira.webresources:jira-global', 'jira.webresources:jira-dialog-core-2'], function () {
  'use strict';

  var $ = require('jquery');
  var _ = require('underscore');
  var Dialog = require('jira/dialog/dialog2');
  var DialogStack = require('jira/dialog/dialog-stack');
  var simpleDialogCreator = function simpleDialogCreator(title, options) {
    var $content = $('<div>').css({
      height: '200px'
    }).append($('<h2>').text(title));
    var defaultOptions = {
      content: function content(callback) {
        //This count is used to check that the content is cached.
        // eslint-disable-next-line no-use-before-define
        d.contentCall++;
        return callback($content);
      },
      height: '200px',
      windowTitle: title,
      id: title
    };
    var d = new Dialog($.extend(defaultOptions, options));
    d.isVisible = function () {
      return $content.is(':visible');
    };
    d.contentCall = 0;
    d.title = title;
    return d;
  };
  var dialogHidden = function dialogHidden(hiddenDialog, currentDialog) {
    if (!hiddenDialog.$popup || !hiddenDialog.isVisible()) {
      return true;
    }
    return hiddenDialog.$popup.css('z-index') < currentDialog.$popup.css('z-index');
  };
  var assertThrobberHidden = function assertThrobberHidden() {
    ok($('.jira-page-loading-indicator').length === 0, 'Throbber is removed when dialog is displayed');
  };
  var assertDialogDisplayedFactory = function assertDialogDisplayedFactory(dialogs, windowTitle) {
    return function (dialog) {
      if (dialog) {
        var title = dialog.title;
        ok(dialog.isVisible(), title + ' visible?');
        strictEqual(document.title, title, 'Title correctly set to \'' + title + '\'.');
        assertThrobberHidden();
      } else {
        strictEqual(document.title, windowTitle, 'Title correctly reset.');
      }
      for (var i = 0; i < dialogs.length; i++) {
        if (dialogs[i] !== dialog) {
          ok(dialogHidden(dialogs[i], dialog), dialogs[i].title + ' not visible?');
        }
      }
    };
  };
  var assertDialogContentCallCountFactory = function assertDialogContentCallCountFactory(dialogs) {
    return function () {
      for (var i = 0; i < arguments.length; i++) {
        var dialog = dialogs[i];
        strictEqual(dialog.contentCall, arguments[i], 'Content refreshed on \'' + dialog.title + '\' ' + arguments[i] + ' times?');
      }
    };
  };
  module('Dialog Tests', {
    teardown: function teardown() {
      //Remove any trace of the dialog when finished.
      $('.' + Dialog.ClassNames.DIALOG).remove();
    }
  });
  test('Stacks dialogs', function () {
    var dialog3 = simpleDialogCreator('Dialog3', {
      stacked: true
    });
    var dialog2 = simpleDialogCreator('Dialog2', {
      stacked: true
    });
    var dialog1 = simpleDialogCreator('Dialog1', {
      stacked: true
    });
    var dialogs = [dialog1, dialog2, dialog3];
    var origTitle = document.title;
    var windowTitle = document.title = 'Stacked Dialogs Test';
    var assertDialogDisplayed = assertDialogDisplayedFactory(dialogs, windowTitle);
    var assertDialogContentCallCount = assertDialogContentCallCountFactory(dialogs);

    //dialog1
    dialog1.show();
    assertDialogDisplayed(dialog1);
    assertDialogContentCallCount(1, 0, 0);

    //dialog1 -> dialog2
    dialog2.show();
    assertDialogDisplayed(dialog2);
    assertDialogContentCallCount(1, 1, 0);

    //dialog1 -> dialog2 -> dialog3
    dialog3.show();
    assertDialogDisplayed(dialog3);
    assertDialogContentCallCount(1, 1, 1);

    //dialog1 -> dialog2
    dialog3.hide();
    assertDialogDisplayed(dialog2);
    assertDialogContentCallCount(1, 1, 1);

    //dialog1 -> dialog2 -> dialog3
    dialog3.show();
    assertDialogDisplayed(dialog3);
    assertDialogContentCallCount(1, 1, 2);

    //dialog1 -> dialog2
    dialog3.hide();
    assertDialogDisplayed(dialog2);
    assertDialogContentCallCount(1, 1, 2);

    //dialog1
    dialog2.hide();
    assertDialogDisplayed(dialog1);
    assertDialogContentCallCount(1, 1, 2);

    // <EMPTY>
    dialog1.hide();
    assertDialogDisplayed(null);
    assertDialogContentCallCount(1, 1, 2);

    //dialog2
    dialog2.show();
    assertDialogDisplayed(dialog2);
    assertDialogContentCallCount(1, 2, 2);

    // <EMPTY>
    dialog2.hide();
    assertDialogDisplayed(null);
    assertDialogContentCallCount(1, 2, 2);

    //dialog3
    dialog3.show();
    assertDialogDisplayed(dialog3);
    assertDialogContentCallCount(1, 2, 3);

    //dialog3 -> dialog1
    dialog1.show();
    assertDialogDisplayed(dialog1);
    assertDialogContentCallCount(2, 2, 3);

    //dialog3 -> dialog1 -> dialog2
    dialog2.show();
    assertDialogDisplayed(dialog2);
    assertDialogContentCallCount(2, 3, 3);

    //dialog3 -> dialog1
    dialog2.hide();
    assertDialogDisplayed(dialog1);
    assertDialogContentCallCount(2, 3, 3);

    //dialog3
    dialog1.hide();
    assertDialogDisplayed(dialog3);
    assertDialogContentCallCount(2, 3, 3);

    //dialog3 -> diglog2
    dialog2.show();
    assertDialogDisplayed(dialog2);
    assertDialogContentCallCount(2, 4, 3);

    //dialog3
    dialog2.hide();
    assertDialogDisplayed(dialog3);
    assertDialogContentCallCount(2, 4, 3);

    // <EMPTY>
    dialog3.hide();
    assertDialogDisplayed(null);
    assertDialogContentCallCount(2, 4, 3);
    document.title = origTitle;
  });
  test('Test Simple Dialog Title Change', function () {
    var dialog1 = simpleDialogCreator('Dialog1');
    var dialog2 = simpleDialogCreator('Dialog2');
    var originalTitle = document.title;
    var testTitle = document.title = 'Test Dialog Title';
    var assertTitle = function assertTitle(dialog) {
      if (dialog) {
        strictEqual(document.title, dialog.title, dialog.title + ' title correct?');
      } else {
        strictEqual(document.title, testTitle, 'Original Title Restored?');
      }
    };
    dialog1.show();
    assertTitle(dialog1);
    dialog2.show();
    assertTitle(dialog2);
    dialog2.hide();
    assertTitle(null);
    dialog1.show();
    assertTitle(dialog1);
    dialog2.show();
    assertTitle(dialog2);
    dialog1.show();
    assertTitle(dialog1);
    dialog1.hide();
    assertTitle(null);
    document.title = originalTitle;
  });
  test('Test redirect instructions', function () {
    var dialog = simpleDialogCreator('Dialog1');
    var headers = {};
    var xhr = {
      getResponseHeader: function getResponseHeader(key) {
        return headers[key];
      }
    };
    var a = dialog._detectRedirectInstructions(xhr);
    deepEqual(a, {
      serverIsDone: false,
      redirectUrl: ''
    }, 'No header');
    headers['X-Atlassian-Dialog-Control'] = 'DONE';
    a = dialog._detectRedirectInstructions(xhr);
    deepEqual(a, {
      serverIsDone: true,
      redirectUrl: ''
    }, 'DONE header');
    headers['X-Atlassian-Dialog-Control'] = 'redirect:http://localhost.com';
    a = dialog._detectRedirectInstructions(xhr);
    deepEqual(a, {
      serverIsDone: true,
      redirectUrl: 'http://localhost.com'
    }, 'Redirect Header');
    headers['X-Atlassian-Dialog-Control'] = 'permissionviolation';
    a = dialog._detectRedirectInstructions(xhr);
    deepEqual(a, {
      serverIsDone: true,
      redirectUrl: window.location.href
    }, 'Permision Voilation');
  });
  module('Dialog headers', {
    setup: function setup() {
      this.$content = $('<p>Practically empty</p>');
      this.dialog = new Dialog({
        content: this.$content
      });
    },
    teardown: function teardown() {
      this.dialog.hide();
      this.$content.remove();
    }
  });
  test('Can provide plain-text for the heading', function () {
    var title = 'This is my dialog heading. It is made from win and awesome.';
    this.dialog.addHeading(title);
    notEqual(this.dialog.get$popupHeading().text().indexOf(title), -1, 'The title text should be present in the dialog');
  });
  test('heading contents are placed inside known container', function () {
    var title = 'Quite full';
    this.dialog.addHeading(title);
    var $heading = this.dialog.$popup.find(Dialog.getSelector('HEADING_AREA'));
    equal($heading.text(), title, 'The dialog\'s heading is inside an element with the HTML class from JIRA.Dialog.ClassNames.HEADING_AREA');
    equal($heading.find('h2').size(), 1, 'The dialog\'s heading is contained within an h2 element.');
  });
  test('Can provide HTML for the heading', function () {
    var titleHtml = 'One flew <i>over</i> the <strong>cuckoo\'s</strong> nest';
    this.dialog.addHeading(titleHtml);
    var $heading = this.dialog.$popup.find(Dialog.getSelector('HEADING_AREA'));
    equal($heading.find('h2').html(), titleHtml, 'HTML is preserved when added to the dialog heading');
  });
  test('H2 is placed first inside the heading', function () {
    var titleHtml = '<h2>Dialog title</h2><div>Some additional stuff</div>';
    this.dialog.addHeading(titleHtml);
    var $heading = this.dialog.$popup.find(Dialog.getSelector('HEADING_AREA'));
    equal($heading.find(':first-child').prop('tagName'), 'H2', 'H2 is the first element in the heading');
  });
  test('H2 is placed first inside the heading regardless the order of elements provided', function () {
    var titleHtml = '<div>Some additional stuff</div><h2>Dialog title</h2>';
    this.dialog.addHeading(titleHtml);
    var $heading = this.dialog.$popup.find(Dialog.getSelector('HEADING_AREA'));
    equal($heading.find(':first-child').prop('tagName'), 'H2', 'H2 is the first element in the heading');
  });
  module('Dialog resources', {
    setup: function setup() {
      this.sandbox = sinon.sandbox.create();
      var $content = $('<div>');
      this.dialogOptions = {
        resources: ['resource1', 'resource2'],
        contexts: ['context1', 'context2'],
        content: function content(callback) {
          return callback($content);
        }
      };
      this.context = AJS.test.mockableModuleContext();
      this.requireDeferred = new $.Deferred();
      this.wrmRequire = this.sandbox.stub();
      this.context.mock('wrm/require', this.wrmRequire);
      this.Dialog = this.context.require('jira/dialog/dialog');
      this.WRMDialog = this.Dialog.extend({
        defineResources: function defineResources() {
          this._super.apply(this, arguments);
          (this.options.resources || []).forEach(function (resource) {
            this.requireResource(resource);
          }, this);
          (this.options.contexts || []).forEach(function (context) {
            this.requireContext(context);
          }, this);
        }
      });
    },
    teardown: function teardown() {
      this.sandbox.restore();
    }
  });
  test('New dialog instance will not prefetch resources in constructor when prefetchResources field is not true', function () {
    new this.WRMDialog(this.dialogOptions);
    ok(this.wrmRequire.notCalled, 'require not called');
  });
  test('New dialog instance will prefetch resources in constructor when prefetchResources field is true', function () {
    new this.WRMDialog(_.extend(this.dialogOptions, {
      prefetchResources: true
    }));
    ok(this.wrmRequire.calledOnce, 'require called once');
    deepEqual(this.wrmRequire.getCall(0).args[0], ['wr!resource1', 'wr!resource2', 'wrc!context1', 'wrc!context2'], 'WRM.require called with proper args');
  });
  test('Show will not download resources if none specified', function () {
    var dialog = new this.WRMDialog();
    ok(this.wrmRequire.notCalled, 'require not called after constructor');
    dialog.show();
    ok(this.wrmRequire.notCalled, 'require not called after show');
    dialog.hide();
  });
  test('Show will download resources once if specified', function () {
    this.wrmRequire.returns(this.requireDeferred);
    var dialog = new this.WRMDialog(this.dialogOptions);
    ok(this.wrmRequire.notCalled, 'require not called after constructor');
    dialog.show();
    ok(this.wrmRequire.calledOnce, 'require called once');
    deepEqual(this.wrmRequire.getCall(0).args[0], ['wr!resource1', 'wr!resource2', 'wrc!context1', 'wrc!context2'], 'WRM.require called with proper args');
    dialog.hide();
    dialog.show();
    ok(this.wrmRequire.calledOnce, 'require called once');
    dialog.hide();
  });
  test('Does not show dialog until resources resolved', function () {
    this.wrmRequire.returns(this.requireDeferred);
    var dialog = new this.WRMDialog(this.dialogOptions);
    var _showContent = this.sandbox.spy(dialog, '_onShowContent');
    ok(this.wrmRequire.notCalled, 'require not called after constructor');
    dialog.show();
    ok(this.wrmRequire.calledOnce, 'require called once');
    ok(_showContent.notCalled);
    this.requireDeferred.resolve();
    ok(_showContent.calledOnce, 'showContent called after resources resolve');
    dialog.hide();
  });
  test('Dialog constructor should call options defineResources with itself in scope', function () {
    var defineResources = this.sandbox.stub();
    var dialog = new this.Dialog({
      defineResources: defineResources
    });
    ok(defineResources.calledOnce, 'defineResources was called once');
    deepEqual(defineResources.getCall(0).thisValue, dialog, 'defineResources called with dialog as this.');
  });
  module('setContent', {
    teardown: function teardown() {
      this.dialog.hide();
      this.$content.remove();
    }
  });
  test('should convert legacy footer to the new footer (AUI Dialog2)', function () {
    // given
    this.$content = $('<div>Dialog<div class="buttons">Legacy footer</div></div>');
    var $expectedFooter = this.$content.find('.buttons');
    this.dialog = new Dialog({
      content: this.$content
    });

    // when
    this.dialog.show();

    // then
    var $dialogContent = this.dialog.$popup;
    equal($dialogContent.children().length, 3, 'Dialog contains three child elements');
    var footerElement = $dialogContent.children().get(2);
    equal(footerElement.tagName, 'DIV', 'Footer is created and put as the last child of the dialog');
    equal(footerElement.className, 'aui-dialog2-footer', 'Footer has correct class name');
    ok($(footerElement).children().get(0).isEqualNode($expectedFooter[0]), 'Footer has correct content');
  });
  test('should promote footer outside main content area', function () {
    // given
    this.$content = $('<div>Dialog content<div class="aui-dialog2-footer">AUI Dialog2 footer</div></div>');
    var $expectedFooter = this.$content.find('.aui-dialog2-footer');
    this.dialog = new Dialog({
      content: this.$content
    });

    // when
    this.dialog.show();

    // then
    var $dialogContent = this.dialog.$popup;
    equal($dialogContent.children().length, 3, 'Dialog contains three child elements');
    var footerElement = $dialogContent.children().get(2);
    ok(footerElement.isEqualNode($expectedFooter[0]), 'Footer is promoted after dialog main content area');
  });
  test('should promote heading outside main content area', function () {
    // given
    this.$content = $('<div>Dialog content<div class="aui-dialog2-header jira-dialog-core-heading">AUI Dialog2 header</div></div>');
    var $expectedHeader = this.$content.find('.aui-dialog2-header');
    this.dialog = new Dialog({
      content: this.$content
    });

    // when
    this.dialog.show();

    // then
    var $dialogContent = this.dialog.$popup;
    equal($dialogContent.children().length, 2, 'Dialog contains two child elements');
    var headerElement = $dialogContent.children().get(0);
    ok(headerElement.isEqualNode($expectedHeader[0]), 'Header is promoted before dialog main content area');
  });
  test('should pull nested dialog content to the main content area', function () {
    // given
    this.$content = $('<div>Dialog content<div class="aui-dialog2-content jira-dialog-core-content"><div>AUI Dialog2 content</div></div></div>');
    this.dialog = new Dialog({
      content: this.$content
    });

    // when
    this.dialog.show();

    // then
    var $dialogContent = this.dialog.$popup;
    equal($dialogContent.children().length, 2, 'Dialog contains two child elements');
    var $dialogMainContent = $dialogContent.find('.jira-dialog-core-content');
    equal($dialogMainContent.html(), '<div>Dialog content<div>AUI Dialog2 content</div></div>', 'Nested main content is pulled out and inserted to the root main content');
  });
  test('should place content between footer and header if footer already exists', function () {
    // given
    this.$content = $('<div>Dialog content<div class="aui-dialog2-content jira-dialog-core-content"><div>AUI Dialog2 content</div></div></div>');
    this.dialog = new Dialog({
      content: this.$content
    });

    // when
    this.dialog.addFooterButtons($('<button>Button 1</button>'));
    this.dialog.show();

    // then
    var $dialogContent = this.dialog.$popup;
    equal($dialogContent.children().get(0), $dialogContent.find('.aui-dialog2-header').get(0), 'Header is the first child');
    equal($dialogContent.children().get(1), $dialogContent.find('.jira-dialog-core-content').get(0), 'Content is the second child');
    equal($dialogContent.children().get(2), $dialogContent.find('.aui-dialog2-footer').get(0), 'Footer is the third child');
  });
  module('DialogFooter', {
    setup: function setup() {
      this.sandbox = sinon.sandbox.create();
    },
    teardown: function teardown() {
      this.dialog.hide();
      this.$content.remove();
      this.sandbox.restore();
    }
  });
  test('should render footer and buttons if adding footer buttons and dialog has no footer', function () {
    var _this$dialog;
    var buttons = [$('<button>Button 1</button>'), $('<button>Button 2</button>')];
    this.$content = $('<div>Dialog content</div>');
    this.dialog = new Dialog({
      content: this.$content
    });
    this.dialog.show();
    var $dialogContent = this.dialog.$popup;
    equal($dialogContent.children('.aui-dialog2-footer').length, 0, 'Dialog doesn\'t have footer');
    (_this$dialog = this.dialog).addFooterButtons.apply(_this$dialog, buttons);
    equal($dialogContent.children('.aui-dialog2-footer').length, 1, 'Dialog has footer');
    equal($dialogContent.find('.aui-dialog2-footer .buttons').children().get(0), buttons[0].get(0), 'First button is added');
    equal($dialogContent.find('.aui-dialog2-footer .buttons').children().get(1), buttons[1].get(0), 'Second button is added');
  });
  test('should add cancel button', function () {
    this.$content = $('<div>Dialog content</div>');
    this.dialog = new Dialog({
      content: this.$content
    });
    this.dialog.show();
    var $dialogContent = this.dialog.$popup;
    var callback = sinon.spy();
    this.dialog.addCancelButton(callback);
    equal($dialogContent.find('.aui-dialog2-footer').children().length, 1, 'Footer has one button');
    equal(callback.callCount, 0, 'Callback not called');
  });
  test('should hide the dialog and call passed callback when clicking cancel button', function () {
    this.$content = $('<div>Dialog content</div>');
    this.dialog = new Dialog({
      content: this.$content
    });
    this.dialog.show();
    var $dialogContent = this.dialog.$popup;
    var callback = sinon.spy();
    this.dialog.addCancelButton(callback);
    $dialogContent.find('.aui-dialog2-footer button').click();
    equal(callback.callCount, 1, 'Callback called');
    equal($dialogContent.is(':visible'), false, 'Dialog hidden');
  });
  test('should add primary button and call callback on click', function () {
    this.$content = $('<div>Dialog content</div>');
    this.dialog = new Dialog({
      content: this.$content
    });
    this.dialog.show();
    var $dialogContent = this.dialog.$popup;
    var callback = sinon.spy();
    this.dialog.addMainActionButton({}, callback);
    equal($dialogContent.find('.aui-dialog2-footer').children().length, 1, 'Footer has one button');
    equal(callback.callCount, 0, 'Callback not called');
    $dialogContent.find('.aui-dialog2-footer button').click();
    equal(callback.callCount, 1, 'Callback called');
  });
  test('should add primary button with custom props', function () {
    this.$content = $('<div>Dialog content</div>');
    this.dialog = new Dialog({
      content: this.$content
    });
    this.auiButtonTemplateStub = this.sandbox.spy(aui.buttons, 'button'); // eslint-disable-line no-undef

    this.dialog.show();
    var callback = sinon.spy();
    this.dialog.addMainActionButton({
      extraClasses: ['foo'],
      text: 'Primary'
    }, callback);
    equal(this.auiButtonTemplateStub.calledOnce, true, 'AUI button template is called');
    equal(this.auiButtonTemplateStub.getCall(0).args[0].extraClasses[0], 'foo', 'Button is called with extra class');
    equal(this.auiButtonTemplateStub.getCall(0).args[0].text, 'Primary', 'Button has correct text');
  });
  test('should add primary button with disabled state by default', function () {
    this.$content = $('<div>Dialog content</div>');
    this.dialog = new Dialog({
      content: this.$content
    });
    this.auiButtonTemplateStub = this.sandbox.spy(aui.buttons, 'button'); // eslint-disable-line no-undef

    this.dialog.show();
    this.dialog.addMainActionButton({
      text: 'Primary',
      defaultEnabled: false
    });
    equal(this.auiButtonTemplateStub.calledOnce, true, 'AUI button template is called');
    equal(this.auiButtonTemplateStub.getCall(0).args[0].isDisabled, true, 'Button is disabled');
  });
  test('should add primary button with default state', function () {
    this.$content = $('<div>Dialog content</div>');
    this.dialog = new Dialog({
      content: this.$content
    });
    this.auiButtonTemplateStub = this.sandbox.spy(aui.buttons, 'button'); // eslint-disable-line no-undef

    this.dialog.show();
    this.dialog.addMainActionButton({}, function () {});
    var calledOptions = this.auiButtonTemplateStub.getCall(0).args[0];
    equal(calledOptions.isDisabled, false, 'Button is enabled');
    equal(calledOptions.type, 'primary', 'Button is primary');
    equal(calledOptions.text, 'common.forms.confirm', 'Button has default text');
    equal(calledOptions.extraClasses.length, 0, 'Button has no extra classes');
  });
  test('should disable controls of non-cancel buttons', function () {
    this.$content = $('<div>Dialog content</div>');
    this.dialog = new Dialog({
      content: this.$content
    });
    this.dialog.show();
    var $dialogContent = this.dialog.$popup;
    this.dialog.addCancelButton();
    this.dialog.addFooterButtons($('<button>Button 1</button>'), $('<button>Button 2</button>'));
    var $cancelButton = $dialogContent.find('.aui-dialog2-footer button.cancel');
    var $primaryButtons = $dialogContent.find('.aui-dialog2-footer button:not(.cancel)');
    this.dialog.disableControls();
    equal($cancelButton.prop('disabled'), false, 'Cancel button is enabled');
    equal($primaryButtons.get(0).disabled, true, 'First primary button is disabled');
    equal($primaryButtons.get(1).disabled, true, 'Second primary button is disabled');
  });
  test('should enable controls of non-cancel buttons', function () {
    this.$content = $('<div>Dialog content</div>');
    this.dialog = new Dialog({
      content: this.$content
    });
    this.dialog.show();
    var $dialogContent = this.dialog.$popup;
    this.dialog.addCancelButton();
    this.dialog.addFooterButtons($('<button>Button 1</button>'), $('<button>Button 2</button>'));
    var $cancelButton = $dialogContent.find('.aui-dialog2-footer button.cancel');
    var $primaryButtons = $dialogContent.find('.aui-dialog2-footer button:not(.cancel)');
    $primaryButtons.prop('disabled', true);
    this.dialog.enableControls();
    equal($cancelButton.prop('disabled'), false, 'Cancel button is enabled');
    equal($primaryButtons.get(0).disabled, false, 'First primary button is enabled');
    equal($primaryButtons.get(1).disabled, false, 'Second primary button is enabled');
  });
  test('should add form attribute if dialog has form and submit button does not have the attribute', function () {
    this.$content = $('<form id="dialog2-form">Dialog2 form<div class="aui-dialog2-footer"><button type="submit">Submit</button></div></form>');
    this.dialog = new Dialog({
      content: this.$content
    });
    this.dialog.show();
    var $dialogContent = this.dialog.$popup;
    var $form = $dialogContent.find('form');
    var $button = $dialogContent.find('.aui-dialog2-footer button[type=submit]');
    equal($button.attr('form'), $form.attr('id'), 'Button has form attribute');
  });
  test('should not add form attribute if dialog does not have form', function () {
    this.$content = $('<div>Dialog2 content<div class="aui-dialog2-footer"><button type="submit">Submit</button></div></div>');
    this.dialog = new Dialog({
      content: this.$content
    });
    this.dialog.show();
    var $dialogContent = this.dialog.$popup;
    var $button = $dialogContent.find('div button[type=submit]');
    equal($button.attr('form'), undefined, 'Button does not have form attribute');
  });

  // Note: This module must be run as last since DialogStack is not restored; any other tests would fail afterwards
  // legacy: check for deprecated `current` prop support (should be removed in the future)
  module('DialogStack', {
    setup: function setup() {
      this.context = AJS.test.mockableModuleContext();
      this.DialogStack = this.context.require('jira/dialog/dialog-stack');
    }
  });
  test('[BC] Should support reading directly from `current` prop', function () {
    var o = null;
    DialogStack.current = o;
    strictEqual(Dialog.current, o);
  });
  test('[BC] Should support writing directly to `current` prop', function () {
    var o = {};
    DialogStack.current = null;
    Dialog.current = o;
    strictEqual(Dialog.current, o);
    strictEqual(DialogStack.current, o);
  });
});
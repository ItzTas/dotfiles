define("jira/setup/setup-account-view",["marionette","underscore","jira/setup/setup-tracker","jira/flag"],(function(e,i,t,s){var a=e.ItemView.extend({ui:{email:"#jira-setup-account-field-email",username:"#jira-setup-account-field-username",innerForm:".jira-setup-account-contents",form:".jira-setup-form",formField:".jira-setup-account-form-field",password:"#jira-setup-account-field-password",retypePassword:"#jira-setup-account-field-retype-password",submitButton:"#jira-setup-account-button-submit",emailHidden:"#jira-setup-account-email-hidden",usernameHidden:"#jira-setup-account-username-hidden",licenseHidden:"#jira-setup-account-license-hidden",passwordHidden:"#jira-setup-account-password-hidden"},events:{"submit @ui.form":"onSubmit","input @ui.password":"onPasswordValueChanged","input @ui.retypePassword":"onRetypePasswordValueChanged","input @ui.email":"onEmailValueChanged","input @ui.username":"onUsernameValueChanged","blur @ui.password":"onFormElementFocusOut","blur @ui.retypePassword":"onFormElementFocusOut","blur @ui.email":"onFormElementFocusOut","blur @ui.username":"onFormElementFocusOut"},initialize:function(e){this.bindUIElements();this.errorTexts=this.ui.innerForm.data("error-texts");this.fields={email:{invalidEmail:this.errorTexts.invalidEmail,required:this.errorTexts.emailRequired},password:{required:this.errorTexts.passwordRequired},username:{required:this.errorTexts.usernameRequired,invalidUsername:this.errorTexts.invalidUsername,tooLongUsername:this.errorTexts.tooLongUsername},retypePassword:{required:this.errorTexts.passwordRetypeRequired,passwordsMatch:this.errorTexts.passwordsDoNotMatch}};this.viewValidationState={errors:{},decoratedFields:{},timeout:null};this.setupTracker=i.isEmpty(e.setupTracker)?t:e.setupTracker;this.ui.email.val(e.email);this.ui.password.val(e.password);this.ui.retypePassword.val(e.password);this.showLicenseState()},getValues:function(){var e={};i.each(Object.keys(this.fields),(function(i){this.ui[i].length&&(e[i]=this.ui[i].val())}),this);return e},validate:function(e){var t={};e=e||this.getValues();i.each(this.fields,(function(i,s){s in e&&(i.required&&!e[s].length?t[s]=i.required:i.invalidEmail&&!this.validateEmailValue(e[s])?t[s]=i.invalidEmail:i.invalidUsername&&!this.validateUsernameValue(e[s])?t[s]=i.invalidUsername:i.tooLongUsername&&!this.validateUsernameLength(e[s])?t[s]=i.tooLongUsername:i.passwordsMatch&&e.password&&e.retypePassword&&e.password!=e.retypePassword&&(t[s]=i.passwordsMatch))}),this);this.viewValidationState.errors=t;return 0===Object.keys(this.viewValidationState.errors).length},validateEmailValue:function(e){return!(e.length>255)&&/^[a-zA-Z0-9.!#$%'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/.test(e)},validateUsernameValue:function(e){return-1===e.indexOf("&")&&(-1===e.indexOf("<")&&(-1===e.indexOf(">")&&-1===e.indexOf(" ")))},validateUsernameLength:function(e){return e.length<=a.MAX_USERNAME_LEN},onPasswordValueChanged:function(){this._handleFieldChange("password");this.ui.passwordHidden.val(this.ui.password.val())},onRetypePasswordValueChanged:function(){this._handleFieldChange("retypePassword")},onEmailValueChanged:function(){this._handleFieldChange("email");this._propagateEmailToUsername();this.ui.emailHidden.val(this.ui.email.val())},onUsernameValueChanged:function(){this._handleFieldChange("username");this.ui.usernameHidden.val(this.ui.username.val())},_propagateEmailToUsername:function(){if(!this.viewValidationState.decoratedFields.username){var e,i=this.ui.email.val(),t=i.indexOf("@");e=t<0?i:i.substring(0,t);this.ui.username.val(e);this.ui.usernameHidden.val(e)}},_handleFieldChange:function(e){delete this.viewValidationState.errors[e];this.viewValidationState.decoratedFields[e]=!0;this._renderErrors([e]);var t=this.viewValidationState.timeout;t&&clearTimeout(t);this.validate();this.viewValidationState.timeout=setTimeout(i.bind(this._renderErrors,this),a.VALIDATION_TIMEOUT)},onFormElementFocusOut:function(){var e=this.viewValidationState.timeout;e&&clearTimeout(e);this._renderErrors()},_isLicensePresent:function(){return!!this.ui.licenseHidden.val()},showLicenseState:function(){var e=this.ui.innerForm.data("flag-texts");if(this._isLicensePresent()){setTimeout((function(){s.showSuccessMsg(e.successTitle,e.successContent,{close:"auto"})}),a.FLAG_TIMEOUT);this.setupTracker.sendUserArrivedFromMacSuccess()}else{setTimeout((function(){s.showErrorMsg(e.errorTitle,e.errorContent,{close:"never"})}),a.FLAG_TIMEOUT);this.ui.submitButton.enable(!1)}},_renderErrors:function(e){var t=this;e=e||Object.keys(this.viewValidationState.decoratedFields);i.each(e,(function(e){var i=t.ui[e].siblings(".error");t.viewValidationState.errors[e]?i.removeClass("hidden").html(t.viewValidationState.errors[e]):i.empty().addClass("hidden")}))},onSubmit:function(e){if(this.validate())this.ui.submitButton.enable(!1);else{e.preventDefault();i.each(Object.keys(this.fields),i.bind((function(e){this.viewValidationState.decoratedFields[e]=!0}),this));this._renderErrors()}}},{FLAG_TIMEOUT:1e3,VALIDATION_TIMEOUT:1200,MAX_USERNAME_LEN:255});return a}));
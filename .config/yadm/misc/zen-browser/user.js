// ==== Privacy ====
user_pref('privacy.resistFingerprinting', true); // Makes your browser appear more generic to resist fingerprinting
user_pref('privacy.trackingprotection.enabled', true); // Enables built-in tracking protection

// ==== Media ====
user_pref('media.peerconnection.enabled', false); // Completely disables WebRTC (prevents IP leaks)
user_pref('media.peerconnection.ice.default_address_only', true); // Only use default network address for WebRTC (if enabled)
user_pref('media.peerconnection.ice.no_host', true); // Prevents exposing local IPs in WebRTC (if enabled)

// ==== Browser Telemetry ====
user_pref('browser.ping-centre.telemetry', false); // Disables telemetry sent to Mozilla via PingCentre
user_pref('browser.newtabpage.activity-stream.feeds.telemetry', false); // Disables telemetry on the new tab activity stream

// ==== WebGL ====
user_pref('webgl.disabled', true); // Disables WebGL to reduce fingerprinting surface

// ==== Device ====
user_pref('device.sensors.enabled', false); // Disables access to device motion/orientation sensors

// ==== DOM APIs ====
user_pref('dom.webaudio.enabled', false); // Disables Web Audio API (can be used for fingerprinting)
user_pref('dom.battery.enabled', false); // Disables access to battery status (used for tracking)

// ==== Data Reporting ====
user_pref('datareporting.healthreport.uploadEnabled', false); // Prevents uploading of health reports to Mozilla

// ==== Beacon ====
user_pref('beacon.enabled', true); // Blocks the Beacon API, which sends data when leaving pages

// ==== Toolkit Telemetry ====
user_pref('toolkit.telemetry.enabled', false); // Fully disables telemetry
user_pref('toolkit.telemetry.unified', false); // Prevents unified telemetry collection

// ==== Network ====
user_pref('network.dns.disablePrefetch', true); // Disables DNS prefetching to avoid unintended lookups
user_pref('network.prefetch-next', false); // Disables link prefetching for privacy

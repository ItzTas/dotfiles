// ==== Privacy ====
user_pref('privacy.resistFingerprinting', false); // Makes your browser appear more generic to resist fingerprinting
user_pref('privacy.trackingprotection.enabled', true); // Enables built-in tracking protection
user_pref('privacy.clearOnShutdown.cache', false); // Cleans cache on exit

// ==== Media ====
user_pref('media.peerconnection.enabled', true); // WebRTC (if disabled prevents IP leaks)
user_pref('media.peerconnection.ice.default_address_only', true); // Only use default network address for WebRTC (if enabled)
user_pref('media.peerconnection.ice.no_host', true); // Prevents exposing local IPs in WebRTC (if enabled)

// ==== Browser Telemetry ====
user_pref('browser.ping-centre.telemetry', false); // Telemetry sent to Mozilla via PingCentre
user_pref('browser.newtabpage.activity-stream.feeds.telemetry', false); // Telemetry on the new tab activity stream

// ==== WebGL ====
user_pref('webgl.disabled', false); // WebGL

// ==== Device ====
user_pref('device.sensors.enabled', false); // Access to device motion/orientation sensors

// ==== DOM APIs ====
user_pref('dom.webaudio.enabled', true); // Web Audio API (can be used for fingerprinting)
user_pref('dom.battery.enabled', false); // Access to battery status (used for tracking)

// ==== Data Reporting ====
user_pref('datareporting.healthreport.uploadEnabled', false); // Uploading of health reports to Mozilla

// ==== Beacon ====
user_pref('beacon.enabled', false); // The Beacon API, which sends data when leaving pages

// ==== Toolkit Telemetry ====
user_pref('toolkit.telemetry.enabled', false); // Toolkit telemetry
user_pref('toolkit.telemetry.unified', false); // Unified telemetry collection

// ==== Network ====
user_pref('network.dns.disablePrefetch', true); // DNS prefetching to avoid unintended lookups
user_pref('network.prefetch-next', false); // Link prefetching

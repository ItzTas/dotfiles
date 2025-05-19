// ==== Privacy ====
user_pref('privacy.resistFingerprinting', true); // Makes your browser appear more generic to resist fingerprinting

// ==== Media ====
user_pref('media.peerconnection.enabled', false); // Completely disables WebRTC (prevents IP leaks)
user_pref('media.peerconnection.ice.default_address_only', true); // Only use default network address for WebRTC (if enabled)
user_pref('media.peerconnection.ice.no_host', true); // Prevents exposing local IPs in WebRTC (if enabled)

// ==== Network ====
user_pref('network.dns.disablePrefetch', true); // Disables DNS prefetching to avoid unintended lookups
user_pref('network.prefetch-next', false); // Disables link prefetching for privacy

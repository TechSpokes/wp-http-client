# Let the site decide unsafe URL rejection

Status: proposed.

## Context and problem

`wp_remote_request()` sets `reject_unsafe_urls` from the `http_request_reject_unsafe_urls` filter, which defaults to `false`. `wp_safe_remote_request()` forces it to `true`, which routes the URL through `wp_http_validate_url()`: scheme and port restrictions, with a known DNS-rebinding weakness.

Core's private PSR-18 adapter for the AI client chose `wp_safe_remote_request()` because provider endpoints are configurable. The package serves arbitrary plugins, some of which call `localhost`, non-standard ports or development hosts on purpose.

## Options considered

### Always reject unsafe URLs

This protects plugins that forget to ask for it. It breaks legitimate internal calls and overrides an operator who deliberately left the filter at its default.

### Never reject unsafe URLs

This is the simplest option. It throws away a policy an operator may have set to `true`.

### Leave the setting to the site, and offer safe() to force it on

The package does not set `reject_unsafe_urls`, so the site filter decides. `safe()` on a client or an endpoint forces it to `true`, mirroring `wp_safe_remote_*`. Nothing forces it to `false`.

## Decision

Leave the setting to the site and offer `safe()`. It is the only option that neither overrides an operator's choice nor lets a plugin undo it.

The package passes `reject_unsafe_urls` only as `true`, through `safe()`, and otherwise omits the key. An explicit `reject_unsafe_urls => false` from a package caller is not passed on to WordPress. This is the single exception to passing explicit request arguments through unchanged (see 0004).

The documentation states the rule plainly: call `safe()` whenever the URL comes from anything other than the plugin's own configuration.

## Consequences

Plugins migrating from `wp_remote_*` see no change. Plugins migrating from `wp_safe_remote_*` add one call. A plugin can be stricter than the site, never looser.

Safe mode does not defend against DNS rebinding; nothing in PHP userland can without pinning resolved addresses. The documentation says so.

## Confirmation

Unit tests check that requests without `safe()` carry no `reject_unsafe_urls` key, that `safe()` sets it to `true`, and that an explicit `false` is dropped.

## More information

- [0004 Inherit transport settings from WordPress](0004-inherit-transport-settings-from-wordpress.md)
- [Developer pain points](../research/developer-pain-points.md)
- [Patchstack: exploring the unpatched WordPress SSRF](https://patchstack.com/articles/exploring-the-unpatched-wordpress-ssrf/)
- [wp_safe_remote_get reference](https://developer.wordpress.org/reference/functions/wp_safe_remote_get/)

# Stream downloads with WordPress file options

Status: proposed.

## Context and problem

`WP_Http` writes a response to `filename` when `stream` is set, defaulting to `get_temp_dir() . basename( $url )`. It forces `blocking`, checks that the directory is writable, and maps `limit_response_size` to Requests' `max_bytes`.

Requests' cURL transport writes through `CURLOPT_WRITEFUNCTION` and dispatches `request.progress`. Request bodies are stringified before cURL sees them, so `CURLFile` uploads fail (Trac #63828).

## Options considered

### Buffer every response in memory

This is simple, but a large download exhausts PHP memory.

### Write the package's own streaming code

This duplicates WordPress and loses its writable-directory checks and temp-dir default.

### Map downloads onto WordPress's stream, filename and limit_response_size

The package exposes behaviour WordPress already has, per batch member, with a clearer API.

## Decision

Map downloads onto WordPress's own options. `Endpoint::download($url)->toFile($path)->maxBytes($n)` maps one to one onto `stream`, `filename` and `limit_response_size`, including the temp-dir default when no path is given, and works per member inside a batch.

The response body is a PSR-7 stream over the file. A download that reaches the byte cap is reported as truncated, never as complete. No progress callback ships in 1.0; one can be added in 1.x if a real consumer needs it.

The package builds multipart upload bodies from paths or streams into a correct string with boundary and `Content-Type`. Streamed request bodies are out of scope because the platform cannot send them.

## Consequences

Large downloads stay off the PHP heap and respect a size cap. Uploads work through the HTTP API without `CURLFile`, but the whole body is held in memory.

## Confirmation

Integration tests download to a file with a size cap, inside and outside a batch, and upload a multipart body to a test endpoint.

## More information

- [Developer pain points](../research/developer-pain-points.md)
- [Trac #63828: Can't use CURLFile with wp_remote_post](https://core.trac.wordpress.org/ticket/63828)

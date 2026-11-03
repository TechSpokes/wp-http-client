# Hold a final client in each plugin or theme

Status: proposed.

## Context and problem

A plugin or theme needs one place for its base URI, credentials and calls to an API, so that URLs and configuration do not spread through its code. An SDK or a one-off call in a theme needs far less: a PSR-18 client or a single request.

The shape of the client also decides what becomes public API and what a package update can break. Several plugins on one site may bundle different versions of the package.

## Options considered

### Offer an abstract client that plugins extend

Each plugin or theme writes a class that extends `ApiClient`, which gives every integration the same structure. Saloon's `Connector` works this way. A method added to the package can clash with one the subclass defines, which is a fatal error when the class loads, and protected members become public API.

### Offer a final client that plugins hold

`ApiClient` is a `final` class. A plugin or theme writes a class that holds one and exposes named methods, with about the same code as a subclass. Guzzle marks its client `@final` for the same reason. Nothing enforces the structure, so the documentation must teach it.

### Offer an open class that plugins may use or extend

This serves both styles, but it keeps the risks of extending and gives two ways to do the same thing.

## Decision

Make `ApiClient` a `final` class and document one pattern: a plugin or theme holds a client inside its own class, and the rest of its code calls that class. An SDK or a one-off call may use `ApiClient` directly.

This beats an abstract client because a package update that adds a method cannot clash with a plugin's own methods. In a comparison with small stand-in classes, not the real package or Strauss, both shapes ran side by side when prefixed. Without prefixing, a method added to the base class caused a fatal error on load that `try/catch` could not catch, while a held client kept working.

The choice also stays open: removing `final` later breaks nobody, while adding `abstract` later would break every direct `new`.

The shape of the client does not prevent version conflicts. Strauss prefixing does, and it costs the same with either shape, so plugins and themes distributed to sites their authors do not control must prefix the package.

## Consequences

Adding a method to `ApiClient` in a minor release is safe for consumers.

A plugin's class can receive a client built with the in-memory transport, so plugin tests need neither WordPress nor a network.

The guide teaches the holding pattern, because nothing enforces it.

This decision is reviewed against real clients before 1.0, and `final` is removed only if they need extension.

## Confirmation

The worked example and the Strauss build hold a client, as a plugin would. At least one real client built on the package is reviewed before 1.0.

## More information

- [0010 Use nyholm/psr7, prefixed with Strauss](0010-use-nyholm-psr7-prefixed-with-strauss.md)
- [Design overview](../design/README.md)
- [Symfony backward compatibility promise](https://github.com/symfony/symfony-docs/blob/7.4/contributing/code/bc.rst)
- [Guzzle client](https://github.com/guzzle/guzzle/blob/7.10/src/Client.php)
- [Saloon connector](https://github.com/saloonphp/saloon/blob/v3/src/Http/Connector.php)
- [wp-background-processing](https://github.com/deliciousbrains/wp-background-processing)

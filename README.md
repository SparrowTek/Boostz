# Boostz
An open source Bitcoin lightning wallet via [Nostr Wallet Connect (NWC)](https://nwc.dev/)

## Project State

The code in this repo should be considered **non-functional** right now.

## Contributing

It is always a good idea to **discuss** before taking on a significant task. That said, I have a strong bias towards enthusiasm. If you are excited about doing something, I'll do my best to get out of your way.

By participating in this project you agree to abide by the [Contributor Code of Conduct](CODE_OF_CONDUCT.md).

### Building

**Note**: requires Xcode 16.2, macOS 15, and Swift 6.

- clone the repo
- `cp User.xcconfig.template User.xcconfig`
- update `User.xcconfig` with your personal information
- build/run with Xcode

**Tip** for OAUTH_REDIRECT_URI in `User.xccongif` to properly escape forward slashes you'll need to do something like this.
Assume you want your redirect URI to be boostz://alby, then `boostz:/$()/alby` is how you should enter this field. Notice the `$()`

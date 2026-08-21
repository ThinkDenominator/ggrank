# Contributing to ggrank

Thank you for considering a contribution. Please open an issue before starting
a substantial change so that the proposed behavior and scope can be discussed.

## Development workflow

1. Fork and clone the repository.
2. Create a focused branch.
3. Add or update tests and documentation with the implementation.
4. Run `devtools::test()` and `devtools::check()`.
5. Open a pull request describing the user problem and the chosen behavior.

The package deliberately focuses on rankings and rank change. New plotting
functions should reuse the common ranking engine and answer a distinct ranking
question rather than duplicate an established general-purpose chart type.

Please never contribute confidential, identifiable, or unlicensed data.
Teaching datasets must be synthetic or clearly redistributable under a
compatible licence.


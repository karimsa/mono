# @karimsa/mono [![CircleCI](https://circleci.com/gh/karimsa/mono.svg?style=svg)](https://circleci.com/gh/karimsa/mono)

Monorepo helper for JavaScript.

## Usage

To get started, you don't have to do anything. As long as your project follows the typical JS monorepo structure of having projects under `packages/` - you should be good to go.

To run a cross-project `npm install`, simply do `npx @karimsa/mono` (you don't have to install this package, it should download quite fast with npx given that it has no dependencies & it is really small).

Here's some other things you can do:

 - **Build all your packages:** `npx @karimsa/mono run build`
 - **Run all tests**: `npx @karimsa/mono test`
 - **Start all dev servers**: `npx @karimsa/mono start`
 - **Link all libraries**: `npx @karimsa/mono link` (`install` will also run `link` after)

## `start`

The `start` command in `@karimsa/mono` is a bit different from the other commands. Most commands will simply run the correct commands in each project directory, but `start` will concurrently run `start` across all projects that support it. This means that you can run all your dev servers in parallel, since this is the typical use case for `start`.

## `link`

The `link` command will create require shortcuts in all repositories to all other packages. For instance, if you have the following directory structure:

```
packages
 |--- a
 |--- b
```

Then running `npx @karimsa/mono link` will make it so that you can `require('a')` inside of `b` and `require('b')` inside of `a`. The require links the module directly rather than making a copy so changes will always be reflected when you do a `require()`.

## License

Licensed under the MIT license.

Copyright &copy; 2019-present Karim Alibhai. All rights reserved.

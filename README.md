# @karimsa/mono [![CircleCI](https://circleci.com/gh/karimsa/mono.svg?style=svg)](https://circleci.com/gh/karimsa/mono)

Monorepo helper for JavaScript.

## Usage

To get started, you don't have to do anything. As long as your project follows the typical JS monorepo structure of having projects under `packages/` - you should be good to go.

To run a cross-project `npm install`, simply do `npx @karimsa/mono` (you don't have to install this package, it should download quite fast with npx given that it has no dependencies & it is really small).

Here's some other things you can do:

 - **Build all your packages:** `npx @karimsa/mono run build`
 - **Run all tests**: `npx @karimsa/mono test`
 - **Start all dev servers**: `npx @karimsa/mono start`

## `npm start`

The `start` command in `@karimsa/mono` is a bit different from the other commands. Most commands will simply run the correct commands in each project directory, but `start` will concurrently run `start` across all projects that support it. This means that you can run all your dev servers in parallel, since this is the typical use case for `start`.

## License

Licensed under the MIT license.

Copyright &copy; 2019-present Karim Alibhai. All rights reserved.

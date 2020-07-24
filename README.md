# Coffeeformation :coffee::factory:

A [Coffeescript](http://coffeescript.org/) DSL to describe
your [AWS CloudFormation](https://aws.amazon.com/cloudformation/) stacks.
CloudFormation already allows you to describe your infrastructure using JSON or YAML data.
Coffeeformation takes the next step by enabling code structures like file includes, comments, helper functions, and loops.

## The tool
Coffeeformation is available as a lightweight command line tool
[published to npm](https://www.npmjs.com/package/coffeeformation).
Installation is straightforward:

```shell
npm install -g coffeeformation
```

There are a couple subcommands:

* `coffeeform compile` evaluates the Coffeeformation files (`*.cf.coffee`) in the current directory
  and generates matching CloudFormation JSON output files.
  This is the default mode, so there's a shorthand: simply `coffeeform`.
* `coffeeform decompile` is the opposite:
  It will take your existing CloudFormation JSON files (`*.cf`, `*.json`) in the current directory
  and output valid Coffeeformation files. This lets you get started with Coffeeformation easily,
  by immediately converting your existing JSON templates into readable coffeescript syntax.
  
  Once you decompile a folder of stacks, simply edit the generated files
  and run `coffeeform compile` going forward to sync the changes back to the CloudFormation JSON.

Filenames starting with an underscore are skipped when processing the current directory.
For example, you can have a `_vpc.coffee` file with shared VPC mapping data,
and use `require('./_vpc')` in a neighboring Coffeeform stack to include that data.

You can also provide an explicit list of files to either subcommand.
This overrides the directory scan for more advanced usage.

For available options and more CLI help, run `coffeeform --help`.

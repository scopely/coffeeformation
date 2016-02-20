exports.run = (argv) ->
  # Blank line aesthetic
  process.on 'exit', ->
    console.log()

  if '--version' in argv
    info = require '../package'
    console.error info.name, info.version
    console.error info.license, 'by', info.author?.name
    process.exit()

  if '--help' in argv
    console.error 'Usage:'
    console.error '  coffeeform [opts] compile [files...]'
    console.error '  coffeeform [opts] decompile [files...]'
    console.error 'If no arguments are passed, "compile" is assumed.'
    console.error ''
    console.error 'Options:'
    console.error '  --indent    Number of spaces per indentation level'
    console.error '              Applies to compiled JSON'
    console.error '              Default: 4'
    console.error '  --extension File extension for finding Coffeeformation'
    console.error '              Also used to name files when decompiling'
    console.error '              Default: .coffee'
    console.error '  --help      This text'
    console.error '  --version   Show metadata about your installation'
    console.error ''
    console.error 'Examples:'
    console.error '  coffeeform compile'
    console.error '    Compiles all .coffee files in the working directory'
    console.error '  coffeeform decompile my-stack.json'
    console.error '    Creates `my-stack.json.coffee` from `my-stack.json`'
    console.error '  coffeeform compile web.json.coffee --indent 2'
    console.error '    Sometimes you only want 2 spaces per tab in your JSON'
    process.exit()

  mode = switch argv[0]
    when 'compile', 'build'
      argv.shift()
      'compile'
    when 'decompile', 'dump'
      argv.shift()
      'decompile'
    else
      if argv[0] and argv[0][0] isnt '-'
        console.error 'Unknown subtask', ['"', '"'].join argv[0]
        console.error "Try using 'compile' or 'decompile'"
        process.exit 5
      'compile'

  impl = require './' + mode

  if '--indent' in argv
    [_, arg] = argv.splice argv.indexOf('--indent'), 2
    unless arg is ('' + Math.round(+arg)) # round-trips as an integer
      console.error '--indent must be followed by an integer'
      console.error 'Default: --indent 4'
      console.error 'Applies to compiled JSON only'
      process.exit 3
    impl.indentation = +arg

  if '--extension' in argv
    [_, arg] = argv.splice argv.indexOf('--extension'), 2
    unless arg
      console.error '--extension must be followed by a file extension'
      console.error 'Default: --extension .coffee'
      console.error 'Applies to naming and finding Coffeeformation files'
      process.exit 4
    impl.extension = arg
    unless impl.extension[0] is '.'
      impl.extension = '.' + impl.extension

  # Actually do work now

  if !argv[0]
    # Assume you want to run on current directory
    # TODO: we should handle listing files or at least final output
    unless impl.processFolder '.'
      process.exit 1

  else if '.' in argv[0] and argv[0][0] isnt '-'
    # Smells like a filename to me
    files = argv.map impl.processFile
    if errors = files.filter((f) -> not f).length
      console.log '❌  Had problems with', errors, 'files'
      process.exit 1
    else
      console.log '☕  Processed', files.length, 'files successfully'

  else
    console.error 'Unknown options', argv
    console.error 'Use --help for usage info'
    process.exit 2

  process.exit()

if require.main is module
  argv = process.argv.slice(2)
  exports.run(argv)

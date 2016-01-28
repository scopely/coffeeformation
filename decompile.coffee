{
  ParamTypes
  ResourceTypes
  ReferenceBuiltins
  KeyValList
} = require './common'

invert = (obj) ->
  out = {}
  for key, val of obj
    out[val] = key
  return out

ParamTypes = invert ParamTypes
ResourceTypes = invert ResourceTypes
ResourceTypes.Subnet = ResourceTypes['AWS::EC2::Subnet'] # apparently ok
ReferenceBuiltins = invert ReferenceBuiltins

isInlinable = (value) ->
  value.Ref or value.constructor in [Number, String, Boolean]

str = (value, delim="'") ->
  if value.Ref
    if ReferenceBuiltins[value.Ref]
      'ref.' + ReferenceBuiltins[value.Ref]
    else
      'ref(' + str(value.Ref, delim) + ')'
  else if value.constructor is Number or value is '0' or (''+value).match /^-?[1-9]\d*$/
    '' + Number(value)
  else if value.constructor is Boolean
    '' + value
  else if value.constructor is String
    if delim in value
      value = value.replace /#{delim}/g, "\\#{delim}"
    [delim, delim].join value
  else
    throw new Error "Couldn't stringify value #{JSON.stringify value} of type #{value.constructor}"


dumpObject = (obj, puts, depth=3) -> switch obj.constructor
  when String, Number, Boolean
    puts depth, str(obj)

  when Array
    puts depth, '['
    for entry in obj.slice(0, -1)
      dumpObject entry, puts, depth+1
      puts depth, ','
    dumpObject obj[obj.length-1], puts, depth+1
    puts depth, ']'

  when Object then for key, val of obj
    longKey = key
    if key.match /^\d/
      longKey = str(longKey)
    longKey += ':'

    switch
      when key is 'Ref'
        if ReferenceBuiltins[val]
          puts depth, 'ref.' + ReferenceBuiltins[val]
        else
          puts depth, 'ref', str(val)

      when key is 'Fn::Join'
        if val[0]
          puts depth, "fn.joinWith", str(val[0]) + ','
        else
          puts depth, "fn.join("

        for entry in val[1]
          dumpObject entry, puts, depth+1
        puts depth, ')' unless val[0]

      when key is 'Fn::FindInMap'
        puts depth, "fn.findIn", str(val[0]) + ','
        dumpObject val[1], puts, depth+1
        dumpObject val[2], puts, depth+1

      when key is 'Fn::Select'
        puts depth, "fn.select", str(val[0]) + ','
        dumpObject val[1], puts, depth+1

      when key is 'Fn::If'
        puts depth, "fn.if", str(val[0]) + ','
        dumpObject val[1], puts, depth+1
        dumpObject val[2], puts, depth+1

      when key is 'Fn::Base64'
        puts depth, "fn.base64("
        dumpObject val, puts, depth+1
        puts depth, ')'

      when key is 'Fn::GetAtt'
        puts depth, "fn.getAtt", str(val[0]) + ',', str(val[1])

      when key is 'Fn::GetAZs'
        puts depth, "fn.getAZs", str(val)

      when key in KeyValList
        puts depth, longKey
        for {Name, Value} in val
          Name = str(Name) if Name.match /^\d/
          Name += ':'

          if Value.constructor is String
            puts depth+1, Name, str(Value)
          else if Value.Ref?
            if ReferenceBuiltins[Value.Ref]
              puts depth+1, Name, 'ref.' + ReferenceBuiltins[Value.Ref]
            else
              puts depth+1, Name, 'ref', str(Value.Ref)
          else
            puts depth+1, Name
            dumpObject Value, puts, depth+2

      when not val?
        console.error 'WARN:', 'Encountered null value in object'
        puts depth, longKey, 'null'

      when val.constructor is Array
        puts depth, longKey, '['
        if val.every isInlinable
          for entry in val
            dumpObject entry, puts, depth+1
          puts depth, ']'
        else
          for entry in val.slice(0, -1)
            dumpObject entry, puts, depth+1
            puts depth, ','
          dumpObject val[val.length-1], puts, depth+1
          puts depth, ']'

      when val.Ref
        if ReferenceBuiltins[val.Ref]
          puts depth, longKey, 'ref.' + ReferenceBuiltins[val.Ref]
        else
          puts depth, longKey, 'ref', str(val.Ref)

      when val.constructor is Object
        puts depth, longKey
        dumpObject val, puts, depth+1

      when key.match /Description$/
        puts depth, longKey, str(val, '"')

      else
        puts depth, longKey, str(val)

  else
    throw new Error "Tried dumping object #{obj} but doesn't smell right"

dumpParam = (key, props, puts) ->
  {Type, Description} = props
  delete props.Type
  #delete props.Description

  decl = [str(key)]
  if false # Description
    decl.push decl.pop() + ','
    decl.push str(Description, '"')

  if Object.keys(props).length
    decl.push decl.pop() + ','

  type = ParamTypes[Type]
  unless type?
    throw new Error "Unhandled parameter type #{Type}"

  puts 2, '@' + type, decl...
  dumpObject props, puts

dumpCondition = (props, puts, depth=2) ->
  [logic, extra...] = Object.keys props
  args = props[logic]
  if extra.length
    throw new error "Extra keys in condition", props

  switch logic
    when 'Fn::And'
      puts depth, '@and('

    when 'Fn::Equals'
      puts depth, '@equals('
      for arg in args
        dumpObject arg, puts, depth+1
      puts depth, ')'
      return

    when 'Fn::Or'
      puts depth, '@or('

    when 'Fn::Not'
      puts depth, '@not'
      dumpObject args[0], puts, depth+1
      return

    else
      throw new Error "Unsupported condition #{logic} in #{JSON.stringify props}"

  # print arguments in standard fashion
  for arg in args
    dumpCondition arg, puts, depth+1
  puts depth, ')'

dumpResource = (key, props, puts) ->
  {Type, Condition, DependsOn, UpdatePolicy, Properties} = props
  # TODO: warn on others

  type = ResourceTypes[Type]
  unless type?
    throw new Error "Unhandled resource type #{Type}"

  propCount = if Properties then Object.keys(Properties).length else 0
  comma = ''
  if Condition or propCount or DependsOn or UpdatePolicy
    comma = ','

  puts 2, '@' + type, str(key) + comma
  dumpObject {Condition}, puts if Condition
  dumpObject Properties, puts if propCount
  dumpObject {DependsOn}, puts if DependsOn
  dumpObject {UpdatePolicy}, puts if UpdatePolicy

dumpStack = (stack, puts) ->
  puts 0, 'exports.stack = (ref, fn) ->'

  if stack.Description
    puts 1, '@description', str(stack.Description, '"')

  puts 0
  if stack.Parameters
    puts 1, '@params ->'
    for key, props of stack.Parameters
      dumpParam key, props, puts
    puts 0

  # mappings can't have anything in them
  if stack.Mappings
    for key, map of stack.Mappings
      puts 1, '@mapping', str(key) + ','
      dumpObject map, puts, 2
      puts 0

  # conditions can only use ref, fn.findInMap, or other conditions
  if stack.Conditions
    for key, props of stack.Conditions
      puts 1, '@condition', str(key) + ', ->'
      dumpCondition props, puts
      puts 0

  # resources can use like everything
  if stack.Resources
    puts 1, '@resources ->'
    for key, props of stack.Resources
      dumpResource key, props, puts
      puts 0

  # outputs can use ref and most other functions
  if stack.Outputs
    for key, props of stack.Outputs
      puts 1, '@output', str(key) + ','
      dumpObject props, puts, 2
      puts 0


fs = require 'fs'

decompileFile = (file) ->
  input = fs.readFileSync file, 'utf-8'
  stack = JSON.parse input

  output = fs.createWriteStream "#{file}.coffee"
  lines = 1
  dumpStack stack, (depth, parts...) ->
    output.write new Array(depth+1).join('  ')
    output.write parts.join(' ')
    output.write "\n"
    lines++
  output.end()

  console.log "#{file}:", input.split("\n").length, '->', lines, 'lines'

fs.readdirSync '.'
  .filter (name) -> name.match /\.(cf|json)$/
  .forEach decompileFile

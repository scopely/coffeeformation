{
  ParamTypes
  ResourceTypes
  ReferenceBuiltins
  KeyValList
} = require './common'

ConditionBuilder =
  equals: (a, b) -> 'Fn::Equals': [a, b]
  and: (a...) -> 'Fn::And': a
  or: (a...) -> 'Fn::Or': a
  not: (a) -> 'Fn::Not': [a]

Functions =
  join: (a...) -> 'Fn::Join': ['', a]
  joinWith: (d, a...) -> 'Fn::Join': [d, a]
  findIn: (a...) -> 'Fn::FindInMap': a
  select: (i, a) -> 'Fn::Select': [i, a]
  if: (a...) -> 'Fn::If': a
  base64: (a) -> 'Fn::Base64': a
  getAtt: (a, b) -> 'Fn::GetAtt': [a, b]
  getAZs: (a) -> 'Fn::GetAZs': a


Ref = (name) -> Ref: name
for alias, fullName of ReferenceBuiltins
  Ref[alias] = Ref fullName

stringify = (thing) -> switch thing?.constructor
  when String then thing
  when Number then ''+thing # CF uses strings for numbers
  when Boolean then thing
  when Array then thing.map stringify
  when Object
    obj = {}
    for key, val of thing
      obj[key] = stringify val
    return obj
  when undefined
    console.error 'WARN:', 'Encountered null value in object'
    null
  else
    throw new Error "Cannot stringify #{thing.constructor} #{thing}"

class ParamBuilder
  constructor: (@params) ->

  Object.keys(ParamTypes).forEach (alias) =>
    @::[alias] = (key, props) ->
      @param key, ParamTypes[alias], props

  param: (key, type, props={}) ->
    copy = Type: type
    for pkey, pval of props
      copy[pkey] = pval
    @params[key] = copy

class ResourceBuilder
  constructor: (@resources) ->

  Object.keys(ResourceTypes).forEach (alias) =>
    @::[alias] = (key, props) ->
      @resource key, ResourceTypes[alias], props

  resource: (key, type, props={}) ->
    res = Type: type

    for rootKey in ['Condition']
      if props[rootKey]?
        res[rootKey] = props[rootKey]
        delete props[rootKey]

    for keyValKey in [KeyValList..., 'Tags']
      # Make sure the field isn't already an array
      if props[keyValKey]? and not props[keyValKey].length?
        list = []
        for Name, Value of props[keyValKey]
          list.push {Name, Value}
        props[keyValKey] = list
    res.Properties = props

    # Special case to handle PropagateAtLaunch properly
    if type is 'AWS::AutoScaling::AutoScalingGroup' and props.InstanceTags
      # PropagateAtLaunch is required, make sure it's there first
      props.Tags ?= []
      for tag in props.Tags
        tag.PropagateAtLaunch ?= "false"

      # Add in tags from second list, where PropagateAtLaunch is true
      PropagateAtLaunch = "true"
      for Name, Value of props.InstanceTags
        props.Tags.push {Name, Value, PropagateAtLaunch}
      delete props.InstanceTags

    for rootKey in ['DependsOn', 'UpdatePolicy']
      if props[rootKey]?
        res[rootKey] = props[rootKey]
        delete props[rootKey]

    @resources[key] = res

class StackBuilder
  constructor: ->
    @cf = {} # TODO: base version

  evaluate: (block) ->
    block.call @, @ref, @fn

  ref: Ref
  fn: Functions

  description: (desc) ->
    @cf.Description = desc

  params: (block) ->
    @cf.Parameters ?= {}
    builder = new ParamBuilder @cf.Parameters
    block.call builder

  mapping: (key, props) ->
    @cf.Mappings ?= {}
    @cf.Mappings[key] = props

  condition: (key, block) ->
    @cf.Conditions ?= {}
    @cf.Conditions[key] = block.call ConditionBuilder

  resources: (block) ->
    @cf.Resources ?= {}
    builder = new ResourceBuilder @cf.Resources
    block.call builder

  output: (key, props) ->
    @cf.Outputs ?= {}
    @cf.Outputs[key] = props

  # Helper for accountId-based maps
  # Returns a getter that takes a single string argument
  accountMapping: (key, props) ->
    @mapping key, props
    return (subKey) ->
      Functions.findIn key, Ref.accountId, subKey

compileStack = (source, file) ->
  stack = new StackBuilder

  try
    stack.evaluate source.stack
    return stringify stack.cf
  catch error
    console.log "Encountered error processing stack", file
    console.log error.stack


fs = require 'fs'
path = require 'path'
require 'coffee-script/register'

# Settings
exports.indentation = 4
exports.extension = '.coffee'

exports.processFile = (file) ->
  lines = fs.readFileSync(file, 'utf-8').split("\n").length
  source = require path.join(process.cwd(), file)

  stack = compileStack source, file
  json = JSON.stringify(stack, null, exports.indentation ? 4) + '\n'
  fs.writeFileSync path.basename(file, exports.extension), json

  console.log "#{file}:", lines, '->', json.split("\n").length, 'lines'
  return lines

exports.processFolder = (folder='.') ->
  files = fs.readdirSync folder
    .filter (name) ->
      # implements endsWith
      name.slice(-exports.extension.length) is exports.extension
    .map exports.processFile

  if errors = files.filter((f) -> not f).length
    console.log '❌  Had problems with', errors, 'files'
  else
    console.log '☕  Compiled', files.length, 'files successfully'

  return errors is 0

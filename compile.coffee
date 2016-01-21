{ParamTypes, ResourceTypes, KeyValList} = require './common'

ConditionBuilder =
  equals: (a, b) -> 'Fn::Equals': [a, b]
  and: (a...) -> 'Fn::And': a
  or: (a...) -> 'Fn::Or': a
  not: (a) -> 'Fn::Not': [a]

Ref = (name) -> Ref: name
Ref.accountId = Ref 'AWS::AccountId'
Ref.region = Ref 'AWS::Region'
Ref.stackId = Ref 'AWS::StackId'
Ref.stackName = Ref 'AWS::StackName'

Functions =
  join: (a...) -> 'Fn::Join': ['', a]
  joinWith: (d, a...) -> 'Fn::Join': [d, a]
  findIn: (a...) -> 'Fn::FindInMap': a
  if: (a...) -> 'Fn::If': a
  base64: (a) -> 'Fn::Base64': a
  getAtt: (a, b) -> 'Fn::GetAtt': [a, b]


stringify = (thing) -> switch thing.constructor
  when String then thing
  when Number then ''+thing # CF uses strings for numbers
  when Boolean then thing
  when Array then thing.map stringify
  when Object
    obj = {}
    for key, val of thing
      obj[key] = stringify val
    return obj
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

    for keyValKey in KeyValList
      if props[keyValKey]?
        list = []
        for Name, Value of props[keyValKey]
          list.push {Name, Value}
        props[keyValKey] = list
    res.Properties = props

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

compileStack = (source, file) ->
  stack = new StackBuilder

  try
    stack.evaluate source.stack
  catch error
    console.log "Encountered error processing stack", file
    console.log error.stack

  return stringify stack.cf


fs = require 'fs'
path = require 'path'

compileFile = (file) ->
  lines = fs.readFileSync(file, 'utf-8').split("\n").length
  source = require path.join(process.cwd(), file)

  stack = compileStack source, file
  json = JSON.stringify(stack, null, 2) + '\n'
  fs.writeFileSync path.basename(file, '.coffee'), json

  console.log "#{file}:", lines, '->', json.split("\n").length, 'lines'

fs.readdirSync '.'
  .filter (name) -> name.match /\.coffee$/
  .forEach compileFile

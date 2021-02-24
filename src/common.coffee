exports.ParamTypes =
  string: 'String'
  number: 'Number'

  list:       'CommaDelimitedList'
  numberList: 'List<Number>'

  zone:          'AWS::EC2::AvailabilityZone::Name'
  ami:           'AWS::EC2::Image::Id'
  instance:      'AWS::EC2::Instance::Id'
  keyPair:       'AWS::EC2::KeyPair::KeyName'
  securityGroup: 'AWS::EC2::SecurityGroup::Id'
  subnet:        'AWS::EC2::Subnet::Id'
  volume:        'AWS::EC2::Volume::Id'
  vpc:           'AWS::EC2::VPC::Id'
  hostedZone:    'AWS::Route53::HostedZone::Id'

  zoneList:          'List<AWS::EC2::AvailabilityZone::Name>'
  amiList:           'List<AWS::EC2::Image::Id>'
  instanceList:      'List<AWS::EC2::Instance::Id>'
  keyPairList:       'List<AWS::EC2::KeyPair::KeyName>'
  securityGroupList: 'List<AWS::EC2::SecurityGroup::Id>'
  subnetList:        'List<AWS::EC2::Subnet::Id>'
  volumeList:        'List<AWS::EC2::Volume::Id>'
  vpcList:           'List<AWS::EC2::VPC::Id>'
  hostedZoneList:    'List<AWS::Route53::HostedZone::Id>'

exports.ResourceTypes =
  asg:             'AWS::AutoScaling::AutoScalingGroup'
  launchConfig:    'AWS::AutoScaling::LaunchConfiguration'
  lifecycleHook:   'AWS::AutoScaling::LifecycleHook'
  scalingPolicy:   'AWS::AutoScaling::ScalingPolicy'
  scheduledAction: 'AWS::AutoScaling::ScheduledAction'

  stack: 'AWS::CloudFormation::Stack'

  alarm: 'AWS::CloudWatch::Alarm'

  dynamoTable: 'AWS::DynamoDB::Table'

  kinesisStream: 'AWS::Kinesis::Stream'

  kmsKey: 'AWS::KMS::Key'
  kmsAlias: 'AWS::KMS::Alias'

  elasticIp:       'AWS::EC2::EIP'
  instance:        'AWS::EC2::Instance'
  internetGateway: 'AWS::EC2::InternetGateway'
  nacl:            'AWS::EC2::NetworkAcl'
  naclEntry:       'AWS::EC2::NetworkAclEntry'
  route:           'AWS::EC2::Route'
  routeTable:      'AWS::EC2::RouteTable'
  securityGroup:   'AWS::EC2::SecurityGroup'
  ingress:         'AWS::EC2::SecurityGroupIngress'
  subnet:          'AWS::EC2::Subnet'
  naclAssoc:       'AWS::EC2::SubnetNetworkAclAssociation'
  routeTableAssoc: 'AWS::EC2::SubnetRouteTableAssociation'
  vpc:             'AWS::EC2::VPC'
  gatewayAssoc:    'AWS::EC2::VPCGatewayAttachment'

  cacheSubnetGroup: 'AWS::ElastiCache::SubnetGroup'

  elb: 'AWS::ElasticLoadBalancing::LoadBalancer'

  lambdaAlias:       'AWS::Lambda::Alias'
  lambdaEventSource: 'AWS::Lambda::EventSourceMapping'
  lambdaEventInvokeConfig: 'AWS::Lambda::EventInvokeConfig'
  lambda:            'AWS::Lambda::Function'
  lambdaPermission:  'AWS::Lambda::Permission'
  lambdaVersion:     'AWS::Lambda::Version'

  rdsSubnetGroup: 'AWS::RDS::DBSubnetGroup'

  redshiftIngress: 'AWS::Redshift::ClusterSecurityGroupIngress'

  recordSetGroup: 'AWS::Route53::RecordSetGroup'
  recordSet:      'AWS::Route53::RecordSet'
  
  bucket:       'AWS::S3::Bucket'
  bucketPolicy: 'AWS::S3::BucketPolicy'

  queue: 'AWS::SQS::Queue'

  iamAccessKey:         'AWS::IAM::AccessKey',
  iamGroup:             'AWS::IAM::AccessKey',
  iamInstanceProfile:   'AWS::IAM::InstanceProfile',
  iamManagedPolicy:     'AWS::IAM::ManagedPolicy',
  iamPolicy:            'AWS::IAM::Policy',
  iamRole:              'AWS::IAM::Role',
  iamServiceLinkedRole: 'AWS::IAM::ServiceLinkedRole',
  iamUser:              'AWS::IAM::User',
  iamUserGroupAddition: 'AWS::IAM::UserToGroupAddition',

exports.ReferenceBuiltins =
  accountId:        'AWS::AccountId'
  notificationARNs: 'AWS::NotificationARNs'
  noValue:          'AWS::NoValue'
  region:           'AWS::Region'
  stackId:          'AWS::StackId'
  stackName:        'AWS::StackName'

exports.KeyValList = [
  'Dimensions'
  # 'Tags' # Special-cased for ASGs, where PropagateAtLaunch is required
]
